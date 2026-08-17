import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/data/local/default_seed_data.dart';
import 'package:my_fit_plan/features/workout/exercise_motion_assets.dart';
import 'package:my_fit_plan/features/workout/models/exercise_model.dart';

void main() {
  test('motion directory is registered in pubspec', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/exercises/motion/'));
  });

  test('every mapped motion asset exists with exact filename casing', () {
    final filenames = Directory('assets/exercises/motion')
        .listSync()
        .whereType<File>()
        .map((file) => file.uri.pathSegments.last)
        .toSet();

    for (final path in exerciseMotionAssetPaths.values.toSet()) {
      expect(File(path).existsSync(), isTrue, reason: 'Missing asset: $path');
      expect(filenames, contains(Uri.parse(path).pathSegments.last),
          reason: 'Filename casing differs for $path');
    }
  });

  test('case-sensitive and leg-curl mappings use the supplied files', () {
    expect(motionAssetPathForExerciseName('Smith Squat'),
        'assets/exercises/motion/Smith_Squat_motion.gif');
    expect(motionAssetPathForExerciseName('Seated Leg Curl'),
        'assets/exercises/motion/seated_leg_curl_motion.gif');
    expect(motionAssetPathForExerciseName('Lying Leg Curl'),
        'assets/exercises/motion/lying_leg_curl_motion.gif');
    expect(motionAssetPathForExerciseName('Seated Row'),
        'assets/exercises/motion/Seated_Row_motion.gif');
    expect(motionAssetPathForExerciseName('Single-Arm Cable Row'),
        'assets/exercises/motion/Single_Arm_Cable_Row_motion.gif');
    expect(motionAssetPathForExerciseName('Seated Calf Raise'),
        'assets/exercises/motion/Seated_Calf_Raise_motion.gif');
    expect(motionAssetPathForExerciseName('Standing Calf Raise'),
        'assets/exercises/motion/Standing_Calf_Raise_motion.gif');
  });

  test('actual Hammer Curl filename is used without renaming', () {
    expect(motionAssetPathForExerciseName('Hammer Curl'),
        'assets/exercises/motion/hammer_curl_motion.gif');
    expect(File('assets/exercises/motion/hamer_curl_motion.gif').existsSync(),
        isFalse);
  });

  test('all current exercises resolve to motion or a safe fallback', () {
    final exercises = DefaultSeedData.workouts()
        .expand((day) => day.exercises)
        .where((exercise) => exercise.type != ExerciseType.cardio)
        .toList();

    for (final exercise in exercises) {
      final motionPath = motionAssetPathForExerciseName(exercise.name);
      if (motionPath != null) {
        expect(File(motionPath).existsSync(), isTrue);
        continue;
      }

      expect(exercise.name, anyOf('Cable Fly', 'Bayesian Cable Curl'));
      if (exercise.name == 'Cable Fly') {
        expect(exercise.imageAssetPath, isNull);
      } else {
        expect(exercise.imageAssetPath,
            'assets/exercises/bayesian_cable_curl.png');
        expect(File(exercise.imageAssetPath!).existsSync(), isTrue);
      }
    }
  });

  test('Cable Fly and Bayesian Cable Curl are not silently mis-mapped', () {
    expect(motionAssetPathForExerciseName('Cable Fly'), isNull);
    expect(motionAssetPathForExerciseName('Bayesian Cable Curl'), isNull);
  });

  test('only the intentional incline-curl aliases share a motion asset', () {
    final namesByPath = <String, Set<String>>{};
    for (final entry in exerciseMotionAssetPaths.entries) {
      namesByPath.putIfAbsent(entry.value, () => <String>{}).add(entry.key);
    }
    final duplicates = namesByPath.values
        .where((names) => names.length > 1)
        .toList(growable: false);

    expect(duplicates, [
      {'Incline DB Curl', 'Incline Dumbbell Curl'}
    ]);
  });
}
