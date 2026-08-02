import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/features/nutrition/models/daily_nutrition_model.dart';
import 'package:my_fit_plan/features/nutrition/models/food_analysis_result.dart';
import 'package:my_fit_plan/features/nutrition/services/mock_food_analysis_service.dart';

void main() {
  const service = MockFoodAnalysisService(analysisDelay: Duration.zero);

  test('normalizes Persian and Arabic numbers', () {
    expect(normalizePersianNumber('۱۲۳٫۵'), '123.5');
    expect(normalizePersianNumber('٤ عدد'), '4 عدد');
  });

  test('parses four eggs and multiplies macros', () async {
    final result = await service.analyze('۴ عدد تخم‌مرغ');

    expect(result.foodName, 'تخم‌مرغ');
    expect(result.quantityText, '۴ عدد');
    expect(result.calories, 280);
    expect(result.proteinGrams, 24);
    expect(result.carbsGrams, 2);
    expect(result.fatGrams, 20);
    expect(result.isEstimated, isTrue);
  });

  test('parses 100 grams of Barbari bread', () async {
    final result = await service.analyze('100 گرم نان بربری');

    expect(result.foodName, 'نان بربری');
    expect(result.quantityText, '۱۰۰ گرم');
    expect(result.calories, 270);
    expect(result.proteinGrams, 9);
    expect(result.carbsGrams, 55);
    expect(result.fatGrams, 2);
  });

  test('calculates daily totals', () {
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

  test('prevents a second report for the same date', () {
    final report = DailyNutritionReport.fromEntries(
      dateKey: '2026-08-02',
      entries: [_entry(id: '1')],
      dayType: NutritionDayType.training,
    );

    expect(canSubmitNutritionReport([], report.dateKey), isTrue);
    expect(canSubmitNutritionReport([report], report.dateKey), isFalse);
  });

  test('entry and report serialization round trip', () {
    final entry = _entry(id: 'persisted');
    final decodedEntry = DailyNutritionEntry.fromJson(entry.toJson());
    expect(decodedEntry.id, entry.id);
    expect(decodedEntry.foodName, entry.foodName);
    expect(decodedEntry.calories, entry.calories);

    final report = DailyNutritionReport.fromEntries(
      dateKey: entry.dateKey,
      entries: [entry],
      dayType: NutritionDayType.rest,
      submittedAt: DateTime(2026, 8, 2, 12),
    );
    final decodedReport = DailyNutritionReport.fromJson(report.toJson());
    expect(decodedReport.dateKey, report.dateKey);
    expect(decodedReport.entries.single.id, entry.id);
    expect(decodedReport.dayType, NutritionDayType.rest);
    expect(decodedReport.totalCalories, entry.calories);
  });
}

DailyNutritionEntry _entry({
  required String id,
  double calories = 70,
  double protein = 6,
  double carbs = 0.5,
  double fat = 5,
}) {
  const result = FoodAnalysisResult(
    originalInput: '۱ عدد تخم‌مرغ',
    foodName: 'تخم‌مرغ',
    quantityText: '۱ عدد',
    calories: 70,
    proteinGrams: 6,
    carbsGrams: 0.5,
    fatGrams: 5,
    isEstimated: true,
  );
  return DailyNutritionEntry(
    id: id,
    dateKey: '2026-08-02',
    createdAt: DateTime(2026, 8, 2, 10),
    originalInput: result.originalInput,
    foodName: result.foodName,
    quantityText: result.quantityText,
    calories: calories,
    proteinGrams: protein,
    carbsGrams: carbs,
    fatGrams: fat,
    isEstimated: result.isEstimated,
  );
}
