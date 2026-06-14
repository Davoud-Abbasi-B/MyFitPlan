import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/craving_log_model.dart';

final cravingLogsProvider =
    AsyncNotifierProvider<CravingLogsNotifier, List<CravingLog>>(
  CravingLogsNotifier.new,
);

class CravingLogsNotifier extends AsyncNotifier<List<CravingLog>> {
  @override
  Future<List<CravingLog>> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.loadCravingLogs();
  }

  Future<void> addLog(CravingLog log) async {
    final current = state.valueOrNull ?? const <CravingLog>[];
    final updated = [log, ...current];
    state = AsyncData(updated);

    final storage = ref.read(localStorageServiceProvider);
    await storage.saveCravingLogs(updated);
  }
}
