enum ExerciseType {
  strength,
  cardio,
  bodyweight,
}

enum ExerciseIntensity {
  light,
  medium,
  heavy,
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.type,
    required this.notes,
    this.sets,
    this.reps,
    this.defaultWeightKg,
    this.targetDurationMinutes,
    this.targetDurationSeconds,
    this.targetRirText,
    this.restText,
    this.guideText,
    this.instructionText,
    this.targetMuscles = const [],
    this.secondaryMuscles = const [],
    this.keyTips = const [],
    this.alternativeText,
    this.safetyTip,
    this.imageAssetPath,
    this.isCompleted = false,
    this.weight,
  });

  final String id;
  final String name;
  final ExerciseType type;
  final int? sets;
  final String? reps;
  final String notes;
  final bool isCompleted;
  final double? weight;
  final double? defaultWeightKg;
  final int? targetDurationMinutes;
  final int? targetDurationSeconds;
  final String? targetRirText;
  final String? restText;
  final String? guideText;
  final String? instructionText;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> keyTips;
  final String? alternativeText;
  final String? safetyTip;
  final String? imageAssetPath;

  bool get supportsWeight => type == ExerciseType.strength;
  bool get supportsDurationMinutes => type == ExerciseType.cardio;
  bool get supportsDurationSeconds =>
      type == ExerciseType.bodyweight && targetDurationSeconds != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'sets': sets,
      'reps': reps,
      'notes': notes,
      'isCompleted': isCompleted,
      'weight': weight,
      'defaultWeightKg': defaultWeightKg,
      'targetDurationMinutes': targetDurationMinutes,
      'targetDurationSeconds': targetDurationSeconds,
      'targetRirText': targetRirText,
      'restText': restText,
      'guideText': guideText,
      'instructionText': instructionText,
      'targetMuscles': targetMuscles,
      'secondaryMuscles': secondaryMuscles,
      'keyTips': keyTips,
      'alternativeText': alternativeText,
      'safetyTip': safetyTip,
      'imageAssetPath': imageAssetPath,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    final legacySafetyTip = json['safetyTip'] as String?;

    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _exerciseTypeFromName(typeName, json),
      sets: json['sets'] as int?,
      reps: json['reps'] as String?,
      notes: json['notes'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      weight: (json['weight'] as num?)?.toDouble(),
      defaultWeightKg: (json['defaultWeightKg'] as num?)?.toDouble(),
      targetDurationMinutes: json['targetDurationMinutes'] as int?,
      targetDurationSeconds: json['targetDurationSeconds'] as int?,
      targetRirText: json['targetRirText'] as String?,
      restText: json['restText'] as String?,
      guideText: json['guideText'] as String?,
      instructionText:
          json['instructionText'] as String? ?? json['guideText'] as String?,
      targetMuscles: (json['targetMuscles'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      keyTips: (json['keyTips'] as List<dynamic>? ?? const [])
          .map((item) => item as String)
          .toList(),
      alternativeText: json['alternativeText'] as String?,
      safetyTip: legacySafetyTip,
      imageAssetPath: json['imageAssetPath'] as String?,
    );
  }

  static ExerciseType _exerciseTypeFromName(
    String? typeName,
    Map<String, dynamic> json,
  ) {
    if (typeName != null) {
      return ExerciseType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => ExerciseType.strength,
      );
    }

    final reps = json['reps'] as String?;
    if (reps != null && reps.contains('دقیقه')) {
      return ExerciseType.cardio;
    }

    return ExerciseType.strength;
  }
}
