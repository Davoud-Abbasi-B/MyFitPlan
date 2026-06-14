import '../../../core/utils/date_utils.dart';
import 'exercise_model.dart';

enum WorkoutLocation {
  gym,
  outdoor,
}

class WorkoutDay {
  const WorkoutDay({
    required this.id,
    required this.title,
    required this.focus,
    required this.dayNumber,
    required this.exercises,
    required this.cardioMinutes,
    required this.location,
  });

  final String id;
  final String title;
  final String focus;
  final int dayNumber;
  final List<Exercise> exercises;
  final int cardioMinutes;
  final WorkoutLocation location;

  bool get isGymWorkout => location == WorkoutLocation.gym;
  bool get isOutdoorWorkout => location == WorkoutLocation.outdoor;

  String get persianWeekdayLabel {
    switch (dayNumber) {
      case 1:
        return 'شنبه';
      case 2:
        return 'یکشنبه';
      case 3:
        return 'سه‌شنبه';
      case 4:
        return 'چهارشنبه';
      case 5:
        return 'پنجشنبه';
      default:
        return '';
    }
  }

  String get displayScheduleLabel {
    final dayNumberLabel = AppDateUtils.toPersianDigits(dayNumber.toString());
    return 'روز $dayNumberLabel - $persianWeekdayLabel';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'focus': focus,
      'dayNumber': dayNumber,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'cardioMinutes': cardioMinutes,
      'location': location.name,
    };
  }

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'] as List<dynamic>? ?? <dynamic>[];
    final locationName = json['location'] as String?;

    return WorkoutDay(
      id: json['id'] as String,
      title: json['title'] as String,
      focus: json['focus'] as String,
      dayNumber: json['dayNumber'] as int,
      exercises: exercisesJson
          .map((item) => Exercise.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
      cardioMinutes: json['cardioMinutes'] as int? ?? 0,
      location: WorkoutLocation.values.firstWhere(
        (value) => value.name == locationName,
        orElse: () => WorkoutLocation.gym,
      ),
    );
  }
}
