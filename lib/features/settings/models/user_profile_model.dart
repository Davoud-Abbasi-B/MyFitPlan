class UserProfile {
  const UserProfile({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.currentWaistCm,
    required this.weeklyWorkoutDays,
    required this.fitnessLevel,
    required this.goals,
  });

  final int age;
  final String gender;
  final int heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final double currentWaistCm;
  final int weeklyWorkoutDays;
  final String fitnessLevel;
  final List<String> goals;

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'targetWeightKg': targetWeightKg,
      'currentWaistCm': currentWaistCm,
      'weeklyWorkoutDays': weeklyWorkoutDays,
      'fitnessLevel': fitnessLevel,
      'goals': goals,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] as int,
      gender: json['gender'] as String,
      heightCm: json['heightCm'] as int,
      currentWeightKg: (json['currentWeightKg'] as num).toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num).toDouble(),
      currentWaistCm: (json['currentWaistCm'] as num).toDouble(),
      weeklyWorkoutDays: json['weeklyWorkoutDays'] as int,
      fitnessLevel: json['fitnessLevel'] as String,
      goals: (json['goals'] as List<dynamic>).cast<String>(),
    );
  }
}
