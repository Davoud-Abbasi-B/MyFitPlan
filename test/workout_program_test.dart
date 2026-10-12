import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:my_fit_plan/data/local/default_seed_data.dart';
import 'package:my_fit_plan/data/local/local_storage_service.dart';
import 'package:my_fit_plan/data/local/storage_keys.dart';
import 'package:my_fit_plan/features/workout/models/workout_day_model.dart';
import 'package:my_fit_plan/features/workout/models/workout_log_model.dart';
import 'package:my_fit_plan/features/workout/models/workout_session_model.dart';

void main() {
  final workouts = DefaultSeedData.workouts();
  test('v8 has exactly four gym days and new stable IDs', () {
    expect(DefaultSeedData.workoutSeedVersion, 8);
    expect(workouts.map((day) => day.dayNumber), [1, 2, 4, 5]);
    expect(workouts.map((day) => day.title),
        ['Upper Body A', 'Lower Body A', 'Upper Body B', 'Lower Body B']);
    expect(workouts.map((day) => day.exercises.length), [8, 5, 9, 6]);
    expect(workouts.every((day) => day.isGymWorkout), isTrue);
    expect(workouts.map((day) => day.id),
        everyElement(startsWith('upper-lower-v8-day-')));
    final exercises = workouts.expand((day) => day.exercises).toList();
    expect(exercises.map((e) => e.id).toSet(), hasLength(28));
    expect(exercises.map((e) => e.id),
        everyElement(startsWith('upper-lower-v8-')));
    for (final day in workouts) {
      expect(WorkoutDay.fromJson(day.toJson()).toJson(), day.toJson());
    }
    expect(workouts.first.exercises.first.alternativeText, isNull);
  });

  test('calendar resolution and labels match the whole Saturday-first week',
      () {
    const titles = [
      'Upper Body A',
      'Lower Body A',
      null,
      'Upper Body B',
      'Lower Body B',
      null,
      null
    ];
    const labels = [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنجشنبه',
      'جمعه'
    ];
    for (var offset = 0; offset < 7; offset++) {
      final date = DateTime(2026, 10, 10 + offset);
      final resolved = WorkoutDay.scheduledFor(workouts, date);
      expect(resolved?.title, titles[offset], reason: labels[offset]);
      expect(
          workouts
              .where((day) => day.isScheduledOn(date))
              .map((day) => day.title),
          titles[offset] == null ? isEmpty : [titles[offset]]);
      if (resolved != null) {
        expect(resolved.dayNumber, offset + 1);
        expect(resolved.persianWeekdayLabel, labels[offset]);
      }
    }
  });

  test('all exercise prescriptions match the requested program exactly', () {
    const expected = [
      [
        ('Bench Press', 3, '6-10', '2', '2-3 minutes'),
        ('Incline Dumbbell Press', 3, '8-12', '1-2', '2 minutes'),
        ('Pec Deck', 3, '12-15', '1-2', '60-90 seconds'),
        ('Chest-Supported Row', 3, '8-12', '1-2', '2 minutes'),
        ('Dumbbell Lateral Raise', 4, '12-20', '1-2', '60-90 seconds'),
        (
          'Overhead Cable Triceps Extension',
          3,
          '10-15',
          '1-2',
          '60-90 seconds'
        ),
        ('Bayesian Cable Curl', 3, '10-15', '1-2', '60-90 seconds'),
        ('Reverse Curl', 3, '10-15', '1-2', '60-90 seconds'),
      ],
      [
        ('Smith Squat', 3, '6-10', '2', '2-3 minutes'),
        ('Leg Press', 3, '8-12', '1-2', '2-3 minutes'),
        ('Leg Extension', 3, '10-15', '1-2', '60-90 seconds'),
        ('Lying Leg Curl', 3, '10-15', '1-2', '90 seconds'),
        ('Standing Calf Raise', 3, '10-15', '1-2', '60-90 seconds'),
      ],
      [
        ('Assisted Pull-up', 3, '6-10', '1-2', '2-3 minutes'),
        ('Seated Row', 3, '8-12', '1-2', '2 minutes'),
        ('Dumbbell Shoulder Press', 3, '6-10', '2', '2-3 minutes'),
        ('Machine Chest Press', 3, '8-12', '1-2', '2 minutes'),
        ('Cable Lateral Raise', 3, '12-20', '1-2', '60-90 seconds'),
        ('Rear Delt Fly', 3, '12-20', '1-2', '60-90 seconds'),
        ('Hammer Curl', 3, '10-15', '1-2', '60-90 seconds'),
        ('Rope Triceps Pushdown', 3, '10-15', '1-2', '60-90 seconds'),
        ('Barbell Shrug', 3, '10-15', '1-2', '90 seconds'),
      ],
      [
        ('Romanian Deadlift', 3, '6-10', '2', '2-3 minutes'),
        ('Hip Thrust', 3, '8-12', '1-2', '2 minutes'),
        ('Bulgarian Split Squat', 3, '8-12 each leg', '1-2', '2 minutes'),
        ('Seated Leg Curl', 3, '10-15', '1-2', '90 seconds'),
        ('Leg Extension', 3, '12-20', '1-2', '60-90 seconds'),
        ('Seated Calf Raise', 3, '12-20', '1-2', '60-90 seconds'),
      ],
    ];
    for (var i = 0; i < workouts.length; i++) {
      expect(
          workouts[i].exercises.map(
              (e) => (e.name, e.sets, e.reps, e.targetRirText, e.restText)),
          expected[i],
          reason: workouts[i].title);
    }
  });

  test('same-date legacy sessions do not block v8; v8 duplicates are rejected',
      () async {
    final directory =
        await Directory('release_output').createTemp('session-test-');
    Hive.init(directory.path);
    final box = await Hive.openBox<dynamic>('session-isolation');
    addTearDown(() async {
      await box.close();
      await directory.delete(recursive: true);
    });
    final day = workouts.first;
    final session = WorkoutSession.fromDraft(
        workoutDay: day, draft: WorkoutLog.createForToday(day));
    final oldJson = session.toJson()..remove('workoutDayId');
    oldJson['id'] = '${session.dateKey}-day-1';
    oldJson['workoutTitle'] = 'Upper A';
    oldJson['legacyMetadata'] = {'preserve': 'verbatim'};
    await box.put(StorageKeys.workoutSessions, [oldJson]);
    final storage = LocalStorageService.forTesting(box);
    expect(await storage.saveWorkoutSession(session), isTrue);
    expect(await storage.saveWorkoutSession(session), isFalse);
    final sessions = await storage.loadWorkoutSessions();
    expect(sessions, hasLength(2));
    expect((box.get(StorageKeys.workoutSessions) as List).first, oldJson);
    expect(sessions.singleWhere((s) => s.workoutDayId == null).workoutTitle,
        'Upper A');
    expect(WorkoutSession.fromJson(session.toJson()).workoutDayId, day.id);
  });

  test('v7 migration preserves history, drafts, and unrelated Hive data',
      () async {
    final directory =
        await Directory('release_output').createTemp('fitora-workout-');
    Hive.init(directory.path);
    final box = await Hive.openBox<dynamic>('workout-migration-test');
    addTearDown(() async {
      await box.close();
      await directory.delete(recursive: true);
    });

    const oldDraft = {
      '2026-08-27:upper-specialization-v7-day-1': {
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
        {
          'id': '2026-08-27-day-6',
          'dateKey': '2026-08-27',
          'completedAt': '2026-08-27T18:00:00.000',
          'workoutDayNumber': 6,
          'workoutTitle': 'Upper C',
          'workoutFocus': 'historical focus',
          'exercises': [
            {
              'exerciseId': 'h-d4-ab-wheel',
              'exerciseName': 'Ab Wheel',
              'plannedSets': 3,
              'plannedReps': '6-12',
              'completed': true
            }
          ],
        }
      ],
      StorageKeys.workoutLogs: oldDraft,
      StorageKeys.usdaFoodSearchCache: {'food': 'preserve-cache'},
      StorageKeys.nutritionLog: {'meals': 'preserve-nutrition'},
      StorageKeys.dailyNutritionReports: [
        {'dateKey': 'preserve-report'}
      ],
      StorageKeys.checklistHistory: {'history': 'preserve-checklist'},
      StorageKeys.cravingLogs: [
        {'id': 'preserve-craving'}
      ],
      StorageKeys.supplementLog: {'taken': 'preserve-supplements'},
      'unrelated-key': {'value': 42},
    };
    for (final entry in sentinels.entries) {
      await box.put(entry.key, entry.value);
    }
    await box.put(StorageKeys.workouts, [
      {
        'id': 'upper-specialization-v7-day-1',
        'title': 'Upper A',
        'dayNumber': 1
      },
      {
        'id': 'upper-specialization-v7-day-2',
        'title': 'Upper B',
        'dayNumber': 2
      },
      {'id': 'upper-specialization-v7-day-3', 'title': 'Lower', 'dayNumber': 4},
      {
        'id': 'upper-specialization-v7-day-4',
        'title': 'Upper C',
        'dayNumber': 6
      },
    ]);
    await box.put(StorageKeys.workoutSeedVersion, 7);

    await LocalStorageService.forTesting(box).ensureWorkoutPlanCurrent();

    for (final entry in sentinels.entries) {
      expect(box.get(entry.key), entry.value, reason: entry.key);
    }
    expect(box.get(StorageKeys.workoutSeedVersion), 8);
    final storage = LocalStorageService.forTesting(box);
    final historical = (await storage.loadWorkoutSessions()).single;
    expect(historical.workoutTitle, 'Upper C');
    expect(historical.exercises.single.exerciseName, 'Ab Wheel');
    expect(historical.workoutDayId, isNull);
    final fresh =
        await storage.loadWorkoutLogForToday(DefaultSeedData.workouts().first);
    expect(
        fresh.exerciseLogs
            .every((log) => !log.completed && log.weightKg == null),
        isTrue);
    expect(fresh.workoutDayId, 'upper-lower-v8-day-1');
    final afterMigration = box.toMap();
    await storage.ensureWorkoutPlanCurrent();
    expect(box.toMap(), afterMigration, reason: 'Migration must be idempotent');
    final migrated = box.get(StorageKeys.workouts) as List<dynamic>;
    expect(migrated, hasLength(4));
    expect(migrated.map((day) => (day as Map)['id']),
        everyElement(startsWith('upper-lower-v8-day-')));
  });
}
