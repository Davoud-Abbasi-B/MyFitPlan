class NutritionLog {
  const NutritionLog({
    required this.date,
    required this.completedMealIds,
    this.selectedSnackOption,
  });

  final DateTime date;
  final List<String> completedMealIds;
  final String? selectedSnackOption;

  NutritionLog copyWith({
    DateTime? date,
    List<String>? completedMealIds,
    String? selectedSnackOption,
    bool clearSelectedSnackOption = false,
  }) {
    return NutritionLog(
      date: date ?? this.date,
      completedMealIds: completedMealIds ?? this.completedMealIds,
      selectedSnackOption: clearSelectedSnackOption
          ? null
          : (selectedSnackOption ?? this.selectedSnackOption),
    );
  }

  bool isMealCompleted(String mealId) => completedMealIds.contains(mealId);

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'completedMealIds': completedMealIds,
      'selectedSnackOption': selectedSnackOption,
    };
  }

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      date: DateTime.parse(json['date'] as String),
      completedMealIds: (json['completedMealIds'] as List<dynamic>? ?? <dynamic>[])
          .cast<String>(),
      selectedSnackOption: json['selectedSnackOption'] as String?,
    );
  }
}
