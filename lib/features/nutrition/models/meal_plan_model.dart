import 'meal_model.dart';

class MealPlan {
  const MealPlan({
    required this.id,
    required this.title,
    required this.isTrainingDay,
    required this.meals,
  });

  final String id;
  final String title;
  final bool isTrainingDay;
  final List<Meal> meals;

  int get totalProtein => meals.fold(0, (sum, meal) => sum + meal.proteinGrams);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isTrainingDay': isTrainingDay,
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final mealsJson = json['meals'] as List<dynamic>? ?? <dynamic>[];

    return MealPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      isTrainingDay: json['isTrainingDay'] as bool? ?? false,
      meals: mealsJson
          .map((meal) => Meal.fromJson(Map<String, dynamic>.from(meal as Map)))
          .toList(),
    );
  }
}
