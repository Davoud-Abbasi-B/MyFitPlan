import 'daily_nutrition_model.dart';

enum FoodSourceType { local, usda, manual }

enum FoodResolutionStatus { resolved, ambiguous, needsPortion, notFound }

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
    this.warnings = const [],
    this.consumedGrams,
    this.sourceType = FoodSourceType.local,
    this.sourceLabel = 'پایگاه داخلی',
    this.fdcId,
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
  final List<String> warnings;
  final double? consumedGrams;
  final FoodSourceType sourceType;
  final String sourceLabel;
  final int? fdcId;

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
        'warnings': warnings,
        'consumedGrams': consumedGrams,
        'sourceType': sourceType.name,
        'sourceLabel': sourceLabel,
        'fdcId': fdcId,
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
      warnings: (json['warnings'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      consumedGrams: (json['consumedGrams'] as num?)?.toDouble(),
      sourceType: FoodSourceType.values.firstWhere(
        (value) => value.name == json['sourceType'],
        orElse: () => FoodSourceType.local,
      ),
      sourceLabel: json['sourceLabel'] as String? ?? 'داده ذخیره‌شده',
      fdcId: json['fdcId'] as int?,
    );
  }
}

class FoodAnalysisBatchResult {
  FoodAnalysisBatchResult({
    required this.originalInput,
    required List<FoodAnalysisResult> items,
    List<String> warnings = const [],
    List<UnresolvedFoodItem> unresolvedItems = const [],
  })  : items = List.unmodifiable(items),
        warnings = List.unmodifiable(warnings),
        unresolvedItems = List.unmodifiable(unresolvedItems);

  final String originalInput;
  final List<FoodAnalysisResult> items;
  final List<String> warnings;
  final List<UnresolvedFoodItem> unresolvedItems;

  bool get needsUserAction => unresolvedItems.isNotEmpty;
  bool get hasResolvedItems => items.isNotEmpty;
  bool get canConfirm => hasResolvedItems && !needsUserAction;

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

class FoodAnalysisCandidate {
  const FoodAnalysisCandidate({
    required this.id,
    required this.description,
    required this.dataType,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.matchScore,
    this.brandOwner,
    this.servingSize,
    this.servingSizeUnit,
  });

  final int id;
  final String description;
  final String dataType;
  final String? brandOwner;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double matchScore;
  final double? servingSize;
  final String? servingSizeUnit;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'dataType': dataType,
        'brandOwner': brandOwner,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatPer100g': fatPer100g,
        'matchScore': matchScore,
        'servingSize': servingSize,
        'servingSizeUnit': servingSizeUnit,
      };

  factory FoodAnalysisCandidate.fromJson(Map<String, dynamic> json) =>
      FoodAnalysisCandidate(
        id: json['id'] as int? ?? json['fdcId'] as int? ?? 0,
        description: json['description'] as String? ?? '',
        dataType: json['dataType'] as String? ?? '',
        brandOwner: json['brandOwner'] as String?,
        caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble() ?? 0,
        proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0,
        carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble() ?? 0,
        fatPer100g: (json['fatPer100g'] as num?)?.toDouble() ?? 0,
        matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0,
        servingSize: (json['servingSize'] as num?)?.toDouble(),
        servingSizeUnit: json['servingSizeUnit'] as String?,
      );
}

class UnresolvedFoodItem {
  const UnresolvedFoodItem({
    required this.originalSegment,
    required this.foodName,
    required this.quantityText,
    required this.quantity,
    required this.unit,
    required this.reason,
    required this.status,
    this.consumedGrams,
    this.searchPhrase,
    this.candidates = const [],
  });

  final String originalSegment;
  final String foodName;
  final String quantityText;
  final double? quantity;
  final String? unit;
  final double? consumedGrams;
  final String? searchPhrase;
  final String reason;
  final FoodResolutionStatus status;
  final List<FoodAnalysisCandidate> candidates;

  bool get allowsManualEntry => status != FoodResolutionStatus.resolved;
}

double _oneDecimal(double value) => double.parse(value.toStringAsFixed(1));
