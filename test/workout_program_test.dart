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
  test('v9 has exactly four gym days and new stable IDs', () {
    expect(DefaultSeedData.workoutSeedVersion, 9);
    expect(workouts.map((day) => day.dayNumber), [1, 2, 4, 5]);
    expect(workouts.map((day) => day.title),
        ['Upper A', 'Lower', 'Upper B', 'Upper C']);
    expect(workouts.map((day) => day.exercises.length), [8, 7, 8, 7]);
    expect(workouts.every((day) => day.isGymWorkout), isTrue);
    expect(workouts.map((day) => day.id),
        everyElement(startsWith('upper-lower-v9-day-')));
    final exercises = workouts.expand((day) => day.exercises).toList();
    expect(exercises.map((e) => e.id).toSet(), hasLength(30));
    expect(exercises.map((e) => e.id),
        everyElement(startsWith('upper-lower-v9-')));
    for (final day in workouts) {
      expect(WorkoutDay.fromJson(day.toJson()).toJson(), day.toJson());
    }
    expect(workouts.first.exercises.first.alternativeText, isNull);
  });

  test('only requested exercises remain active with a single Lower day', () {
    final names = workouts.expand((day) => day.exercises).map((e) => e.name);
    expect(names, isNot(contains('Machine Chest Press')));
    expect(names, isNot(contains('Assisted Pull-up')));
    expect(
        workouts.where((day) => day.title.startsWith('Lower')), hasLength(1));
    expect(workouts.first.exercises.map((e) => e.name),
        contains('High-to-Low Cable Fly'));
    expect(workouts.first.exercises, hasLength(8));
  });

  test('calendar resolution and labels match the whole Saturday-first week',
      () {
    const titles = ['Upper A', 'Lower', null, 'Upper B', 'Upper C', null, null];
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
        ('High-to-Low Cable Fly', 3, '12-15', '1-2', '60-90 seconds'),
        ('Chest-Supported Row', 3, '8-12', '1-2', '2 minutes'),
        ('Dumbbell Lateral Raise', 3, '12-20', '1-2', '60-90 seconds'),
        (
          'Overhead Cable Triceps Extension',
          3,
          '10-15',
          '1-2',
          '60-90 seconds'
        ),
        ('Bayesian Cable Curl', 3, '10-15', '1-2', '60-90 seconds'),
      ],
      [
        ('Smith Squat', 3, '6-10', '2', '2-3 minutes'),
        ('Leg Press', 3, '8-12', '1-2', '2-3 minutes'),
        ('Leg Extension', 3, '10-15', '1-2', '60-90 seconds'),
        ('Romanian Deadlift', 3, '6-10', '2', '2-3 minutes'),
        ('Hip Thrust', 3, '8-12', '1-2', '2 minutes'),
        ('Bulgarian Split Squat', 3, '8-12 each leg', '1-2', '2 minutes'),
        ('Standing Calf Raise', 3, '10-15', '1-2', '60-90 seconds'),
      ],
      [
        ('Lat Pulldown', 3, '6-10', '1-2', '2-3 minutes'),
        ('Seated Row', 3, '8-12', '1-2', '2 minutes'),
        ('Single-Arm Cable Row', 3, '10-12 each side', '1-2', '90-120 seconds'),
        ('Dumbbell Shoulder Press', 3, '6-10', '2', '2-3 minutes'),
        ('Rear Delt Fly', 3, '12-20', '1-2', '60-90 seconds'),
        ('Hammer Curl', 3, '10-15', '1-2', '60-90 seconds'),
        ('Reverse Curl', 3, '10-15', '1-2', '60-90 seconds'),
        ('Rope Triceps Pushdown', 3, '10-15', '1-2', '60-90 seconds'),
      ],
      [
        ('Incline Dumbbell Press', 3, '8-12', '1-2', '2 minutes'),
        ('Lat Pulldown', 3, '8-12', '1-2', '2 minutes'),
        ('Cable Lateral Raise', 3, '12-20', '1-2', '60-90 seconds'),
        ('Face Pull', 3, '12-20', '1-2', '60-90 seconds'),
        ('Barbell Shrug', 3, '10-15', '1-2', '90 seconds'),
        ('Cable Curl', 3, '10-15', '1-2', '60-90 seconds'),
        ('Rope Triceps Pushdown', 3, '10-15', '1-2', '60-90 seconds'),
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

  test('same-date legacy sessions do not block v9; v9 duplicates are rejected',
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
    oldJson['id'] = '${session.dateKey}-upper-lower-v8-day-1';
    oldJson['workoutDayId'] = 'upper-lower-v8-day-1';
    oldJson['workoutTitle'] = 'Upper A';
    oldJson['legacyMetadata'] = {'preserve': 'verbatim'};
    await box.put(StorageKeys.workoutSessions, [oldJson]);
    final storage = LocalStorageService.forTesting(box);
    expect(await storage.saveWorkoutSession(session), isTrue);
    expect(await storage.saveWorkoutSession(session), isFalse);
    final sessions = await storage.loadWorkoutSessions();
    expect(sessions, hasLength(2));
    expect((box.get(StorageKeys.workoutSessions) as List).first, oldJson);
    expect(
        sessions
            .singleWhere((s) => s.workoutDayId == 'upper-lower-v8-day-1')
            .workoutTitle,
        'Upper A');
    expect(WorkoutSession.fromJson(session.toJson()).workoutDayId, day.id);
  });

  for (final previousVersion in [7, 8]) {
    test(
        'v$previousVersion migration preserves history, drafts, and unrelated Hive data',
        () async {
      final directory =
          await Directory('release_output').createTemp('fitora-workout-');
      Hive.init(directory.path);
      final box = await Hive.openBox<dynamic>('workout-migration-test');
      addTearDown(() async {
        await box.close();
        await directory.delete(recursive: true);
      });

      final oldDraft = {
        '${DateTime.now().toIso8601String().substring(0, 10)}:upper-lower-v$previousVersion-day-1':
            {
          'id': 'old-draft',
          'exerciseLogs': [
            {'exerciseId': 'h-d1-smith-squat', 'weightKg': 100.0}
          ],
        }
      };
      final sentinels = <String, dynamic>{
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
            'workoutTitle': previousVersion == 8 ? 'Lower Body B' : 'Upper C',
            if (previousVersion == 8) 'workoutDayId': 'upper-lower-v8-day-4',
            'workoutFocus': 'historical focus',
            'exercises': [
              {
                'exerciseId': 'h-d4-ab-wheel',
                'exerciseName':
                    previousVersion == 8 ? 'Romanian Deadlift' : 'Ab Wheel',
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
          'id': 'upper-lower-v$previousVersion-day-1',
          'title': previousVersion == 8 ? 'Upper Body A' : 'Upper A',
          'dayNumber': 1
        },
        {
          'id': 'upper-lower-v$previousVersion-day-2',
          'title': previousVersion == 8 ? 'Lower Body A' : 'Upper B',
          'dayNumber': 2
        },
        {
          'id': 'upper-lower-v$previousVersion-day-3',
          'title': previousVersion == 8 ? 'Upper Body B' : 'Lower',
          'dayNumber': 4
        },
        {
          'id': 'upper-lower-v$previousVersion-day-4',
          'title': previousVersion == 8 ? 'Lower Body B' : 'Upper C',
          'dayNumber': previousVersion == 8 ? 5 : 6
        },
      ]);
      await box.put(StorageKeys.workoutSeedVersion, previousVersion);

      await LocalStorageService.forTesting(box).ensureWorkoutPlanCurrent();

      for (final entry in sentinels.entries) {
        expect(box.get(entry.key), entry.value, reason: entry.key);
      }
      expect(box.get(StorageKeys.workoutSeedVersion), 9);
      final storage = LocalStorageService.forTesting(box);
      final historical = (await storage.loadWorkoutSessions()).single;
      expect(historical.workoutTitle,
          previousVersion == 8 ? 'Lower Body B' : 'Upper C');
      expect(historical.exercises.single.exerciseName,
          previousVersion == 8 ? 'Romanian Deadlift' : 'Ab Wheel');
      expect(historical.workoutDayId,
          previousVersion == 8 ? 'upper-lower-v8-day-4' : isNull);
      final fresh = await storage
          .loadWorkoutLogForToday(DefaultSeedData.workouts().first);
      expect(
          fresh.exerciseLogs
              .every((log) => !log.completed && log.weightKg == null),
          isTrue);
      expect(fresh.workoutDayId, 'upper-lower-v9-day-1');
      final afterMigration = box.toMap();
      await storage.ensureWorkoutPlanCurrent();
      expect(box.toMap(), afterMigration,
          reason: 'Migration must be idempotent');
      final migrated = box.get(StorageKeys.workouts) as List<dynamic>;
      expect(migrated, hasLength(4));
      expect(migrated.map((day) => (day as Map)['id']),
          everyElement(startsWith('upper-lower-v9-day-')));
    });
  }
}
