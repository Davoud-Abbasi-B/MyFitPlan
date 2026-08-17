const exerciseMotionAssetPaths = <String, String>{
  'Ab Wheel': 'assets/exercises/motion/ab_wheel_motion.gif',
  'Assisted Pull-up': 'assets/exercises/motion/assisted_pull_up_motion.gif',
  'Bench Press': 'assets/exercises/motion/bench_press_motion.gif',
  'Cable Crunch': 'assets/exercises/motion/cable_crunch_motion.gif',
  'Cable Curl': 'assets/exercises/motion/cable_curl_motion.gif',
  'Dumbbell Shoulder Press':
      'assets/exercises/motion/dumbbell_shoulder_press_motion.gif',
  'Farmer Carry': 'assets/exercises/motion/farmer_carry_motion.gif',
  'Hammer Curl': 'assets/exercises/motion/hammer_curl_motion.gif',
  'Hip Thrust': 'assets/exercises/motion/hip_thrust_motion.gif',
  'Incline DB Curl': 'assets/exercises/motion/incline_db_curl_motion.gif',
  'Incline Dumbbell Curl': 'assets/exercises/motion/incline_db_curl_motion.gif',
  'Incline Dumbbell Press':
      'assets/exercises/motion/incline_dumbbell_press_motion.gif',
  'Lat Pulldown': 'assets/exercises/motion/lat_pulldown_motion.gif',
  'Lateral Raise': 'assets/exercises/motion/lateral_raise_motion.gif',
  'Leg Extension': 'assets/exercises/motion/leg_extension_motion.gif',
  'Leg Press': 'assets/exercises/motion/leg_press_motion.gif',
  'Lying Leg Curl': 'assets/exercises/motion/lying_leg_curl_motion.gif',
  'Machine Chest Press':
      'assets/exercises/motion/machine_chest_press_motion.gif',
  'Overhead Cable Triceps Extension':
      'assets/exercises/motion/overhead_cable_triceps_extension_motion.gif',
  'Pallof Press': 'assets/exercises/motion/pallof_press_motion.gif',
  'Plank': 'assets/exercises/motion/plank_motion.gif',
  'Rear Delt Fly': 'assets/exercises/motion/rear_delt_fly_motion.gif',
  'Reverse Crunch': 'assets/exercises/motion/reverse_crunch_motion.gif',
  'Reverse Lunge': 'assets/exercises/motion/reverse_lunge_motion.gif',
  'Romanian Deadlift': 'assets/exercises/motion/romanian_deadlift_motion.gif',
  'Rope Triceps Pushdown':
      'assets/exercises/motion/rope_triceps_pushdown_motion.gif',
  'Seated Calf Raise': 'assets/exercises/motion/Seated_Calf_Raise_motion.gif',
  'Seated Leg Curl': 'assets/exercises/motion/seated_leg_curl_motion.gif',
  'Seated Row': 'assets/exercises/motion/Seated_Row_motion.gif',
  'Single-Arm Cable Row':
      'assets/exercises/motion/Single_Arm_Cable_Row_motion.gif',
  'Smith Squat': 'assets/exercises/motion/Smith_Squat_motion.gif',
  'Standing Calf Raise':
      'assets/exercises/motion/Standing_Calf_Raise_motion.gif',
};

String? motionAssetPathForExerciseName(String exerciseName) {
  final normalizedName = _normalizeExerciseName(exerciseName);
  final exactMatch = exerciseMotionAssetPaths[normalizedName];
  if (exactMatch != null) return exactMatch;

  final lowerName = normalizedName.toLowerCase();
  for (final entry in exerciseMotionAssetPaths.entries) {
    if (entry.key.toLowerCase() == lowerName) return entry.value;
  }

  return null;
}

String _normalizeExerciseName(String value) {
  return value.trim().replaceAll('\u200c', ' ').replaceAll(RegExp(r'\s+'), ' ');
}
