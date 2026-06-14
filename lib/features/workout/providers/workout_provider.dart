import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../models/workout_log_model.dart';

final workoutLogProvider = AsyncNotifierProviderFamily<
    WorkoutLogNotifier, WorkoutLog, WorkoutDay>(
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

  Future<void> updateIntensity(String exerciseId, ExerciseIntensity? value) async {
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

  Future<void> _save(WorkoutLog updated) async {
    state = AsyncData(updated);
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveWorkoutLog(updated);
  }
}
