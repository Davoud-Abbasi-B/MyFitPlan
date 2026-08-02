import 'daily_nutrition_model.dart';

class FoodAnalysisResult {
  const FoodAnalysisResult({
    required this.originalInput,
    required this.foodName,
    required this.quantityText,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.isEstimated,
    this.confidence = 'medium',
    this.assumptions = const [],
  });

  final String originalInput;
  final String foodName;
  final String quantityText;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final bool isEstimated;
  final String confidence;
  final List<String> assumptions;

  Map<String, dynamic> toJson() => {
        'originalInput': originalInput,
        'foodName': foodName,
        'quantityText': quantityText,
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'isEstimated': isEstimated,
        'confidence': confidence,
        'assumptions': assumptions,
      };

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      originalInput: json['originalInput'] as String? ?? '',
      foodName: json['foodName'] as String? ?? '',
      quantityText: json['quantityText'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0,
      fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0,
      isEstimated: json['isEstimated'] as bool? ?? true,
      confidence: json['confidence'] as String? ?? 'medium',
      assumptions: (json['assumptions'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }
}

class FoodAnalysisBatchResult {
  FoodAnalysisBatchResult({
    required this.originalInput,
    required List<FoodAnalysisResult> items,
    List<String> warnings = const [],
  })  : items = List.unmodifiable(items),
        warnings = List.unmodifiable(warnings);

  final String originalInput;
  final List<FoodAnalysisResult> items;
  final List<String> warnings;

  DailyNutritionTotals get totals {
    var calories = 0.0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    for (final item in items) {
      calories += item.calories;
      protein += item.proteinGrams;
      carbs += item.carbsGrams;
      fat += item.fatGrams;
    }
    return DailyNutritionTotals(
      calories: calories.roundToDouble(),
      proteinGrams: _oneDecimal(protein),
      carbsGrams: _oneDecimal(carbs),
      fatGrams: _oneDecimal(fat),
    );
  }
}

double _oneDecimal(double value) => double.parse(value.toStringAsFixed(1));
