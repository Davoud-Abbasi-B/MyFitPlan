import '../models/food_analysis_result.dart';

abstract interface class FoodAnalysisService {
  Future<FoodAnalysisBatchResult> analyze(String input);
}

class FoodNotRecognizedException implements Exception {
  const FoodNotRecognizedException();
}

enum FoodAnalysisErrorType {
  network,
  unauthorized,
  rateLimited,
  badRequest,
  unavailable,
  malformed,
  unknown,
}

class FoodAnalysisException implements Exception {
  const FoodAnalysisException(this.type);

  final FoodAnalysisErrorType type;
}

String foodAnalysisErrorMessage(Object error) {
  final type = error is FoodAnalysisException
      ? error.type
      : FoodAnalysisErrorType.unknown;
  return switch (type) {
    FoodAnalysisErrorType.network =>
      'ارتباط با سرویس محاسبه برقرار نشد. دوباره تلاش کنید.',
    FoodAnalysisErrorType.unauthorized => 'کلید سرویس معتبر نیست.',
    FoodAnalysisErrorType.rateLimited =>
      'تعداد درخواست‌ها زیاد بوده یا اعتبار حساب کافی نیست. کمی بعد دوباره تلاش کنید.',
    FoodAnalysisErrorType.badRequest => 'درخواست محاسبه معتبر نبود.',
    FoodAnalysisErrorType.unavailable => 'سرویس محاسبه موقتاً در دسترس نیست.',
    FoodAnalysisErrorType.malformed => 'پاسخ سرویس قابل پردازش نبود.',
    FoodAnalysisErrorType.unknown => 'در محاسبه اطلاعات غذایی خطایی رخ داد.',
  };
}
