import '../models/food_analysis_result.dart';

abstract interface class FoodAnalysisService {
  Future<FoodAnalysisResult> analyze(String input);
}

class FoodNotRecognizedException implements Exception {
  const FoodNotRecognizedException();
}
