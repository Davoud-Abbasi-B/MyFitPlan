import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/data/local/default_seed_data.dart';
import 'package:my_fit_plan/features/workout/models/exercise_model.dart';
import 'package:my_fit_plan/features/workout/screens/workout_plan_screen.dart';

void main() {
  testWidgets('all active PNGs are bundled and decode successfully',
      (tester) async {
    final paths = DefaultSeedData.workouts()
        .expand((day) => day.exercises)
        .map((exercise) => exercise.imageAssetPath!)
        .toSet();
    expect(paths, hasLength(27));
    await tester.runAsync(() async {
      for (final path in paths) {
        final bytes = await rootBundle.load(path);
        final codec =
            await ui.instantiateImageCodec(bytes.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(0), reason: path);
        expect(frame.image.height, greaterThan(0), reason: path);
        frame.image.dispose();
        codec.dispose();
      }
    });
  });
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
      expect(path, isNotNull, reason: exercise.name);
      expect(path, exercise.imageAssetPath);
      expect(path, endsWith('.png'));
      expect(path, isNot(contains('/motion/')));
      final fallback = Exercise(
          id: 'fallback', name: exercise.name, type: exercise.type, notes: '');
      expect(resolvedExerciseImagePath(fallback), path, reason: exercise.name);

      expect(path!.toLowerCase().endsWith(['.', 'gif'].join()), isFalse,
          reason: exercise.name);
      expect(File(path).existsSync(), isTrue,
          reason: 'Missing static image for ${exercise.name}: $path');
    }
  });

  test('new hypertrophy exercises resolve to their static images', () {
    const expectedPaths = {
      'Pec Deck': 'assets/exercises/pec_deck.png',
      'Bayesian Cable Curl': 'assets/exercises/bayesian_cable_curl.png',
      'Lying Leg Curl': 'assets/exercises/leg_curl.png',
      'Assisted Pull-up': 'assets/exercises/assisted_pullup.png',
      'Seated Row': 'assets/exercises/seated_row.png',
      'Barbell Shrug': 'assets/exercises/barbell_shrug.png',
      'Bulgarian Split Squat': 'assets/exercises/bulgarian_split_squat.png',
      'Seated Calf Raise': 'assets/exercises/seated_calf_raise.png',
      'Seated Leg Curl': 'assets/exercises/seated_leg_curl.png',
      'Dumbbell Shoulder Press': 'assets/exercises/dumbbell_shoulder_press.png',
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
