import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/food_analysis_result.dart';
import 'food_analysis_service.dart';

const openAiResponsesEndpoint = 'https://api.openai.com/v1/responses';

class FoodAnalysisHttpResponse {
  const FoodAnalysisHttpResponse(
      {required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

abstract interface class FoodAnalysisHttpTransport {
  Future<FoodAnalysisHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  });
}

class IoFoodAnalysisHttpTransport implements FoodAnalysisHttpTransport {
  const IoFoodAnalysisHttpTransport();

  @override
  Future<FoodAnalysisHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.postUrl(uri).timeout(timeout);
      headers.forEach(request.headers.set);
      request.write(body);
      final response = await request.close().timeout(timeout);
      final responseBody =
          await utf8.decoder.bind(response).join().timeout(timeout);
      return FoodAnalysisHttpResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } finally {
      client.close(force: true);
    }
  }
}

/// Temporary direct-client integration for private testing only.
///
/// Before any public distribution, move this API call and secret to a backend.
class DirectOpenAiFoodAnalysisService implements FoodAnalysisService {
  const DirectOpenAiFoodAnalysisService({
    required this.apiKey,
    required this.model,
    this.transport = const IoFoodAnalysisHttpTransport(),
    this.timeout = const Duration(seconds: 30),
  });

  final String apiKey;
  final String model;
  final FoodAnalysisHttpTransport transport;
  final Duration timeout;

  @override
  Future<FoodAnalysisBatchResult> analyze(String input) async {
    final foodText = input.trim();
    if (foodText.isEmpty) {
      throw const FoodAnalysisException(FoodAnalysisErrorType.badRequest);
    }
    try {
      final response = await transport.post(
        uri: Uri.parse(openAiResponsesEndpoint),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $apiKey',
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        body: jsonEncode(_requestBody(foodText)),
        timeout: timeout,
      );
      _throwForStatus(response.statusCode);
      return parseResponse(response.body, originalInput: foodText);
    } on FoodAnalysisException {
      rethrow;
    } on TimeoutException catch (_) {
      throw const FoodAnalysisException(FoodAnalysisErrorType.network);
    } on SocketException catch (_) {
      throw const FoodAnalysisException(FoodAnalysisErrorType.network);
    } on HttpException catch (_) {
      throw const FoodAnalysisException(FoodAnalysisErrorType.network);
    } on IOException catch (_) {
      throw const FoodAnalysisException(FoodAnalysisErrorType.network);
    } catch (_) {
      throw const FoodAnalysisException(FoodAnalysisErrorType.unknown);
    }
  }

  Map<String, dynamic> _requestBody(String foodText) => {
        'model': model,
        'store': false,
        'max_output_tokens': 2000,
        'input': [
          {
            'role': 'developer',
            'content':
                'Analyze Persian food descriptions, including Iranian foods, and normalize Persian and Arabic digits. Split multiple foods into separate items. Estimate calories, protein, carbohydrates, and fat. Preserve each original quantity phrase and support units including عدد، گرم، کیلوگرم، لیوان، قاشق غذاخوری، قاشق چای‌خوری، کف دست، پیمانه، بشقاب، کاسه، and برش. For ambiguity, make a reasonable explicit assumption. Confidence must be low, medium, or high; do not invent certainty. Values must be non-negative estimates and are not medical advice. Analyze only the food text in the user message and never infer or request personal data.',
          },
          {'role': 'user', 'content': foodText},
        ],
        'text': {
          'format': {
            'type': 'json_schema',
            'name': 'food_analysis_batch',
            'strict': true,
            'schema': {
              'type': 'object',
              'additionalProperties': false,
              'properties': {
                'originalInput': {'type': 'string'},
                'items': {
                  'type': 'array',
                  'minItems': 1,
                  'items': {
                    'type': 'object',
                    'additionalProperties': false,
                    'properties': {
                      'foodName': {'type': 'string'},
                      'quantityText': {'type': 'string'},
                      'calories': {'type': 'number', 'minimum': 0},
                      'proteinGrams': {'type': 'number', 'minimum': 0},
                      'carbsGrams': {'type': 'number', 'minimum': 0},
                      'fatGrams': {'type': 'number', 'minimum': 0},
                      'isEstimated': {'type': 'boolean'},
                      'confidence': {
                        'type': 'string',
                        'enum': ['low', 'medium', 'high'],
                      },
                      'assumptions': {
                        'type': 'array',
                        'items': {'type': 'string'},
                      },
                    },
                    'required': [
                      'foodName',
                      'quantityText',
                      'calories',
                      'proteinGrams',
                      'carbsGrams',
                      'fatGrams',
                      'isEstimated',
                      'confidence',
                      'assumptions',
                    ],
                  },
                },
                'warnings': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
              },
              'required': ['originalInput', 'items', 'warnings'],
            },
          },
        },
      };

  static FoodAnalysisBatchResult parseResponse(
    String responseBody, {
    required String originalInput,
  }) {
    try {
      final envelope = jsonDecode(responseBody) as Map<String, dynamic>;
      final output = envelope['output'] as List<dynamic>?;
      if (output == null) _malformed();

      String? structuredText;
      for (final rawMessage in output) {
        if (rawMessage is! Map || rawMessage['type'] != 'message') continue;
        final content = rawMessage['content'] as List<dynamic>? ?? const [];
        for (final rawContent in content) {
          if (rawContent is! Map) continue;
          if (rawContent['type'] == 'refusal') _malformed();
          if (rawContent['type'] == 'output_text') {
            structuredText = rawContent['text'] as String?;
            break;
          }
        }
      }
      if (structuredText == null || structuredText.isEmpty) _malformed();
      final payload = jsonDecode(structuredText) as Map<String, dynamic>;
      final rawItems = payload['items'] as List<dynamic>?;
      if (rawItems == null || rawItems.isEmpty) _malformed();

      final items = rawItems.map((raw) {
        if (raw is! Map) _malformed();
        final map = Map<String, dynamic>.from(raw);
        final foodName = map['foodName'] as String?;
        final quantityText = map['quantityText'] as String?;
        final confidence = map['confidence'] as String?;
        final assumptions = map['assumptions'] as List<dynamic>?;
        final isEstimated = map['isEstimated'];
        if (foodName == null ||
            foodName.trim().isEmpty ||
            quantityText == null ||
            quantityText.trim().isEmpty ||
            !const {'low', 'medium', 'high'}.contains(confidence) ||
            assumptions == null ||
            assumptions.any((value) => value is! String) ||
            isEstimated is! bool) {
          _malformed();
        }
        final calories = _validNumber(map['calories']);
        final protein = _validNumber(map['proteinGrams']);
        final carbs = _validNumber(map['carbsGrams']);
        final fat = _validNumber(map['fatGrams']);
        return FoodAnalysisResult(
          originalInput: originalInput,
          foodName: foodName.trim(),
          quantityText: quantityText.trim(),
          calories: calories.roundToDouble(),
          proteinGrams: _roundMacro(protein),
          carbsGrams: _roundMacro(carbs),
          fatGrams: _roundMacro(fat),
          isEstimated: isEstimated,
          confidence: confidence!,
          assumptions: assumptions.cast<String>(),
        );
      }).toList(growable: false);

      final rawWarnings = payload['warnings'] as List<dynamic>?;
      if (rawWarnings == null || rawWarnings.any((value) => value is! String)) {
        _malformed();
      }
      return FoodAnalysisBatchResult(
        originalInput: originalInput,
        items: items,
        warnings: rawWarnings.cast<String>(),
      );
    } on FoodAnalysisException {
      rethrow;
    } catch (_) {
      throw const FoodAnalysisException(FoodAnalysisErrorType.malformed);
    }
  }

  static Never _malformed() =>
      throw const FoodAnalysisException(FoodAnalysisErrorType.malformed);

  static double _validNumber(Object? value) {
    if (value is! num) _malformed();
    final result = value.toDouble();
    if (!result.isFinite || result < 0) _malformed();
    return result;
  }

  static double _roundMacro(double value) =>
      double.parse(value.toStringAsFixed(1));

  static void _throwForStatus(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return;
    final type = switch (statusCode) {
      400 => FoodAnalysisErrorType.badRequest,
      401 || 403 => FoodAnalysisErrorType.unauthorized,
      429 => FoodAnalysisErrorType.rateLimited,
      >= 500 => FoodAnalysisErrorType.unavailable,
      _ => FoodAnalysisErrorType.unknown,
    };
    throw FoodAnalysisException(type);
  }
}
