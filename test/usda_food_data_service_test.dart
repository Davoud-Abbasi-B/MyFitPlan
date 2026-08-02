import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/features/nutrition/services/food_analysis_service.dart';
import 'package:my_fit_plan/features/nutrition/services/usda_food_data_service.dart';

void main() {
  test('creates the documented search request without leaking unrelated data',
      () async {
    late Uri uri;
    late String body;
    final service = UsdaFoodDataService(
      apiKey: 'test-key',
      transport: _FakeTransport((request) async {
        uri = request.uri;
        body = request.body ?? '';
        return UsdaHttpResponse(
          statusCode: 200,
          body: jsonEncode({
            'foods': [_food()]
          }),
        );
      }),
    );
    await service.search('chicken breast cooked');
    expect(uri.path, '/fdc/v1/foods/search');
    expect(uri.queryParameters['api_key'], 'test-key');
    final json = jsonDecode(body) as Map<String, dynamic>;
    expect(json['query'], 'chicken breast cooked');
    expect(json['pageSize'], 10);
    expect(body, isNot(contains('nutrition history')));
  });

  test('extracts nutrients by identifiers and converts kJ to kcal', () {
    final result = UsdaFoodDataService.extractNutrients([
      {
        'nutrientId': 1008,
        'nutrientName': 'Energy',
        'unitName': 'kJ',
        'value': 418.4
      },
      {
        'nutrientId': 1003,
        'nutrientName': 'Protein',
        'unitName': 'g',
        'value': 20
      },
      {
        'nutrientId': 1005,
        'nutrientName': 'Carbohydrate, by difference',
        'unitName': 'g',
        'value': 4
      },
      {
        'nutrientId': 1004,
        'nutrientName': 'Total lipid (fat)',
        'unitName': 'g',
        'value': 3
      },
    ]);
    expect(result.calories, closeTo(100, 0.01));
    expect(result.protein, 20);
    expect(result.carbs, 4);
    expect(result.fat, 3);
  });

  test('missing nutrient becomes zero and kcal is preserved', () {
    final result = UsdaFoodDataService.extractNutrients([
      {'nutrientName': 'Energy', 'unitName': 'kcal', 'value': 120},
      {'nutrientName': 'Protein', 'unitName': 'g', 'value': 5},
    ]);
    expect(result.calories, 120);
    expect(result.carbs, 0);
    expect(result.fat, 0);
  });

  test('maps malformed, authorization, rate limit, timeout, and no results',
      () async {
    for (final pair in [
      (401, FoodAnalysisErrorType.unauthorized),
      (403, FoodAnalysisErrorType.unauthorized),
      (429, FoodAnalysisErrorType.rateLimited),
    ]) {
      final service = UsdaFoodDataService(
        apiKey: 'test',
        transport: _FakeTransport(
            (_) async => UsdaHttpResponse(statusCode: pair.$1, body: '{}')),
      );
      await expectLater(service.search('food'), throwsA(_type(pair.$2)));
    }
    final timeout = UsdaFoodDataService(
      apiKey: 'test',
      transport: _FakeTransport((_) => throw TimeoutException('test')),
    );
    await expectLater(
        timeout.search('food'), throwsA(_type(FoodAnalysisErrorType.network)));

    final empty = UsdaFoodDataService(
      apiKey: 'test',
      transport: _FakeTransport((_) async =>
          const UsdaHttpResponse(statusCode: 200, body: '{"foods":[]}')),
    );
    await expectLater(
        empty.search('food'), throwsA(_type(FoodAnalysisErrorType.noResults)));

    final malformed = UsdaFoodDataService(
      apiKey: 'test',
      transport: _FakeTransport(
          (_) async => const UsdaHttpResponse(statusCode: 200, body: '{}')),
    );
    await expectLater(malformed.search('food'),
        throwsA(_type(FoodAnalysisErrorType.malformed)));
  });

  test('ranking prefers generic cooked reference food over branded sandwich',
      () {
    final foundation = UsdaCandidateRanker.score(
      query: 'chicken breast cooked',
      description: 'Chicken breast meat only cooked roasted',
      dataType: 'Foundation',
      isBranded: false,
    );
    final branded = UsdaCandidateRanker.score(
      query: 'chicken breast cooked',
      description: 'Brand chicken breast sandwich breaded',
      dataType: 'Branded',
      isBranded: true,
    );
    final raw = UsdaCandidateRanker.score(
      query: 'chicken breast cooked',
      description: 'Chicken breast raw',
      dataType: 'SR Legacy',
      isBranded: false,
    );
    expect(foundation, greaterThan(branded));
    expect(foundation, greaterThan(raw));
  });
}

Map<String, dynamic> _food() => {
      'fdcId': 1,
      'description': 'Chicken breast cooked',
      'dataType': 'Foundation',
      'foodNutrients': [
        {
          'nutrientId': 1008,
          'nutrientName': 'Energy',
          'unitName': 'kcal',
          'value': 165
        },
        {
          'nutrientId': 1003,
          'nutrientName': 'Protein',
          'unitName': 'g',
          'value': 31
        },
      ],
    };

Matcher _type(FoodAnalysisErrorType type) =>
    isA<FoodAnalysisException>().having((error) => error.type, 'type', type);

class _Request {
  const _Request(this.method, this.uri, this.body);
  final String method;
  final Uri uri;
  final String? body;
}

class _FakeTransport implements UsdaHttpTransport {
  const _FakeTransport(this.handler);
  final Future<UsdaHttpResponse> Function(_Request request) handler;

  @override
  Future<UsdaHttpResponse> send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
    required Duration timeout,
  }) =>
      handler(_Request(method, uri, body));
}
