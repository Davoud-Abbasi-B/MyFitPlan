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
  });

  final String originalInput;
  final String foodName;
  final String quantityText;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final bool isEstimated;

  Map<String, dynamic> toJson() => {
        'originalInput': originalInput,
        'foodName': foodName,
        'quantityText': quantityText,
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'isEstimated': isEstimated,
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
    );
  }
}
