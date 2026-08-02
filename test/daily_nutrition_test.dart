import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/features/nutrition/models/daily_nutrition_model.dart';
import 'package:my_fit_plan/features/nutrition/models/food_analysis_result.dart';
import 'package:my_fit_plan/features/nutrition/providers/daily_nutrition_provider.dart';
import 'package:my_fit_plan/features/nutrition/services/direct_openai_food_analysis_service.dart';
import 'package:my_fit_plan/features/nutrition/services/food_analysis_service.dart';
import 'package:my_fit_plan/features/nutrition/services/mock_food_analysis_service.dart';

void main() {
  const service = MockFoodAnalysisService(analysisDelay: Duration.zero);

  test('normalizes Persian and Arabic numbers', () {
    expect(normalizePersianNumber('۱۲۳٫۵'), '123.5');
    expect(normalizePersianNumber('٤ عدد'), '4 عدد');
  });

  test('parses four eggs and multiplies macros', () async {
    final batch = await service.analyze('۴ عدد تخم‌مرغ');
    final result = batch.items.single;

    expect(result.foodName, 'تخم‌مرغ');
    expect(result.quantityText, '۴ عدد');
    expect(result.calories, 280);
    expect(result.proteinGrams, 24);
    expect(result.carbsGrams, 2);
    expect(result.fatGrams, 20);
    expect(result.isEstimated, isTrue);
  });

  test('parses 100 grams of Barbari bread', () async {
    final batch = await service.analyze('100 گرم نان بربری');
    final result = batch.items.single;

    expect(result.foodName, 'نان بربری');
    expect(result.quantityText, '۱۰۰ گرم');
    expect(result.calories, 270);
    expect(result.proteinGrams, 9);
    expect(result.carbsGrams, 55);
    expect(result.fatGrams, 2);
  });

  test('calculates daily totals', () {
    final entries = [
      _entry(id: '1', calories: 280, protein: 24, carbs: 2, fat: 20),
      _entry(id: '2', calories: 270, protein: 9, carbs: 55, fat: 2),
    ];

    final totals = DailyNutritionTotals.fromEntries(entries);
    expect(totals.calories, 550);
    expect(totals.proteinGrams, 33);
    expect(totals.carbsGrams, 57);
    expect(totals.fatGrams, 22);
  });

  test('prevents a second report for the same date', () {
    final report = DailyNutritionReport.fromEntries(
      dateKey: '2026-08-02',
      entries: [_entry(id: '1')],
      dayType: NutritionDayType.training,
    );

    expect(canSubmitNutritionReport([], report.dateKey), isTrue);
    expect(canSubmitNutritionReport([report], report.dateKey), isFalse);
  });

  test('entry and report serialization round trip', () {
    final entry = _entry(id: 'persisted');
    final decodedEntry = DailyNutritionEntry.fromJson(entry.toJson());
    expect(decodedEntry.id, entry.id);
    expect(decodedEntry.foodName, entry.foodName);
    expect(decodedEntry.calories, entry.calories);

    final report = DailyNutritionReport.fromEntries(
      dateKey: entry.dateKey,
      entries: [entry],
      dayType: NutritionDayType.rest,
      submittedAt: DateTime(2026, 8, 2, 12),
    );
    final decodedReport = DailyNutritionReport.fromJson(report.toJson());
    expect(decodedReport.dateKey, report.dateKey);
    expect(decodedReport.entries.single.id, entry.id);
    expect(decodedReport.dayType, NutritionDayType.rest);
    expect(decodedReport.totalCalories, entry.calories);
  });

  test('selects mock only when the API key is empty', () {
    expect(
      createFoodAnalysisService(apiKey: ''),
      isA<MockFoodAnalysisService>(),
    );
    expect(
      createFoodAnalysisService(apiKey: 'test-placeholder'),
      isA<DirectOpenAiFoodAnalysisService>(),
    );
  });

  test('parses multiple foods, rounds values, and recalculates totals', () {
    final batch = DirectOpenAiFoodAnalysisService.parseResponse(
      _responseBody(items: [
        _foodJson(name: 'تخم‌مرغ', calories: 140.4, protein: 12.04),
        _foodJson(name: 'شیر', calories: 100.6, protein: 6.06),
      ]),
      originalInput: 'دو تخم‌مرغ و یک لیوان شیر',
    );

    expect(batch.items, hasLength(2));
    expect(batch.items.first.calories, 140);
    expect(batch.items.last.calories, 101);
    expect(batch.items.first.proteinGrams, 12);
    expect(batch.items.last.proteinGrams, 6.1);
    expect(batch.totals.calories, 241);
    expect(batch.totals.proteinGrams, 18.1);
  });

  test('rejects malformed and negative structured responses', () {
    expect(
      () => DirectOpenAiFoodAnalysisService.parseResponse(
        '{}',
        originalInput: 'غذا',
      ),
      throwsA(_errorType(FoodAnalysisErrorType.malformed)),
    );
    expect(
      () => DirectOpenAiFoodAnalysisService.parseResponse(
        _responseBody(items: [_foodJson(name: 'غذا', calories: -1)]),
        originalInput: 'غذا',
      ),
      throwsA(_errorType(FoodAnalysisErrorType.malformed)),
    );
  });

  test('maps timeout, 401, and 429 without making real HTTP calls', () async {
    final timeoutService = DirectOpenAiFoodAnalysisService(
      apiKey: 'test-placeholder',
      model: 'test-model',
      transport: _FakeTransport((_) => throw TimeoutException('test')),
    );
    await expectLater(
      timeoutService.analyze('غذا'),
      throwsA(_errorType(FoodAnalysisErrorType.network)),
    );
    expect(
      foodAnalysisErrorMessage(
        const FoodAnalysisException(FoodAnalysisErrorType.network),
      ),
      'ارتباط با سرویس محاسبه برقرار نشد. دوباره تلاش کنید.',
    );

    for (final status in [401, 429]) {
      final service = DirectOpenAiFoodAnalysisService(
        apiKey: 'test-placeholder',
        model: 'test-model',
        transport: _FakeTransport(
          (_) async => FoodAnalysisHttpResponse(statusCode: status, body: ''),
        ),
      );
      await expectLater(
        service.analyze('غذا'),
        throwsA(_errorType(
          status == 401
              ? FoodAnalysisErrorType.unauthorized
              : FoodAnalysisErrorType.rateLimited,
        )),
      );
    }
  });

  test('adds every analyzed item as a separate draft entry', () {
    final items = [
      _result('تخم‌مرغ'),
      _result('شیر'),
    ];
    final entries = dailyNutritionEntriesFromAnalyses(
      items,
      dateKey: '2026-08-02',
      createdAt: DateTime(2026, 8, 2, 12),
    );

    expect(entries.map((entry) => entry.foodName), ['تخم‌مرغ', 'شیر']);
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
  });

  test('confirmation guard prevents a repeated insert', () {
    final guard = FoodConfirmationGuard();
    expect(guard.tryConfirm(), isTrue);
    expect(guard.tryConfirm(), isFalse);
  });
}

Matcher _errorType(FoodAnalysisErrorType type) =>
    isA<FoodAnalysisException>().having((error) => error.type, 'type', type);

Map<String, dynamic> _foodJson({
  required String name,
  double calories = 70,
  double protein = 6,
}) =>
    {
      'foodName': name,
      'quantityText': '۱ عدد',
      'calories': calories,
      'proteinGrams': protein,
      'carbsGrams': 0.5,
      'fatGrams': 5,
      'isEstimated': true,
      'confidence': 'medium',
      'assumptions': ['اندازه متوسط'],
    };

String _responseBody({required List<Map<String, dynamic>> items}) =>
    jsonEncode({
      'output': [
        {
          'type': 'message',
          'content': [
            {
              'type': 'output_text',
              'text': jsonEncode({
                'originalInput': 'ورودی',
                'items': items,
                'warnings': ['تخمینی'],
              }),
            },
          ],
        },
      ],
    });

FoodAnalysisResult _result(String name) => FoodAnalysisResult(
      originalInput: name,
      foodName: name,
      quantityText: '۱ عدد',
      calories: 70,
      proteinGrams: 6,
      carbsGrams: 0.5,
      fatGrams: 5,
      isEstimated: true,
    );

class _FakeTransport implements FoodAnalysisHttpTransport {
  const _FakeTransport(this.handler);

  final Future<FoodAnalysisHttpResponse> Function(String body) handler;

  @override
  Future<FoodAnalysisHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) {
    return handler(body);
  }
}

DailyNutritionEntry _entry({
  required String id,
  double calories = 70,
  double protein = 6,
  double carbs = 0.5,
  double fat = 5,
}) {
  const result = FoodAnalysisResult(
    originalInput: '۱ عدد تخم‌مرغ',
    foodName: 'تخم‌مرغ',
    quantityText: '۱ عدد',
    calories: 70,
    proteinGrams: 6,
    carbsGrams: 0.5,
    fatGrams: 5,
    isEstimated: true,
  );
  return DailyNutritionEntry(
    id: id,
    dateKey: '2026-08-02',
    createdAt: DateTime(2026, 8, 2, 10),
    originalInput: result.originalInput,
    foodName: result.foodName,
    quantityText: result.quantityText,
    calories: calories,
    proteinGrams: protein,
    carbsGrams: carbs,
    fatGrams: fat,
    isEstimated: result.isEstimated,
  );
}
