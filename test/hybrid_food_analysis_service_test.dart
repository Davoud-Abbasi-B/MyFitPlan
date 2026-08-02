import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/features/nutrition/models/food_analysis_result.dart';
import 'package:my_fit_plan/features/nutrition/services/food_search_cache_service.dart';
import 'package:my_fit_plan/features/nutrition/services/hybrid_food_analysis_service.dart';
import 'package:my_fit_plan/features/nutrition/services/local_food_database_service.dart';
import 'package:my_fit_plan/features/nutrition/services/persian_food_parser.dart';
import 'package:my_fit_plan/features/nutrition/services/usda_food_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled local database contains at least 80 foods', () async {
    final database = LocalFoodDatabaseService();
    expect((await database.loadFoods()).length, greaterThanOrEqualTo(80));
  });

  test('local database supports exact, alias, custom override, and no match',
      () async {
    final custom = _food(name: 'نان بربری', calories: 999, isCustom: true);
    final db = _database(custom: [custom]);
    expect((await db.findExact('نان بربری'))?.calories, 999);
    expect((await db.findExact('بربری'))?.nameFa, 'نان بربری');
    expect(await db.findExact('خوراک ناشناخته'), isNull);
  });

  test('calculates 10g, 50g, kilograms, and configured portions', () async {
    final service = _service();
    final batch =
        await service.analyze('۱۰ گرم پنیر لیقوان و ۵۰ گرم نان بربری');
    expect(batch.items, hasLength(2));
    expect(batch.items[0].calories, 26.5);
    expect(batch.items[1].calories, 135);
    expect(batch.totals.calories, 162);

    final kg = await service.analyze('۱ کیلوگرم نان بربری');
    expect(kg.items.single.consumedGrams, 1000);
    expect(kg.items.single.calories, 2700);

    final portion = await service.analyze('۲ برش نان بربری');
    expect(portion.items.single.consumedGrams, 70);
  });

  test('missing portion conversion remains unresolved', () async {
    final batch = await _service().analyze('۱ کاسه نان بربری');
    expect(batch.needsUserAction, isTrue);
    expect(batch.items, isEmpty);
  });

  test('ambiguous USDA matches require selection', () async {
    final usda = _FakeUsda([_candidate(1, 50), _candidate(2, 45)]);
    final service = _service(usda: usda);
    final batch = await service.analyze('۱۰۰ گرم سینه مرغ پخته ناشناخته');
    expect(batch.unresolvedItems.single.candidates, hasLength(2));
    expect(batch.items, isEmpty);
  });

  test('cache hit and selected candidate reuse avoid USDA search', () async {
    final cache = MemoryFoodSearchCacheService();
    final selected = _candidate(8, 60);
    await cache.put(FoodSearchCacheEntry(
      query: 'chicken breast cooked skinless',
      candidates: [selected],
      selectedCandidate: selected,
      timestamp: DateTime.now(),
    ));
    final usda = _FakeUsda([]);
    final service = _service(usda: usda, cache: cache);
    final batch = await service.analyze('۱۰۰ گرم سینه مرغ ناشناخته');
    expect(batch.items.single.fdcId, 8);
    expect(usda.calls, 0);
  });

  test('expired cache is ignored', () async {
    final now = DateTime(2026, 8, 2);
    final cache = MemoryFoodSearchCacheService(now: () => now);
    await cache.put(FoodSearchCacheEntry(
      query: 'q',
      candidates: [_candidate(1, 50)],
      timestamp: now.subtract(const Duration(days: 31)),
    ));
    expect(await cache.get('q'), isNull);
  });
}

HybridFoodAnalysisService _service({
  UsdaFoodDataService? usda,
  FoodSearchCacheService? cache,
}) =>
    HybridFoodAnalysisService(
      parser: const PersianFoodParser(),
      localDatabase: _database(),
      usda: usda ?? const UsdaFoodDataService(apiKey: ''),
      cache: cache ?? MemoryFoodSearchCacheService(),
      dictionary: const _TestDictionary(),
    );

LocalFoodDatabaseService _database(
    {List<LocalFoodDefinition> custom = const []}) {
  final data = jsonEncode({
    'version': 1,
    'foods': [
      _food(name: 'پنیر لیقوان', calories: 265).toJson(),
      _food(
        name: 'نان بربری',
        calories: 270,
        aliases: const ['بربری'],
        conversions: const {'برش': 35},
      ).toJson(),
    ],
  });
  return LocalFoodDatabaseService(
    jsonTextLoader: () async => data,
    customFoodLoader: () async => custom,
  );
}

LocalFoodDefinition _food({
  required String name,
  required double calories,
  bool isCustom = false,
  List<String> aliases = const [],
  Map<String, double> conversions = const {},
}) =>
    LocalFoodDefinition(
      id: name,
      nameFa: name,
      aliasesFa: aliases,
      searchTermsEn: const [],
      basisAmount: 100,
      calories: calories,
      proteinGrams: 10,
      carbsGrams: 20,
      fatGrams: 5,
      source: isCustom ? 'user_custom' : 'local_curated',
      defaultGramConversions: conversions,
      isCustom: isCustom,
    );

FoodAnalysisCandidate _candidate(int id, double score) => FoodAnalysisCandidate(
      id: id,
      description: 'Chicken breast cooked',
      dataType: 'Foundation',
      caloriesPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
      matchScore: score,
    );

class _FakeUsda extends UsdaFoodDataService {
  _FakeUsda(this.results) : super(apiKey: 'test');
  final List<FoodAnalysisCandidate> results;
  int calls = 0;

  @override
  Future<List<FoodAnalysisCandidate>> search(String query) async {
    calls++;
    return results;
  }
}

class _TestDictionary extends PersianFoodSearchDictionary {
  const _TestDictionary();

  @override
  String? searchPhrase(String normalizedFoodName,
          {LocalFoodDefinition? localDefinition}) =>
      normalizedFoodName.contains('سینه مرغ')
          ? 'chicken breast cooked skinless'
          : null;
}
