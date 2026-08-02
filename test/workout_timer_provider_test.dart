import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_fit_plan/features/workout/providers/workout_timer_provider.dart';

void main() {
  test('converts minutes and seconds and formats MM:SS', () {
    expect(workoutDurationInSeconds(2, 5), 125);
    expect(formatWorkoutDuration(125), '02:05');
    expect(formatWorkoutDuration(-1), '00:00');
  });

  test('rejects seconds outside 0 to 59', () {
    expect(() => workoutDurationInSeconds(0, 60), throwsArgumentError);
    expect(() => workoutDurationInSeconds(0, -1), throwsArgumentError);

    final timer = WorkoutTimerNotifier();
    addTearDown(timer.dispose);
    timer.setSeconds(60);
    expect(timer.state.selectedSeconds, 60);
  });

  test('countdown reaches zero and stop/reset restores selection', () {
    var now = DateTime(2026);
    final timer = WorkoutTimerNotifier(now: () => now);
    addTearDown(timer.dispose);

    timer.setDuration(minutes: 0, seconds: 2);
    timer.start();
    now = now.add(const Duration(seconds: 2));
    timer.updateTime();

    expect(timer.state.remainingSeconds, 0);
    expect(timer.state.isComplete, isTrue);
    expect(timer.state.isRunning, isFalse);

    timer.stopAndReset();
    expect(timer.state.remainingSeconds, 2);
    expect(timer.state.isComplete, isFalse);
  });

  test('rapid starts create only one periodic timer', () {
    final timer = WorkoutTimerNotifier();
    addTearDown(timer.dispose);

    timer.start();
    timer.start();
    timer.start();

    expect(timer.timerCreationCount, 1);
  });

  test('provider keeps the same running timer across reads and rebuilds', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timer = container.read(workoutTimerProvider.notifier);
    timer.start();
    container.read(workoutTimerProvider);
    container.read(workoutTimerProvider);

    expect(container.read(workoutTimerProvider).isRunning, isTrue);
    expect(identical(timer, container.read(workoutTimerProvider.notifier)),
        isTrue);
    expect(timer.timerCreationCount, 1);
  });
}
