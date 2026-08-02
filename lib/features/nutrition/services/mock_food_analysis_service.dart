import '../../../core/utils/date_utils.dart';
import '../models/food_analysis_result.dart';
import 'food_analysis_service.dart';

class MockFoodAnalysisService implements FoodAnalysisService {
  const MockFoodAnalysisService(
      {this.analysisDelay = const Duration(milliseconds: 250)});

  final Duration analysisDelay;

  @override
  Future<FoodAnalysisResult> analyze(String input) async {
    if (analysisDelay > Duration.zero) {
      await Future<void>.delayed(analysisDelay);
    }
    final normalized = normalizePersianNumber(input).trim();
    final searchable = _normalizeFoodText(normalized);
    final food = _foods.firstWhere(
      (candidate) => candidate.aliases.any(searchable.contains),
      orElse: () => throw const FoodNotRecognizedException(),
    );

    final numberMatch = RegExp(r'(\d+(?:[\.,]\d+)?)').firstMatch(normalized);
    final parsedAmount = double.tryParse(
      (numberMatch?.group(1) ?? '').replaceAll(',', '.'),
    );
    final amount = parsedAmount ?? food.defaultAmount;
    if (amount <= 0) throw const FoodNotRecognizedException();
    final multiplier = amount / food.baseAmount;

    return FoodAnalysisResult(
      originalInput: input.trim(),
      foodName: food.name,
      quantityText: food.quantityLabel(amount),
      calories: _round(food.calories * multiplier),
      proteinGrams: _round(food.protein * multiplier),
      carbsGrams: _round(food.carbs * multiplier),
      fatGrams: _round(food.fat * multiplier),
      isEstimated: true,
    );
  }
}

String normalizePersianNumber(String value) {
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  var result = value;
  for (var index = 0; index < 10; index++) {
    result = result
        .replaceAll(persian[index], index.toString())
        .replaceAll(arabic[index], index.toString());
  }
  return result.replaceAll('٫', '.').replaceAll('٬', '');
}

String _normalizeFoodText(String value) {
  return value
      .replaceAll('\u200c', ' ')
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'\s+'), ' ')
      .toLowerCase();
}

double _round(double value) => double.parse(value.toStringAsFixed(1));

enum _FoodUnit { item, gram, milliliter, scoop }

class _MockFood {
  const _MockFood({
    required this.name,
    required this.aliases,
    required this.unit,
    required this.baseAmount,
    required this.defaultAmount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final String name;
  final List<String> aliases;
  final _FoodUnit unit;
  final double baseAmount;
  final double defaultAmount;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  String quantityLabel(double amount) {
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(1);
    final persianValue = AppDateUtils.toPersianDigits(value);
    return switch (unit) {
      _FoodUnit.item => '$persianValue عدد',
      _FoodUnit.gram => '$persianValue گرم',
      _FoodUnit.milliliter => '$persianValue میلی‌لیتر',
      _FoodUnit.scoop => '$persianValue پیمانه',
    };
  }
}

const _foods = <_MockFood>[
  _MockFood(
      name: 'سینه مرغ',
      aliases: ['سینه مرغ'],
      unit: _FoodUnit.gram,
      baseAmount: 100,
      defaultAmount: 100,
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6),
  _MockFood(
      name: 'نان بربری',
      aliases: ['نان بربری', 'بربری'],
      unit: _FoodUnit.gram,
      baseAmount: 100,
      defaultAmount: 100,
      calories: 270,
      protein: 9,
      carbs: 55,
      fat: 2),
  _MockFood(
      name: 'نان سنگک',
      aliases: ['نان سنگک', 'سنگک'],
      unit: _FoodUnit.gram,
      baseAmount: 100,
      defaultAmount: 100,
      calories: 259,
      protein: 8.7,
      carbs: 55.7,
      fat: 1.6),
  _MockFood(
      name: 'برنج پخته',
      aliases: ['برنج پخته', 'برنج'],
      unit: _FoodUnit.gram,
      baseAmount: 100,
      defaultAmount: 100,
      calories: 130,
      protein: 2.5,
      carbs: 28,
      fat: 0.3),
  _MockFood(
      name: 'تخم‌مرغ',
      aliases: ['تخم مرغ', 'تخم‌مرغ'],
      unit: _FoodUnit.item,
      baseAmount: 1,
      defaultAmount: 1,
      calories: 70,
      protein: 6,
      carbs: 0.5,
      fat: 5),
  _MockFood(
      name: 'مرغ',
      aliases: ['مرغ'],
      unit: _FoodUnit.gram,
      baseAmount: 100,
      defaultAmount: 100,
      calories: 190,
      protein: 27,
      carbs: 0,
      fat: 7),
  _MockFood(
      name: 'گوشت',
      aliases: ['گوشت'],
      unit: _FoodUnit.gram,
      baseAmount: 100,
      defaultAmount: 100,
      calories: 250,
      protein: 26,
      carbs: 0,
      fat: 15),
  _MockFood(
      name: 'شیر',
      aliases: ['شیر'],
      unit: _FoodUnit.milliliter,
      baseAmount: 100,
      defaultAmount: 250,
      calories: 47,
      protein: 3.4,
      carbs: 4.8,
      fat: 1.5),
  _MockFood(
      name: 'ماست',
      aliases: ['ماست'],
      unit: _FoodUnit.gram,
      baseAmount: 100,
      defaultAmount: 100,
      calories: 61,
      protein: 3.5,
      carbs: 4.7,
      fat: 3.3),
  _MockFood(
      name: 'موز',
      aliases: ['موز'],
      unit: _FoodUnit.item,
      baseAmount: 1,
      defaultAmount: 1,
      calories: 105,
      protein: 1.3,
      carbs: 27,
      fat: 0.4),
  _MockFood(
      name: 'سیب',
      aliases: ['سیب'],
      unit: _FoodUnit.item,
      baseAmount: 1,
      defaultAmount: 1,
      calories: 95,
      protein: 0.5,
      carbs: 25,
      fat: 0.3),
  _MockFood(
      name: 'خرما',
      aliases: ['خرما'],
      unit: _FoodUnit.item,
      baseAmount: 1,
      defaultAmount: 1,
      calories: 23,
      protein: 0.2,
      carbs: 6,
      fat: 0),
  _MockFood(
      name: 'گردو',
      aliases: ['گردو'],
      unit: _FoodUnit.item,
      baseAmount: 1,
      defaultAmount: 1,
      calories: 26,
      protein: 0.6,
      carbs: 0.6,
      fat: 2.6),
  _MockFood(
      name: 'بادام',
      aliases: ['بادام'],
      unit: _FoodUnit.item,
      baseAmount: 10,
      defaultAmount: 10,
      calories: 70,
      protein: 2.6,
      carbs: 2.6,
      fat: 6),
  _MockFood(
      name: 'پنیر',
      aliases: ['پنیر'],
      unit: _FoodUnit.gram,
      baseAmount: 30,
      defaultAmount: 30,
      calories: 80,
      protein: 5,
      carbs: 1,
      fat: 6),
  _MockFood(
      name: 'وی پروتئین',
      aliases: ['وی پروتئین', 'پروتئین وی', 'whey'],
      unit: _FoodUnit.scoop,
      baseAmount: 1,
      defaultAmount: 1,
      calories: 120,
      protein: 24,
      carbs: 3,
      fat: 2),
];
