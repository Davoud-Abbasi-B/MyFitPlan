import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/data/local/default_seed_data.dart';
import 'package:my_fit_plan/features/workout/models/exercise_model.dart';
import 'package:my_fit_plan/features/workout/screens/workout_plan_screen.dart';

void main() {
  test('only the static exercise asset directory is registered', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final removedDirectory = ['assets/exercises', 'motion', ''].join('/');

    expect(pubspec, contains('- assets/exercises/'));
    expect(pubspec, isNot(contains(removedDirectory)));
    expect(Directory(removedDirectory).existsSync(), isFalse);
  });

  test('active workout exercises resolve only to safe static images', () {
    final exercises = DefaultSeedData.workouts().expand(
      (day) => day.exercises,
    );

    for (final exercise in exercises) {
      final path = resolvedExerciseImagePath(exercise);
      if (path == null) {
        continue;
      }

      expect(path.toLowerCase().endsWith(['.', 'gif'].join()), isFalse,
          reason: exercise.name);
      expect(File(path).existsSync(), isTrue,
          reason: 'Missing static image for ${exercise.name}: $path');
    }
  });

  test('new hypertrophy exercises resolve to their static images', () {
    const expectedPaths = {
      'Flat Dumbbell Press': 'assets/exercises/flat_dumbbell_press.png',
      'Cable Fly': 'assets/exercises/cable_fly.png',
      'Hanging Knee Raise': 'assets/exercises/hanging_knee_raise.png',
      'Cable Lateral Raise': 'assets/exercises/cable_lateral_raise.png',
      'Low-to-High Cable Fly': 'assets/exercises/low_to_high_cable_fly.png',
    };
    final exercisesByName = {
      for (final exercise
          in DefaultSeedData.workouts().expand((day) => day.exercises))
        exercise.name: exercise,
    };

    for (final entry in expectedPaths.entries) {
      final exercise = exercisesByName[entry.key];
      expect(exercise, isNotNull, reason: 'Missing exercise ${entry.key}');
      expect(resolvedExerciseImagePath(exercise!), entry.value);
      expect(File(entry.value).existsSync(), isTrue,
          reason: 'Missing static image for ${entry.key}: ${entry.value}');

      final persistedExerciseWithoutImagePath = Exercise(
        id: 'persisted-${entry.key}',
        name: entry.key,
        type: exercise.type,
        notes: '',
      );
      expect(
        resolvedExerciseImagePath(persistedExerciseWithoutImagePath),
        entry.value,
        reason: 'Persisted ${entry.key} should use its static fallback',
      );
    }
  });

  test('existing name fallback resolves safely and unknown names do not', () {
    const fallbackExercise = Exercise(
      id: 'fallback',
      name: 'Bench Press',
      type: ExerciseType.strength,
      notes: '',
    );
    const unknownExercise = Exercise(
      id: 'unknown',
      name: 'Exercise Without Static Artwork',
      type: ExerciseType.strength,
      notes: '',
    );

    final fallbackPath = resolvedExerciseImagePath(fallbackExercise);
    expect(fallbackPath, 'assets/exercises/bench_press.png');
    expect(File(fallbackPath!).existsSync(), isTrue);
    expect(resolvedExerciseImagePath(unknownExercise), isNull);
  });

  testWidgets('missing static image uses the safe placeholder', (tester) async {
    const exercise = Exercise(
      id: 'missing-image',
      name: 'Exercise Without Static Artwork',
      type: ExerciseType.strength,
      notes: '',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ExerciseGuideImage(exercise: exercise),
        ),
      ),
    );

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  test('workout UI has no removed animation resolver dependency', () {
    final source = File(
      'lib/features/workout/screens/workout_plan_screen.dart',
    ).readAsStringSync();
    final removedImport = ['exercise', 'motion', 'assets.dart'].join('_');
    final removedResolver = [
      'motionAssetPathFor',
      'ExerciseName',
    ].join();

    expect(source, isNot(contains(removedImport)));
    expect(source, isNot(contains(removedResolver)));
  });
}
