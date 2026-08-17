import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:my_fit_plan/data/local/default_seed_data.dart';
import 'package:my_fit_plan/data/local/local_storage_service.dart';
import 'package:my_fit_plan/data/local/storage_keys.dart';
import 'package:my_fit_plan/features/workout/models/exercise_model.dart';
import 'package:my_fit_plan/features/workout/models/workout_day_model.dart';

void main() {
  group('four-day hypertrophy program', () {
    final workouts = DefaultSeedData.workouts();

    test('contains exactly four resistance-training sessions', () {
      expect(workouts, hasLength(4));
      expect(workouts.every((day) => day.isGymWorkout), isTrue);
      expect(workouts.map((day) => day.dayNumber), [1, 2, 4, 5]);
      expect(workouts.map((day) => day.title), [
        'Day 1: Lower Body A',
        'Day 2: Upper Body A',
        'Day 4: Lower Body B',
        'Day 5: Upper Body B',
      ]);
    });

    test('uses the prescribed exercise order and repetition ranges', () {
      _expectPlan(workouts[0], const [
        ('Smith Squat', '6-10'),
        ('Leg Press', '8-12'),
        ('Leg Extension', '10-15'),
        ('Seated Leg Curl', '10-15'),
        ('Standing Calf Raise', '10-15'),
        ('Cable Crunch', '8-15'),
      ]);
      _expectPlan(workouts[1], const [
        ('Machine Chest Press', '6-10'),
        ('Incline Dumbbell Press', '8-12'),
        ('Seated Row', '8-12'),
        ('Cable Fly', '12-15'),
        ('Lat Pulldown', '10-12'),
        ('Overhead Cable Triceps Extension', '10-15'),
        ('Lateral Raise', '12-20'),
        ('Plank', '45-60 seconds'),
      ]);
      _expectPlan(workouts[2], const [
        ('Romanian Deadlift', '6-10'),
        ('Hip Thrust', '8-12'),
        ('Reverse Lunge', '8-12 per leg'),
        ('Seated Leg Curl', '10-15'),
        ('Leg Extension', '12-20'),
        ('Seated Calf Raise', '12-20'),
        ('Reverse Crunch', '10-20'),
        ('Pallof Press', '10-15 per side'),
      ]);
      _expectPlan(workouts[3], const [
        ('Assisted Pull-up', '6-10'),
        ('Single-Arm Cable Row', '8-12 per side'),
        ('Dumbbell Shoulder Press', '6-10'),
        ('Machine Chest Press', '10-15'),
        ('Lateral Raise', '12-20'),
        ('Rear Delt Fly', '12-20'),
        ('Bayesian Cable Curl', '10-15'),
        ('Rope Triceps Pushdown', '10-15'),
        ('Farmer Carry', '30-60 seconds'),
        ('Ab Wheel', '6-12'),
      ]);
    });

    test('uses three sets, unique IDs, and parseable guidance metadata', () {
      final exercises = workouts.expand((day) => day.exercises).toList();
      final resistance = exercises
          .where((exercise) => exercise.type != ExerciseType.cardio)
          .toList();
      final parsed = workouts.map((day) => WorkoutDay.fromJson(day.toJson()));

      expect(resistance.every((exercise) => exercise.sets == 3), isTrue);
      expect(exercises.map((exercise) => exercise.id).toSet(),
          hasLength(exercises.length));
      expect(
          parsed
              .expand((day) => day.exercises)
              .where((exercise) => exercise.type != ExerciseType.cardio)
              .every((exercise) =>
                  exercise.notes.isNotEmpty &&
                  exercise.targetRirText != null &&
                  exercise.restText != null),
          isTrue);
    });

    test('direct weekly set totals match the program classification', () {
      final totals = <String, int>{};
      for (final exercise in workouts
          .expand((day) => day.exercises)
          .where((exercise) => exercise.type != ExerciseType.cardio)) {
        totals.update(exercise.targetMuscles.single,
            (sets) => sets + (exercise.sets ?? 0),
            ifAbsent: () => exercise.sets ?? 0);
      }
      expect(totals, {
        'چهارسر ران': 12,
        'همسترینگ': 9,
        'سرینی': 6,
        'ساق': 6,
        'شکم و میان‌تنه': 15,
        'سینه': 12,
        'پشت و لت': 12,
        'پشت بازو': 6,
        'سرشانه': 12,
        'جلو بازو': 3,
        'گریپ و ساعد': 3,
      });
    });
  });

  test('template migration preserves unrelated and historical data', () async {
    final directory = await Directory.systemTemp.createTemp('fitora-workout-');
    Hive.init(directory.path);
    final box = await Hive.openBox<dynamic>('workout-migration-test');
    addTearDown(() async {
      await box.close();
      await directory.delete(recursive: true);
    });

    const sentinels = <String, dynamic>{
      StorageKeys.profile: {'name': 'preserve-profile'},
      StorageKeys.dailyNutritionDrafts: {'calories': 2100},
      StorageKeys.progress: [
        {'weightKg': 84.0}
      ],
      StorageKeys.workoutSessions: [
        {'id': 'historical-session'}
      ],
      StorageKeys.workoutLogs: {'historical-log': true},
    };
    for (final entry in sentinels.entries) {
      await box.put(entry.key, entry.value);
    }
    await box.put(StorageKeys.workouts, const <dynamic>[]);
    await box.put(StorageKeys.workoutSeedVersion, 4);

    await LocalStorageService.forTesting(box).ensureWorkoutPlanCurrent();

    for (final entry in sentinels.entries) {
      expect(box.get(entry.key), entry.value);
    }
    expect(box.get(StorageKeys.workoutSeedVersion),
        DefaultSeedData.workoutSeedVersion);
    expect(box.get(StorageKeys.workouts), hasLength(4));
  });
}

void _expectPlan(WorkoutDay day, List<(String, String)> expected) {
  final actual = day.exercises
      .where((exercise) => exercise.type != ExerciseType.cardio)
      .map((exercise) => (exercise.name, exercise.reps))
      .toList();
  expect(actual, expected);
}
