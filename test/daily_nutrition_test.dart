import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/features/nutrition/models/daily_nutrition_model.dart';
import 'package:my_fit_plan/features/nutrition/models/food_analysis_result.dart';
import 'package:my_fit_plan/features/nutrition/providers/daily_nutrition_provider.dart';

void main() {
  test('calculates daily totals locally', () {
    final entries = [
      _entry(id: '1', calories: 280, protein: 24, carbs: 2, fat: 20),
      _entry(id: '2', calories: 270, protein: 9, carbs: 55, fat: 2),
    ];
    final totals = DailyNutritionTotals.fromEntries(entries);
    expect(totals.calories, 550);
    expect(totals.proteinGrams, 33);
    expect(totals.carbsGrams, 57);
    expect(totals.fatGrams, 22);
  });

  test('batch totals never rely on a remote total', () {
    final batch = FoodAnalysisBatchResult(
      originalInput: 'غذاها',
      items: const [
        FoodAnalysisResult(
          originalInput: 'اول',
          foodName: 'اول',
          quantityText: '۱۰ گرم',
          calories: 27,
          proteinGrams: 0.9,
          carbsGrams: 5.5,
          fatGrams: 0.2,
          isEstimated: true,
        ),
        FoodAnalysisResult(
          originalInput: 'دوم',
          foodName: 'دوم',
          quantityText: '۵۰ گرم',
          calories: 65,
          proteinGrams: 1.4,
          carbsGrams: 14,
          fatGrams: 0.2,
          isEstimated: true,
        ),
      ],
    );
    expect(batch.totals.calories, 92);
    expect(batch.totals.proteinGrams, 2.3);
  });

  test('prevents a second report for the same date', () {
    final report = DailyNutritionReport.fromEntries(
      dateKey: '2026-08-02',
      entries: [_entry(id: '1')],
      dayType: NutritionDayType.training,
    );
    expect(canSubmitNutritionReport([], report.dateKey), isTrue);
    expect(canSubmitNutritionReport([report], report.dateKey), isFalse);
  });

  test('legacy entry data remains backward compatible', () {
    final decoded = DailyNutritionEntry.fromJson({
      'id': 'legacy',
      'dateKey': '2026-08-02',
      'createdAt': '2026-08-02T10:00:00.000',
      'foodName': 'تخم‌مرغ',
      'calories': 70,
      'proteinGrams': 6,
      'carbsGrams': 0.5,
      'fatGrams': 5,
      'confidence': 'medium',
      'assumptions': ['اندازه متوسط'],
    });
    expect(decoded.foodName, 'تخم‌مرغ');
    expect(decoded.confidence, 'medium');
    expect(decoded.sourceType, FoodSourceType.local);
    expect(decoded.warnings, isEmpty);
  });

  test('adds every analyzed item as a separate draft entry', () {
    final entries = dailyNutritionEntriesFromAnalyses(
      [_result('تخم‌مرغ'), _result('شیر')],
      dateKey: '2026-08-02',
      createdAt: DateTime(2026, 8, 2, 12),
    );
    expect(entries.map((entry) => entry.foodName), ['تخم‌مرغ', 'شیر']);
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2));
  });

  test('confirmation guard prevents repeated insertion', () {
    final guard = FoodConfirmationGuard();
    expect(guard.tryConfirm(), isTrue);
    expect(guard.tryConfirm(), isFalse);
  });
}

FoodAnalysisResult _result(String name) => FoodAnalysisResult(
      originalInput: name,
      foodName: name,
      quantityText: '۱ عدد',
      calories: 70,
      proteinGrams: 6,
      carbsGrams: 0.5,
      fatGrams: 5,
      isEstimated: true,
    );

DailyNutritionEntry _entry({
  required String id,
  double calories = 70,
  double protein = 6,
  double carbs = 0.5,
  double fat = 5,
}) =>
    DailyNutritionEntry(
      id: id,
      dateKey: '2026-08-02',
      createdAt: DateTime(2026, 8, 2, 10),
      originalInput: '۱ عدد تخم‌مرغ',
      foodName: 'تخم‌مرغ',
      quantityText: '۱ عدد',
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      isEstimated: true,
    );
