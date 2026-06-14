import '../../features/checklist/models/daily_checklist_model.dart';
import '../../features/nutrition/models/meal_plan_model.dart';
import '../../features/progress/models/body_progress_model.dart';
import '../../features/settings/models/user_profile_model.dart';
import '../../features/supplements/models/supplement_model.dart';
import '../../features/workout/models/workout_day_model.dart';

class AppSnapshot {
  const AppSnapshot({
    required this.profile,
    required this.workouts,
    required this.mealPlans,
    required this.supplements,
    required this.progressEntries,
    required this.todayChecklist,
  });

  final UserProfile profile;
  final List<WorkoutDay> workouts;
  final List<MealPlan> mealPlans;
  final List<Supplement> supplements;
  final List<BodyProgress> progressEntries;
  final DailyChecklist todayChecklist;
}
