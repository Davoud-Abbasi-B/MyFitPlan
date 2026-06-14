import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/body_progress_model.dart';

final progressEntriesProvider =
    AsyncNotifierProvider<ProgressEntriesNotifier, List<BodyProgress>>(
  ProgressEntriesNotifier.new,
);

class ProgressEntriesNotifier extends AsyncNotifier<List<BodyProgress>> {
  @override
  Future<List<BodyProgress>> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.loadProgressEntries();
  }

  Future<void> saveTodayProgress({
    required double weightKg,
    required double waistCm,
    required int? steps,
    required String? note,
  }) async {
    final storage = ref.read(localStorageServiceProvider);
    final updated = await storage.upsertTodayProgress(
      weightKg: weightKg,
      waistCm: waistCm,
      steps: steps,
      note: note,
    );
    state = AsyncData(updated);
  }
}
