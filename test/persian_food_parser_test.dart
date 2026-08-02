import 'package:flutter_test/flutter_test.dart';
import 'package:my_fit_plan/features/nutrition/services/persian_food_parser.dart';

void main() {
  const parser = PersianFoodParser();

  test('parses two Persian foods with Persian digits', () {
    final foods = parser.parse('۱۰ گرم پنیر لیقوان و ۵۰ گرم نان بربری');
    expect(foods, hasLength(2));
    expect(foods[0].quantity, 10);
    expect(foods[0].unit, FoodUnit.gram);
    expect(foods[0].normalizedFoodName, 'پنیر لیقوان');
    expect(foods[1].quantity, 50);
    expect(foods[1].normalizedFoodName, 'نان بربری');
  });

  test('normalizes Arabic digits, decimals, words, and kilograms', () {
    expect(parser.parse('١٫٥ کیلوگرم سینه مرغ').single.quantity, 1.5);
    expect(parser.parse('٢ عدد تخم‌مرغ').single.quantity, 2);
    expect(parser.parse('نیم لیوان شیر').single.quantity, 0.5);
    expect(parser.parse('سه‌چهارم پیمانه جو دوسر').single.quantity, 0.75);
    expect(parser.parse('یک کیلوگرم برنج').single.unit, FoodUnit.kilogram);
  });

  test('handles Persian separators', () {
    final foods = parser.parse(
      '۲ عدد تخم‌مرغ، یک لیوان شیر + ۱۰۰ گرم برنج به‌همراه ۵۰ گرم مرغ',
    );
    expect(foods, hasLength(4));
    final withFood = parser.parse(
      '۱۵۰ گرم سینه مرغ با ۲۰۰ گرم برنج پخته',
    );
    expect(withFood, hasLength(2));
    expect(withFood.last.normalizedFoodName, 'برنج پخته');
  });

  test('marks missing quantity and unsupported unit', () {
    expect(parser.parse('نان بربری').single.isQuantityAmbiguous, isTrue);
    final unsupported = parser.parse('۲ مشت بادام').single;
    expect(unsupported.hasUnsupportedUnit, isTrue);
    expect(unsupported.normalizedFoodName, 'بادام');
  });
}
