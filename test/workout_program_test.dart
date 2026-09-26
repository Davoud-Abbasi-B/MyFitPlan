import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:my_fit_plan/data/local/default_seed_data.dart';
import 'package:my_fit_plan/data/local/local_storage_service.dart';
import 'package:my_fit_plan/data/local/storage_keys.dart';
import 'package:my_fit_plan/features/workout/models/workout_day_model.dart';

void main() {
  group('four-week upper-body specialization program', () {
    final workouts = DefaultSeedData.workouts();

    test('contains exactly the four scheduled resistance sessions', () {
      expect(DefaultSeedData.workoutSeedVersion, 7);
      expect(workouts, hasLength(4));
      expect(workouts.every((day) => day.isGymWorkout), isTrue);
      expect(workouts.map((day) => day.dayNumber), [1, 2, 4, 6]);
      expect(workouts.map((day) => day.title),
          ['Upper A', 'Upper B', 'Lower', 'Upper C']);
    });

    test('uses the exact exercise order and repetition ranges', () {
      _expectPlan(workouts[0], const [
        ('Machine Chest Press', '6-10'),
        ('Incline Dumbbell Press', '8-12'),
        ('Flat Dumbbell Press', '8-12'),
        ('Cable Fly', '12-15'),
        ('Overhead Cable Triceps Extension', '10-15'),
        ('Rope Triceps Pushdown', '10-15'),
        ('Cable Crunch', '10-15'),
      ]);
      _expectPlan(workouts[1], const [
        ('Pull-up / Assisted Pull-up', '6-10'),
        ('Chest-Supported Row', '8-12'),
        ('Single-Arm Cable Row', '10-12 per side'),
        ('Face Pull', '12-20'),
        ('Incline Dumbbell Curl', '10-15'),
        ('Preacher Curl', '8-12'),
        ('Hammer Curl', '10-15'),
        ('Reverse Curl', '10-15'),
        ('Hanging Knee Raise', '10-15'),
      ]);
      _expectPlan(workouts[2], const [
        ('Smith Squat', '6-10'),
        ('Leg Press', '8-12'),
        ('Romanian Deadlift', '8-10'),
        ('Seated Leg Curl', '10-15'),
        ('Hip Thrust', '8-12'),
        ('Leg Extension', '12-15'),
        ('Standing Calf Raise', '12-20'),
        ('Reverse Crunch', '12-20'),
      ]);
      _expectPlan(workouts[3], const [
        ('Machine Shoulder Press', '6-10'),
        ('Dumbbell Lateral Raise', '12-15'),
        ('Rear Delt Fly', '12-15'),
        ('Dumbbell Shrug', '10-15'),
        ('Incline Dumbbell Press', '8-12'),
        ('Low-to-High Cable Fly', '12-15'),
        ('Cable Curl', '10-15'),
        ('Rope Triceps Pushdown', '10-15'),
        ('Ab Wheel', '6-12'),
      ]);
    });

    test('uses exact sets, RIR and rest prescriptions', () {
      const expected = <String, List<(String, String)>>{
        'Upper A': [
          ('2', '2-3 minutes'),
          ('1-2', '2 minutes'),
          ('1-2', '2 minutes'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60 seconds'),
        ],
        'Upper B': [
          ('1-2', '2-3 minutes'),
          ('1-2', '2 minutes'),
          ('1-2', '90-120 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60 seconds'),
        ],
        'Lower': [
          ('2', '2-3 minutes'),
          ('1-2', '2-3 minutes'),
          ('2', '2-3 minutes'),
          ('1-2', '90-120 seconds'),
          ('1-2', '2 minutes'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60 seconds'),
        ],
        'Upper C': [
          ('2', '2-3 minutes'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '2 minutes'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('1-2', '60-90 seconds'),
          ('2', '60-90 seconds'),
        ],
      };

      for (final day in workouts) {
        expect(
          day.exercises.every(
            (exercise) =>
                exercise.sets ==
                (exercise.name == 'Dumbbell Lateral Raise' ? 4 : 3),
          ),
          isTrue,
        );
        expect(
          day.exercises
              .map((exercise) => (exercise.targetRirText!, exercise.restText!)),
          expected[day.title],
        );
      }
    });

    test('excludes retired active movements and includes new movements', () {
      final names = workouts
          .expand((day) => day.exercises)
          .map((exercise) => exercise.name)
          .toSet();

      expect(names, isNot(contains('Farmer Carry')));
      expect(names, isNot(contains('Pallof Press')));
      expect(names, isNot(contains('Plank')));
      expect(names, isNot(contains('Cable Lateral Raise')));
      expect(
          names,
          containsAll([
            'Flat Dumbbell Press',
            'Hanging Knee Raise',
            'Dumbbell Shrug',
            'Low-to-High Cable Fly',
          ]));
    });

    test('uses unique stable IDs and round-trips all guidance metadata', () {
      final exercises = workouts.expand((day) => day.exercises).toList();
      final parsed = workouts.map((day) => WorkoutDay.fromJson(day.toJson()));

      expect(exercises.map((exercise) => exercise.id).toSet(),
          hasLength(exercises.length));
      expect(
          parsed.expand((day) => day.exercises).every((exercise) =>
              exercise.notes.isNotEmpty &&
              exercise.targetRirText != null &&
              exercise.restText != null),
          isTrue);
      expect(
        workouts[3]
            .exercises
            .firstWhere((exercise) => exercise.name == 'Dumbbell Shrug')
            .id,
        'upper-c-dumbbell-shrug',
      );
      expect(
        workouts[1].exercises.first.name,
        'Pull-up / Assisted Pull-up',
      );
      expect(workouts[1].exercises.first.alternativeText, 'Lat Pulldown');
      expect(
        workouts[3]
            .exercises
            .firstWhere((exercise) => exercise.name == 'Dumbbell Shrug')
            .alternativeText,
        'Barbell Shrug',
      );
      expect(
        workouts[3]
            .exercises
            .firstWhere(
              (exercise) => exercise.name == 'Dumbbell Lateral Raise',
            )
            .sets,
        4,
      );
      expect(
        workouts[3].exercises.where((exercise) => exercise.name == 'Face Pull'),
        isEmpty,
      );
      expect(
          workouts[3]
              .exercises
              .firstWhere(
                  (exercise) => exercise.name == 'Low-to-High Cable Fly')
              .id,
          isNot(workouts[0]
              .exercises
              .firstWhere((exercise) => exercise.name == 'Cable Fly')
              .id));
    });

    test('direct weekly set totals match primary classification', () {
      final totals = <String, int>{};
      for (final exercise in workouts.expand((day) => day.exercises)) {
        totals.update(exercise.targetMuscles.single,
            (sets) => sets + (exercise.sets ?? 0),
            ifAbsent: () => exercise.sets ?? 0);
      }

      expect(totals, {
        'Chest': 18,
        'Triceps': 9,
        'Abs/Core': 12,
        'Back/Lats': 9,
        'Rear delts / upper back': 3,
        'Biceps': 9,
        'Biceps / brachialis': 3,
        'Forearms / brachioradialis': 3,
        'Quadriceps': 9,
        'Hamstrings': 6,
        'Glutes': 3,
        'Calves': 3,
        'Shoulders': 3,
        'Side delts': 4,
        'Rear delts': 3,
        'Traps': 3,
      });
    });
  });

  test('v6 migration preserves history, drafts, and unrelated Hive data',
      () async {
    final directory = await Directory.systemTemp.createTemp('fitora-workout-');
    Hive.init(directory.path);
    final box = await Hive.openBox<dynamic>('workout-migration-test');
    addTearDown(() async {
      await box.close();
      await directory.delete(recursive: true);
    });

    const oldDraft = {
      '2026-08-27:hypertrophy-day-1': {
        'id': 'old-draft',
        'exerciseLogs': [
          {'exerciseId': 'h-d1-smith-squat', 'weightKg': 100.0}
        ],
      }
    };
    const sentinels = <String, dynamic>{
      StorageKeys.profile: {'name': 'preserve-profile'},
      StorageKeys.meals: [
        {'id': 'preserve-meal'}
      ],
      StorageKeys.supplements: [
        {'id': 'preserve-supplement'}
      ],
      StorageKeys.dailyNutritionDrafts: {'calories': 2100},
      StorageKeys.progress: [
        {'weightKg': 84.0}
      ],
      StorageKeys.checklist: {'water': true},
      StorageKeys.workoutSessions: [
        {'id': 'historical-session'}
      ],
      StorageKeys.workoutLogs: oldDraft,
      StorageKeys.usdaFoodSearchCache: {'food': 'preserve-cache'},
    };
    for (final entry in sentinels.entries) {
      await box.put(entry.key, entry.value);
    }
    await box.put(StorageKeys.workouts, const <dynamic>[]);
    await box.put(StorageKeys.workoutSeedVersion, 6);

    await LocalStorageService.forTesting(box).ensureWorkoutPlanCurrent();

    for (final entry in sentinels.entries) {
      expect(box.get(entry.key), entry.value, reason: entry.key);
    }
    expect(box.get(StorageKeys.workoutSeedVersion), 7);
    final migrated = box.get(StorageKeys.workouts) as List<dynamic>;
    expect(migrated, hasLength(4));
    expect(migrated.map((day) => (day as Map)['id']),
        everyElement(startsWith('upper-specialization-v7-day-')));
  });
}

void _expectPlan(WorkoutDay day, List<(String, String)> expected) {
  final actual =
      day.exercises.map((exercise) => (exercise.name, exercise.reps!)).toList();
  expect(actual, expected);
}
