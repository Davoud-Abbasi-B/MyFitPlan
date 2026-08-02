import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class WorkoutTimerState {
  const WorkoutTimerState({
    this.selectedSeconds = 60,
    this.remainingSeconds = 60,
    this.isRunning = false,
    this.isComplete = false,
  });

  final int selectedSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isComplete;

  int get selectedMinutes => selectedSeconds ~/ 60;
  int get selectedSecondPart => selectedSeconds % 60;
  bool get canStart => selectedSeconds > 0 && !isRunning && !isComplete;
  bool get canStopOrReset => isRunning || isComplete;

  WorkoutTimerState copyWith({
    int? selectedSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? isComplete,
  }) {
    return WorkoutTimerState(
      selectedSeconds: selectedSeconds ?? this.selectedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

int workoutDurationInSeconds(int minutes, int seconds) {
  if (minutes < 0 || seconds < 0 || seconds > 59) {
    throw ArgumentError('Minutes must be positive and seconds must be 0–59.');
  }
  return minutes * 60 + seconds;
}

String formatWorkoutDuration(int totalSeconds) {
  final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
  final minutes = safeSeconds ~/ 60;
  final seconds = safeSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

final workoutTimerProvider =
    StateNotifierProvider<WorkoutTimerNotifier, WorkoutTimerState>(
  (ref) => WorkoutTimerNotifier(),
);

class WorkoutTimerNotifier extends StateNotifier<WorkoutTimerState> {
  WorkoutTimerNotifier({DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(const WorkoutTimerState());

  final DateTime Function() _now;
  Timer? _timer;
  DateTime? _endsAt;
  int _timerCreationCount = 0;

  @visibleForTesting
  int get timerCreationCount => _timerCreationCount;

  void setMinutes(int minutes) {
    if (state.isRunning || minutes < 0) return;
    _setSelectedDuration(minutes, state.selectedSecondPart);
  }

  void setSeconds(int seconds) {
    if (state.isRunning || seconds < 0 || seconds > 59) return;
    _setSelectedDuration(state.selectedMinutes, seconds);
  }

  void setDuration({required int minutes, required int seconds}) {
    if (state.isRunning || minutes < 0 || seconds < 0 || seconds > 59) {
      return;
    }
    _setSelectedDuration(minutes, seconds);
  }

  void _setSelectedDuration(int minutes, int seconds) {
    final total = workoutDurationInSeconds(minutes, seconds);
    state = WorkoutTimerState(
      selectedSeconds: total,
      remainingSeconds: total,
    );
  }

  void start() {
    if (!state.canStart || _timer != null) return;

    _endsAt = _now().add(Duration(seconds: state.selectedSeconds));
    state = state.copyWith(
      remainingSeconds: state.selectedSeconds,
      isRunning: true,
      isComplete: false,
    );
    _timerCreationCount++;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
  }

  @visibleForTesting
  void updateTime() {
    if (!state.isRunning || _endsAt == null) return;

    final milliseconds = _endsAt!.difference(_now()).inMilliseconds;
    final remaining = milliseconds <= 0 ? 0 : (milliseconds + 999) ~/ 1000;
    if (remaining == 0) {
      _timer?.cancel();
      _timer = null;
      _endsAt = null;
      state = state.copyWith(
        remainingSeconds: 0,
        isRunning: false,
        isComplete: true,
      );
      return;
    }

    if (remaining != state.remainingSeconds) {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  void stopAndReset() {
    if (!state.canStopOrReset) return;
    _timer?.cancel();
    _timer = null;
    _endsAt = null;
    state = WorkoutTimerState(
      selectedSeconds: state.selectedSeconds,
      remainingSeconds: state.selectedSeconds,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
