import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/daily_nutrition_model.dart';
import '../models/food_analysis_result.dart';
import '../services/food_analysis_service.dart';
import '../services/food_name_translation_service.dart';
import '../services/food_search_cache_service.dart';
import '../services/hybrid_food_analysis_service.dart';
import '../services/local_food_database_service.dart';
import '../services/persian_food_parser.dart';
import '../services/usda_food_data_service.dart';

const usdaApiKey = String.fromEnvironment('USDA_API_KEY');
const isUsdaFoodSearchEnabled = usdaApiKey != '';

final localFoodDatabaseProvider = Provider<LocalFoodDatabaseService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return LocalFoodDatabaseService(customFoodLoader: storage.loadCustomFoods);
});

final foodSearchCacheProvider = Provider<FoodSearchCacheService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return CallbackFoodSearchCacheService(
    loader: storage.loadUsdaFoodSearchCache,
    saver: storage.saveUsdaFoodSearchCache,
    clearer: storage.clearUsdaFoodSearchCache,
  );
});

class TranslationUiController extends Notifier<TranslationUiState> {
  @override
  TranslationUiState build() => const TranslationUiState();

  void operationStarted({bool downloading = false}) {
    state = state.copyWith(
      status: downloading
          ? TranslationModelStatus.downloading
          : state.status == TranslationModelStatus.ready
              ? TranslationModelStatus.ready
              : TranslationModelStatus.unknown,
      clearDiagnostic: true,
    );
  }

  void applyServiceStatus(TranslationModelStatus status) {
    state = state.copyWith(
      status: status,
      clearDiagnostic: status == TranslationModelStatus.downloading ||
          status == TranslationModelStatus.ready,
      translatorInitialized:
          status == TranslationModelStatus.ready || state.translatorInitialized,
    );
  }

  void failed(TranslationModelStatus status, String diagnostic) {
    assert(status != TranslationModelStatus.ready);
    state = TranslationUiState(
      status: status,
      diagnostic: diagnostic,
      translatorInitialized: state.translatorInitialized,
    );
  }

  void succeeded() {
    state = const TranslationUiState(
      status: TranslationModelStatus.ready,
      translatorInitialized: true,
    );
  }

  void screenOpened() {
    if (state.status == TranslationModelStatus.downloading || state.isReady) {
      state = state.copyWith(clearDiagnostic: true);
      return;
    }
    state = const TranslationUiState();
  }
}

final translationUiStateProvider =
    NotifierProvider<TranslationUiController, TranslationUiState>(
  TranslationUiController.new,
);

final translationModelStatusProvider = Provider<TranslationModelStatus>(
  (ref) => ref.watch(translationUiStateProvider).status,
);

final foodTranslationCacheProvider = Provider<FoodTranslationCacheService>(
  (ref) {
    final storage = ref.watch(localStorageServiceProvider);
    return CallbackFoodTranslationCacheService(
      loader: storage.loadFoodTranslationCache,
      saver: storage.saveFoodTranslationCache,
    );
  },
);

final foodNameTranslationServiceProvider = Provider<FoodNameTranslationService>(
  (ref) => CachedFoodNameTranslationService(
    cache: ref.watch(foodTranslationCacheProvider),
    onDeviceTranslator: const MethodChannelFoodNameTranslator(),
    onStatusChanged: (status) {
      ref.read(translationUiStateProvider.notifier).applyServiceStatus(status);
    },
  ),
);

final hybridFoodAnalysisServiceProvider = Provider<HybridFoodAnalysisService>(
  (ref) => HybridFoodAnalysisService(
    parser: const PersianFoodParser(),
    localDatabase: ref.watch(localFoodDatabaseProvider),
    usda: const UsdaFoodDataService(apiKey: usdaApiKey),
    cache: ref.watch(foodSearchCacheProvider),
    translation: ref.watch(foodNameTranslationServiceProvider),
  ),
);

final foodAnalysisServiceProvider = Provider<FoodAnalysisService>(
  (ref) => ref.watch(hybridFoodAnalysisServiceProvider),
);

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
