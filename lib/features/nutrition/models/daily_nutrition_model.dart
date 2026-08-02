import 'food_analysis_result.dart';

enum NutritionDayType { training, rest }

class DailyNutritionEntry {
  const DailyNutritionEntry({
    required this.id,
    required this.dateKey,
    required this.createdAt,
    required this.originalInput,
    required this.foodName,
    required this.quantityText,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.isEstimated,
  });

  final String id;
  final String dateKey;
  final DateTime createdAt;
  final String originalInput;
  final String foodName;
  final String quantityText;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final bool isEstimated;

  factory DailyNutritionEntry.fromAnalysis({
    required FoodAnalysisResult result,
    required String dateKey,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    return DailyNutritionEntry(
      id: 'food-${timestamp.microsecondsSinceEpoch}',
      dateKey: dateKey,
      createdAt: timestamp,
      originalInput: result.originalInput,
      foodName: result.foodName,
      quantityText: result.quantityText,
      calories: result.calories,
      proteinGrams: result.proteinGrams,
      carbsGrams: result.carbsGrams,
      fatGrams: result.fatGrams,
      isEstimated: result.isEstimated,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateKey': dateKey,
        'createdAt': createdAt.toIso8601String(),
        'originalInput': originalInput,
        'foodName': foodName,
        'quantityText': quantityText,
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'isEstimated': isEstimated,
      };

  factory DailyNutritionEntry.fromJson(Map<String, dynamic> json) {
    return DailyNutritionEntry(
      id: json['id'] as String? ?? '',
      dateKey: json['dateKey'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
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

class DailyNutritionTotals {
  const DailyNutritionTotals({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  const DailyNutritionTotals.zero()
      : calories = 0,
        proteinGrams = 0,
        carbsGrams = 0,
        fatGrams = 0;

  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  factory DailyNutritionTotals.fromEntries(
    Iterable<DailyNutritionEntry> entries,
  ) {
    var calories = 0.0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    for (final entry in entries) {
      calories += entry.calories;
      protein += entry.proteinGrams;
      carbs += entry.carbsGrams;
      fat += entry.fatGrams;
    }
    return DailyNutritionTotals(
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
    );
  }
}

class DailyNutritionReport {
  const DailyNutritionReport({
    required this.dateKey,
    required this.submittedAt,
    required this.entries,
    required this.totalCalories,
    required this.totalProteinGrams,
    required this.totalCarbsGrams,
    required this.totalFatGrams,
    required this.dayType,
  });

  final String dateKey;
  final DateTime submittedAt;
  final List<DailyNutritionEntry> entries;
  final double totalCalories;
  final double totalProteinGrams;
  final double totalCarbsGrams;
  final double totalFatGrams;
  final NutritionDayType dayType;

  factory DailyNutritionReport.fromEntries({
    required String dateKey,
    required List<DailyNutritionEntry> entries,
    required NutritionDayType dayType,
    DateTime? submittedAt,
  }) {
    final totals = DailyNutritionTotals.fromEntries(entries);
    return DailyNutritionReport(
      dateKey: dateKey,
      submittedAt: submittedAt ?? DateTime.now(),
      entries: List.unmodifiable(entries),
      totalCalories: totals.calories,
      totalProteinGrams: totals.proteinGrams,
      totalCarbsGrams: totals.carbsGrams,
      totalFatGrams: totals.fatGrams,
      dayType: dayType,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'submittedAt': submittedAt.toIso8601String(),
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'totalCalories': totalCalories,
        'totalProteinGrams': totalProteinGrams,
        'totalCarbsGrams': totalCarbsGrams,
        'totalFatGrams': totalFatGrams,
        'dayType': dayType.name,
      };

  factory DailyNutritionReport.fromJson(Map<String, dynamic> json) {
    final entryJson = json['entries'] as List<dynamic>? ?? const [];
    return DailyNutritionReport(
      dateKey: json['dateKey'] as String? ?? '',
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ??
          DateTime.now(),
      entries: entryJson
          .whereType<Map>()
          .map((entry) => DailyNutritionEntry.fromJson(
                Map<String, dynamic>.from(entry),
              ))
          .toList(growable: false),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProteinGrams: (json['totalProteinGrams'] as num?)?.toDouble() ?? 0,
      totalCarbsGrams: (json['totalCarbsGrams'] as num?)?.toDouble() ?? 0,
      totalFatGrams: (json['totalFatGrams'] as num?)?.toDouble() ?? 0,
      dayType: NutritionDayType.values.firstWhere(
        (value) => value.name == json['dayType'],
        orElse: () => NutritionDayType.rest,
      ),
    );
  }
}

String nutritionDateKey(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}

bool canSubmitNutritionReport(
  Iterable<DailyNutritionReport> reports,
  String dateKey,
) {
  return !reports.any((report) => report.dateKey == dateKey);
}
