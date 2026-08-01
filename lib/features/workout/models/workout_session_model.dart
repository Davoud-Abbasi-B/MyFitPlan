import '../../../core/utils/date_utils.dart';
import 'workout_day_model.dart';
import 'workout_log_model.dart';

class WorkoutExerciseRecord {
  const WorkoutExerciseRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.plannedSets,
    required this.completed,
    this.plannedReps,
    this.targetRirText,
    this.restText,
    this.weightKg,
    this.actualReps,
    this.durationMinutes,
    this.durationSeconds,
    this.note,
  });

  final String exerciseId;
  final String exerciseName;
  final int plannedSets;
  final String? plannedReps;
  final String? targetRirText;
  final String? restText;
  final bool completed;
  final double? weightKg;
  final String? actualReps;
  final int? durationMinutes;
  final int? durationSeconds;
  final String? note;

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'plannedSets': plannedSets,
        'plannedReps': plannedReps,
        'targetRirText': targetRirText,
        'restText': restText,
        'completed': completed,
        'weightKg': weightKg,
        'actualReps': actualReps,
        'durationMinutes': durationMinutes,
        'durationSeconds': durationSeconds,
        'note': note,
      };

  factory WorkoutExerciseRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseRecord(
      exerciseId: json['exerciseId'] as String? ??
          json['stableExerciseKey'] as String? ??
          '',
      exerciseName:
          json['exerciseName'] as String? ?? json['name'] as String? ?? '',
      plannedSets: json['plannedSets'] as int? ?? 0,
      plannedReps: json['plannedReps'] as String?,
      targetRirText: json['targetRirText'] as String?,
      restText: json['restText'] as String?,
      completed: json['completed'] as bool? ?? false,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      actualReps: json['actualReps'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      note: json['note'] as String?,
    );
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.dateKey,
    required this.completedAt,
    required this.workoutDayNumber,
    required this.workoutTitle,
    required this.workoutFocus,
    required this.exercises,
    this.sessionNote,
  });

  final String id;
  final String dateKey;
  final DateTime completedAt;
  final int workoutDayNumber;
  final String workoutTitle;
  final String workoutFocus;
  final List<WorkoutExerciseRecord> exercises;
  final String? sessionNote;

  int get completedExerciseCount =>
      exercises.where((exercise) => exercise.completed).length;

  factory WorkoutSession.fromDraft({
    required WorkoutDay workoutDay,
    required WorkoutLog draft,
    DateTime? completedAt,
  }) {
    final timestamp = completedAt ?? DateTime.now();
    final dateKey = _machineDateKey(timestamp);
    final logsById = {
      for (final exerciseLog in draft.exerciseLogs)
        exerciseLog.exerciseId: exerciseLog,
    };

    return WorkoutSession(
      id: '$dateKey-day-${workoutDay.dayNumber}',
      dateKey: dateKey,
      completedAt: timestamp,
      workoutDayNumber: workoutDay.dayNumber,
      workoutTitle: workoutDay.title,
      workoutFocus: workoutDay.focus,
      exercises: workoutDay.exercises.map((exercise) {
        final log = logsById[exercise.id];
        return WorkoutExerciseRecord(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          plannedSets: exercise.sets ?? 0,
          plannedReps: exercise.reps,
          targetRirText: exercise.targetRirText,
          restText: exercise.restText,
          completed: log?.completed ?? false,
          weightKg: log?.weightKg,
          actualReps: log?.actualReps,
          durationMinutes: log?.durationMinutes,
          durationSeconds: log?.durationSeconds,
          note: log?.note,
        );
      }).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateKey': dateKey,
        'completedAt': completedAt.toIso8601String(),
        'workoutDayNumber': workoutDayNumber,
        'workoutTitle': workoutTitle,
        'workoutFocus': workoutFocus,
        'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
        'sessionNote': sessionNote,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    final completedAtText = json['completedAt'] as String?;
    final fallbackDate = json['date'] as String?;
    final completedAt =
        DateTime.tryParse(completedAtText ?? fallbackDate ?? '') ??
            DateTime.now();
    final exerciseJson = json['exercises'] as List<dynamic>? ?? const [];
    final storedDateKey = json['dateKey'] as String?;
    final normalizedDateKey =
        storedDateKey != null && storedDateKey.length >= 10
            ? storedDateKey.substring(0, 10)
            : _machineDateKey(completedAt);

    return WorkoutSession(
      id: json['id'] as String? ??
          '${_machineDateKey(completedAt)}-day-${json['workoutDayNumber'] ?? 0}',
      dateKey: normalizedDateKey,
      completedAt: completedAt,
      workoutDayNumber: json['workoutDayNumber'] as int? ?? 0,
      workoutTitle: json['workoutTitle'] as String? ?? '',
      workoutFocus: json['workoutFocus'] as String? ?? '',
      exercises: exerciseJson
          .whereType<Map>()
          .map((item) => WorkoutExerciseRecord.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false),
      sessionNote: json['sessionNote'] as String?,
    );
  }

  String get jalaliDate => AppDateUtils.formatJalaliNumeric(completedAt);
}

String _machineDateKey(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
}
