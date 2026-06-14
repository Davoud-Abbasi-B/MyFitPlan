class DailyChecklist {
  const DailyChecklist({
    required this.id,
    required this.date,
    required this.workoutDone,
    required this.enoughProtein,
    required this.healthySnack,
    required this.noSugaryDrink,
    required this.supplementsDone,
    required this.stepsDone,
    required this.enoughWater,
    required this.cravingControlled,
  });

  final String id;
  final DateTime date;
  final bool workoutDone;
  final bool enoughProtein;
  final bool healthySnack;
  final bool noSugaryDrink;
  final bool supplementsDone;
  final bool stepsDone;
  final bool enoughWater;
  final bool cravingControlled;

  DailyChecklist copyWith({
    String? id,
    DateTime? date,
    bool? workoutDone,
    bool? enoughProtein,
    bool? healthySnack,
    bool? noSugaryDrink,
    bool? supplementsDone,
    bool? stepsDone,
    bool? enoughWater,
    bool? cravingControlled,
  }) {
    return DailyChecklist(
      id: id ?? this.id,
      date: date ?? this.date,
      workoutDone: workoutDone ?? this.workoutDone,
      enoughProtein: enoughProtein ?? this.enoughProtein,
      healthySnack: healthySnack ?? this.healthySnack,
      noSugaryDrink: noSugaryDrink ?? this.noSugaryDrink,
      supplementsDone: supplementsDone ?? this.supplementsDone,
      stepsDone: stepsDone ?? this.stepsDone,
      enoughWater: enoughWater ?? this.enoughWater,
      cravingControlled: cravingControlled ?? this.cravingControlled,
    );
  }

  int get score {
    var total = 0;
    if (workoutDone) total += 20;
    if (enoughProtein) total += 15;
    if (healthySnack) total += 15;
    if (noSugaryDrink) total += 10;
    if (supplementsDone) total += 10;
    if (stepsDone) total += 10;
    if (enoughWater) total += 10;
    if (cravingControlled) total += 10;
    return total;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'workoutDone': workoutDone,
      'enoughProtein': enoughProtein,
      'healthySnack': healthySnack,
      'noSugaryDrink': noSugaryDrink,
      'supplementsDone': supplementsDone,
      'stepsDone': stepsDone,
      'enoughWater': enoughWater,
      'cravingControlled': cravingControlled,
    };
  }

  factory DailyChecklist.fromJson(Map<String, dynamic> json) {
    return DailyChecklist(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      workoutDone: json['workoutDone'] as bool? ?? false,
      enoughProtein: json['enoughProtein'] as bool? ?? false,
      healthySnack: json['healthySnack'] as bool? ?? false,
      noSugaryDrink: json['noSugaryDrink'] as bool? ?? false,
      supplementsDone: json['supplementsDone'] as bool? ?? false,
      stepsDone: json['stepsDone'] as bool? ?? false,
      enoughWater: json['enoughWater'] as bool? ?? false,
      cravingControlled: json['cravingControlled'] as bool? ?? false,
    );
  }
}

enum ChecklistItemKey {
  workoutDone,
  enoughProtein,
  healthySnack,
  noSugaryDrink,
  supplementsDone,
  stepsDone,
  enoughWater,
  cravingControlled,
}

extension DailyChecklistItems on DailyChecklist {
  bool valueFor(ChecklistItemKey key) {
    switch (key) {
      case ChecklistItemKey.workoutDone:
        return workoutDone;
      case ChecklistItemKey.enoughProtein:
        return enoughProtein;
      case ChecklistItemKey.healthySnack:
        return healthySnack;
      case ChecklistItemKey.noSugaryDrink:
        return noSugaryDrink;
      case ChecklistItemKey.supplementsDone:
        return supplementsDone;
      case ChecklistItemKey.stepsDone:
        return stepsDone;
      case ChecklistItemKey.enoughWater:
        return enoughWater;
      case ChecklistItemKey.cravingControlled:
        return cravingControlled;
    }
  }

  DailyChecklist withValue(ChecklistItemKey key, bool value) {
    switch (key) {
      case ChecklistItemKey.workoutDone:
        return copyWith(workoutDone: value);
      case ChecklistItemKey.enoughProtein:
        return copyWith(enoughProtein: value);
      case ChecklistItemKey.healthySnack:
        return copyWith(healthySnack: value);
      case ChecklistItemKey.noSugaryDrink:
        return copyWith(noSugaryDrink: value);
      case ChecklistItemKey.supplementsDone:
        return copyWith(supplementsDone: value);
      case ChecklistItemKey.stepsDone:
        return copyWith(stepsDone: value);
      case ChecklistItemKey.enoughWater:
        return copyWith(enoughWater: value);
      case ChecklistItemKey.cravingControlled:
        return copyWith(cravingControlled: value);
    }
  }
}
