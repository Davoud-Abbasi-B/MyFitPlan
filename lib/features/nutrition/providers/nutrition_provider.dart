import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/nutrition_log_model.dart';

final nutritionLogProvider =
    AsyncNotifierProvider<NutritionLogNotifier, NutritionLog>(
  NutritionLogNotifier.new,
);

class NutritionLogNotifier extends AsyncNotifier<NutritionLog> {
  @override
  Future<NutritionLog> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    final mealPlans = await storage.loadMealPlans();
    return storage.loadNutritionLogForToday(mealPlans);
  }

  Future<void> toggleMeal(String mealId, bool completed) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final updatedIds = [...current.completedMealIds];
    if (completed) {
      if (!updatedIds.contains(mealId)) {
        updatedIds.add(mealId);
      }
    } else {
      updatedIds.remove(mealId);
    }

    await _save(current.copyWith(completedMealIds: updatedIds));
  }

  Future<void> selectSnackOption(String option) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    await _save(current.copyWith(selectedSnackOption: option));
  }

  Future<void> _save(NutritionLog updated) async {
    state = AsyncData(updated);
    final storage = ref.read(localStorageServiceProvider);
    await storage.saveNutritionLog(updated);
  }
}
