import '../../../core/utils/date_utils.dart';
import 'exercise_model.dart';
import 'workout_day_model.dart';

class ExerciseLog {
  const ExerciseLog({
    required this.exerciseId,
    required this.name,
    required this.type,
    required this.completed,
    this.plannedSets,
    this.plannedReps,
    this.weightKg,
    this.actualReps,
    this.durationMinutes,
    this.durationSeconds,
    this.intensity,
    this.note,
  });

  final String exerciseId;
  final String name;
  final ExerciseType type;
  final int? plannedSets;
  final String? plannedReps;
  final bool completed;
  final double? weightKg;
  final String? actualReps;
  final int? durationMinutes;
  final int? durationSeconds;
  final ExerciseIntensity? intensity;
  final String? note;

  ExerciseLog copyWith({
    String? exerciseId,
    String? name,
    ExerciseType? type,
    int? plannedSets,
    String? plannedReps,
    bool? completed,
    double? weightKg,
    bool clearWeightKg = false,
    String? actualReps,
    bool clearActualReps = false,
    int? durationMinutes,
    bool clearDurationMinutes = false,
    int? durationSeconds,
    bool clearDurationSeconds = false,
    ExerciseIntensity? intensity,
    bool clearIntensity = false,
    String? note,
    bool clearNote = false,
  }) {
    return ExerciseLog(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      type: type ?? this.type,
      plannedSets: plannedSets ?? this.plannedSets,
      plannedReps: plannedReps ?? this.plannedReps,
      completed: completed ?? this.completed,
      weightKg: clearWeightKg ? null : (weightKg ?? this.weightKg),
      actualReps: clearActualReps ? null : (actualReps ?? this.actualReps),
      durationMinutes:
          clearDurationMinutes ? null : (durationMinutes ?? this.durationMinutes),
      durationSeconds:
          clearDurationSeconds ? null : (durationSeconds ?? this.durationSeconds),
      intensity: clearIntensity ? null : (intensity ?? this.intensity),
      note: clearNote ? null : (note ?? this.note),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'type': type.name,
      'plannedSets': plannedSets,
      'plannedReps': plannedReps,
      'completed': completed,
      'weightKg': weightKg,
      'actualReps': actualReps,
      'durationMinutes': durationMinutes,
      'durationSeconds': durationSeconds,
      'intensity': intensity?.name,
      'note': note,
    };
  }

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    final intensityName = json['intensity'] as String?;
    final typeName = json['type'] as String?;

    return ExerciseLog(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      type: ExerciseType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => ExerciseType.strength,
      ),
      plannedSets: json['plannedSets'] as int?,
      plannedReps: json['plannedReps'] as String?,
      completed: json['completed'] as bool? ?? false,
      weightKg: ((json['weightKg'] ?? json['weight']) as num?)?.toDouble(),
      actualReps: json['actualReps'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      intensity: intensityName == null
          ? null
          : ExerciseIntensity.values.firstWhere(
              (value) => value.name == intensityName,
              orElse: () => ExerciseIntensity.medium,
            ),
      note: json['note'] as String?,
    );
  }
}

class WorkoutLog {
  const WorkoutLog({
    required this.id,
    required this.date,
    required this.workoutDayId,
    required this.exerciseLogs,
    required this.cardioCompleted,
    required this.cardioMinutes,
    required this.kneePain,
  });

  final String id;
  final DateTime date;
  final String workoutDayId;
  final List<ExerciseLog> exerciseLogs;
  final bool cardioCompleted;
  final int cardioMinutes;
  final bool kneePain;

  factory WorkoutLog.createForToday(WorkoutDay workoutDay) {
    final now = DateTime.now();

    return WorkoutLog(
      id: '${AppDateUtils.dateKey(now)}:${workoutDay.id}',
      date: now,
      workoutDayId: workoutDay.id,
      cardioCompleted: false,
      cardioMinutes: workoutDay.cardioMinutes,
      kneePain: false,
      exerciseLogs: workoutDay.exercises
          .map(
            (exercise) => ExerciseLog(
              exerciseId: exercise.id,
              name: exercise.name,
              type: exercise.type,
              plannedSets: exercise.sets,
              plannedReps: exercise.reps,
              completed: false,
              durationMinutes: exercise.targetDurationMinutes,
              durationSeconds: exercise.targetDurationSeconds,
            ),
          )
          .toList(),
    );
  }

  WorkoutLog copyWith({
    String? id,
    DateTime? date,
    String? workoutDayId,
    List<ExerciseLog>? exerciseLogs,
    bool? cardioCompleted,
    int? cardioMinutes,
    bool? kneePain,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      date: date ?? this.date,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      exerciseLogs: exerciseLogs ?? this.exerciseLogs,
      cardioCompleted: cardioCompleted ?? this.cardioCompleted,
      cardioMinutes: cardioMinutes ?? this.cardioMinutes,
      kneePain: kneePain ?? this.kneePain,
    );
  }

  WorkoutLog updateExercise(
    String exerciseId, {
    bool? completed,
    double? weightKg,
    bool clearWeightKg = false,
    String? actualReps,
    bool clearActualReps = false,
    int? durationMinutes,
    bool clearDurationMinutes = false,
    int? durationSeconds,
    bool clearDurationSeconds = false,
    ExerciseIntensity? intensity,
    bool clearIntensity = false,
    String? note,
    bool clearNote = false,
  }) {
    final updatedLogs = exerciseLogs
        .map(
          (log) => log.exerciseId == exerciseId
              ? log.copyWith(
                  completed: completed,
                  weightKg: weightKg,
                  clearWeightKg: clearWeightKg,
                  actualReps: actualReps,
                  clearActualReps: clearActualReps,
                  durationMinutes: durationMinutes,
                  clearDurationMinutes: clearDurationMinutes,
                  durationSeconds: durationSeconds,
                  clearDurationSeconds: clearDurationSeconds,
                  intensity: intensity,
                  clearIntensity: clearIntensity,
                  note: note,
                  clearNote: clearNote,
                )
              : log,
        )
        .toList();

    return copyWith(exerciseLogs: updatedLogs);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'workoutDayId': workoutDayId,
      'exerciseLogs': exerciseLogs.map((log) => log.toJson()).toList(),
      'cardioCompleted': cardioCompleted,
      'cardioMinutes': cardioMinutes,
      'kneePain': kneePain,
    };
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    final exerciseLogsJson = json['exerciseLogs'] as List<dynamic>? ?? <dynamic>[];

    return WorkoutLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      workoutDayId: json['workoutDayId'] as String,
      exerciseLogs: exerciseLogsJson
          .map((item) => ExerciseLog.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      cardioCompleted: json['cardioCompleted'] as bool? ?? false,
      cardioMinutes: json['cardioMinutes'] as int? ?? 0,
      kneePain: json['kneePain'] as bool? ?? false,
    );
  }
}
