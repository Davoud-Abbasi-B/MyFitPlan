import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../models/workout_log_model.dart';
import '../models/workout_session_model.dart';

enum WorkoutSubmissionResult { submitted, duplicate, incomplete }

final workoutHistoryProvider =
    AsyncNotifierProvider<WorkoutHistoryNotifier, List<WorkoutSession>>(
  WorkoutHistoryNotifier.new,
);

class WorkoutHistoryNotifier extends AsyncNotifier<List<WorkoutSession>> {
  @override
  Future<List<WorkoutSession>> build() {
    return ref.watch(localStorageServiceProvider).loadWorkoutSessions();
  }

  Future<void> deleteSession(String sessionId) async {
    await ref.read(localStorageServiceProvider).deleteWorkoutSession(sessionId);
    state = AsyncData(
        await ref.read(localStorageServiceProvider).loadWorkoutSessions());
  }
}

final workoutLogProvider =
    AsyncNotifierProviderFamily<WorkoutLogNotifier, WorkoutLog, WorkoutDay>(
  WorkoutLogNotifier.new,
);

class WorkoutLogNotifier extends FamilyAsyncNotifier<WorkoutLog, WorkoutDay> {
  @override
  Future<WorkoutLog> build(WorkoutDay arg) async {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.loadWorkoutLogForToday(arg);
  }

  Future<void> toggleExercise(String exerciseId, bool value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _save(current.updateExercise(exerciseId, completed: value));
  }

  Future<void> updateWeight(String exerciseId, String value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final parsed = double.tryParse(value.trim());
    await _save(
      current.updateExercise(
        exerciseId,
        weightKg: parsed,
        clearWeightKg: value.trim().isEmpty,
      ),
    );
  }

  Future<void> updateActualReps(String exerciseId, String value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _save(
      current.updateExercise(
        exerciseId,
        actualReps: value.trim(),
        clearActualReps: value.trim().isEmpty,
      ),
    );
  }

  Future<void> updateDurationMinutes(String exerciseId, String value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final parsed = int.tryParse(value.trim());
    await _save(
      current.updateExercise(
        exerciseId,
        durationMinutes: parsed,
        clearDurationMinutes: value.trim().isEmpty,
      ),
    );
  }

  Future<void> updateDurationSeconds(String exerciseId, String value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final parsed = int.tryParse(value.trim());
    await _save(
      current.updateExercise(
        exerciseId,
        durationSeconds: parsed,
        clearDurationSeconds: value.trim().isEmpty,
      ),
    );
  }

  Future<void> updateIntensity(
      String exerciseId, ExerciseIntensity? value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _save(
      current.updateExercise(
        exerciseId,
        intensity: value,
        clearIntensity: value == null,
      ),
    );
  }

  Future<void> updateNote(String exerciseId, String value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _save(
      current.updateExercise(
        exerciseId,
        note: value.trim(),
        clearNote: value.trim().isEmpty,
      ),
    );
  }

  Future<void> setCardioCompleted(bool value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _save(current.copyWith(cardioCompleted: value));
  }

  Future<void> updateCardioMinutes(String value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final parsed = int.tryParse(value.trim()) ?? 0;
    await _save(current.copyWith(cardioMinutes: parsed));
  }

  Future<void> setKneePain(bool value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _save(current.copyWith(kneePain: value));
  }

  Future<WorkoutSubmissionResult> submitSession() async {
    final current = state.valueOrNull;
    if (current == null) return WorkoutSubmissionResult.incomplete;

    final completedById = {
      for (final log in current.exerciseLogs) log.exerciseId: log.completed,
    };
    final allRequiredCompleted = arg.exercises
        .where((exercise) => !exercise.isOptional)
        .every((exercise) => completedById[exercise.id] ?? false);
    if (!allRequiredCompleted) return WorkoutSubmissionResult.incomplete;

    final session = WorkoutSession.fromDraft(
      workoutDay: arg,
      draft: current,
    );
    final saved =
        await ref.read(localStorageServiceProvider).saveWorkoutSession(session);
    if (!saved) return WorkoutSubmissionResult.duplicate;

    ref.invalidate(workoutHistoryProvider);
    return WorkoutSubmissionResult.submitted;
  }

  Future<void> _save(WorkoutLog updated) async {
    state = AsyncData(updated);
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveWorkoutLog(updated);
  }
}
