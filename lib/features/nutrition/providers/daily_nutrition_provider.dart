import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/daily_nutrition_model.dart';
import '../models/food_analysis_result.dart';
import '../services/food_analysis_service.dart';
import '../services/direct_openai_food_analysis_service.dart';
import '../services/mock_food_analysis_service.dart';

const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY');
const openAiModel = String.fromEnvironment(
  'OPENAI_MODEL',
  defaultValue: 'gpt-5-mini',
);
const isDirectOpenAiFoodAnalysisEnabled = openAiApiKey != '';

final foodAnalysisServiceProvider = Provider<FoodAnalysisService>(
  (ref) => createFoodAnalysisService(
    apiKey: openAiApiKey,
    model: openAiModel,
  ),
);

FoodAnalysisService createFoodAnalysisService({
  required String apiKey,
  String model = 'gpt-5-mini',
  FoodAnalysisHttpTransport transport = const IoFoodAnalysisHttpTransport(),
}) {
  if (apiKey.trim().isEmpty) return const MockFoodAnalysisService();
  return DirectOpenAiFoodAnalysisService(
    apiKey: apiKey,
    model: model,
    transport: transport,
  );
}

class FoodConfirmationGuard {
  bool _confirmed = false;

  bool tryConfirm() {
    if (_confirmed) return false;
    _confirmed = true;
    return true;
  }
}

enum NutritionReportSubmissionResult { submitted, duplicate, empty }

class DailyNutritionState {
  const DailyNutritionState({
    required this.dateKey,
    required this.entries,
    required this.dayType,
    required this.isSubmitted,
  });

  final String dateKey;
  final List<DailyNutritionEntry> entries;
  final NutritionDayType dayType;
  final bool isSubmitted;

  DailyNutritionTotals get totals => DailyNutritionTotals.fromEntries(entries);

  DailyNutritionState copyWith({
    List<DailyNutritionEntry>? entries,
    bool? isSubmitted,
  }) {
    return DailyNutritionState(
      dateKey: dateKey,
      entries: entries ?? this.entries,
      dayType: dayType,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

final dailyNutritionProvider =
    AsyncNotifierProvider<DailyNutritionNotifier, DailyNutritionState>(
  DailyNutritionNotifier.new,
);

class DailyNutritionNotifier extends AsyncNotifier<DailyNutritionState> {
  bool _submissionInProgress = false;

  @override
  Future<DailyNutritionState> build() async {
    final now = DateTime.now();
    final dateKey = nutritionDateKey(now);
    final storage = ref.watch(localStorageServiceProvider);
    final entries = await storage.loadDailyNutritionDraft(dateKey);
    final reports = await storage.loadDailyNutritionReports();
    return DailyNutritionState(
      dateKey: dateKey,
      entries: entries,
      dayType: nutritionDayTypeForDate(now),
      isSubmitted: reports.any((report) => report.dateKey == dateKey),
    );
  }

  Future<void> addAnalysis(FoodAnalysisResult result) async {
    await addAnalyses([result]);
  }

  Future<void> addAnalyses(List<FoodAnalysisResult> results) async {
    final current = state.valueOrNull;
    if (current == null || results.isEmpty) return;
    final entries = dailyNutritionEntriesFromAnalyses(
      results,
      dateKey: current.dateKey,
    );
    await _saveDraft(
      current.copyWith(entries: [...current.entries, ...entries]),
    );
  }

  Future<void> deleteEntry(String entryId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await _saveDraft(
      current.copyWith(
        entries: current.entries
            .where((entry) => entry.id != entryId)
            .toList(growable: false),
      ),
    );
  }

  Future<NutritionReportSubmissionResult> submitReport() async {
    final current = state.valueOrNull;
    if (current == null || current.entries.isEmpty) {
      return NutritionReportSubmissionResult.empty;
    }
    if (current.isSubmitted) {
      return NutritionReportSubmissionResult.duplicate;
    }
    if (_submissionInProgress) {
      return NutritionReportSubmissionResult.duplicate;
    }
    _submissionInProgress = true;
    final report = DailyNutritionReport.fromEntries(
      dateKey: current.dateKey,
      entries: current.entries,
      dayType: current.dayType,
    );
    late final bool saved;
    try {
      saved = await ref
          .read(localStorageServiceProvider)
          .saveDailyNutritionReport(report);
    } finally {
      _submissionInProgress = false;
    }
    if (!saved) {
      state = AsyncData(current.copyWith(isSubmitted: true));
      return NutritionReportSubmissionResult.duplicate;
    }
    state = AsyncData(current.copyWith(isSubmitted: true));
    ref.invalidate(nutritionReportHistoryProvider);
    return NutritionReportSubmissionResult.submitted;
  }

  Future<void> _saveDraft(DailyNutritionState updated) async {
    state = AsyncData(updated);
    await ref
        .read(localStorageServiceProvider)
        .saveDailyNutritionDraft(updated.dateKey, updated.entries);
  }
}

List<DailyNutritionEntry> dailyNutritionEntriesFromAnalyses(
  List<FoodAnalysisResult> results, {
  required String dateKey,
  DateTime? createdAt,
}) {
  final timestamp = createdAt ?? DateTime.now();
  return results.indexed
      .map(
        (indexed) => DailyNutritionEntry.fromAnalysis(
          result: indexed.$2,
          dateKey: dateKey,
          createdAt: timestamp.add(Duration(microseconds: indexed.$1)),
        ),
      )
      .toList(growable: false);
}

final nutritionReportHistoryProvider = AsyncNotifierProvider<
    NutritionReportHistoryNotifier, List<DailyNutritionReport>>(
  NutritionReportHistoryNotifier.new,
);

class NutritionReportHistoryNotifier
    extends AsyncNotifier<List<DailyNutritionReport>> {
  @override
  Future<List<DailyNutritionReport>> build() {
    return ref.watch(localStorageServiceProvider).loadDailyNutritionReports();
  }

  Future<void> deleteReport(String dateKey) async {
    await ref
        .read(localStorageServiceProvider)
        .deleteDailyNutritionReport(dateKey);
    state = AsyncData(
      await ref.read(localStorageServiceProvider).loadDailyNutritionReports(),
    );
    final todayState = ref.read(dailyNutritionProvider).valueOrNull;
    if (todayState?.dateKey == dateKey) ref.invalidate(dailyNutritionProvider);
  }
}

NutritionDayType nutritionDayTypeForDate(DateTime date) {
  return switch (date.weekday) {
    DateTime.saturday ||
    DateTime.sunday ||
    DateTime.tuesday ||
    DateTime.wednesday =>
      NutritionDayType.training,
    _ => NutritionDayType.rest,
  };
}
