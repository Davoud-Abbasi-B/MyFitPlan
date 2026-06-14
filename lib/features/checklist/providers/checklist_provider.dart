import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/daily_checklist_model.dart';

final todayChecklistProvider =
    AsyncNotifierProvider<TodayChecklistNotifier, DailyChecklist>(
  TodayChecklistNotifier.new,
);

final checklistHistoryProvider =
    AsyncNotifierProvider<ChecklistHistoryNotifier, List<DailyChecklist>>(
  ChecklistHistoryNotifier.new,
);

class TodayChecklistNotifier extends AsyncNotifier<DailyChecklist> {
  @override
  Future<DailyChecklist> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.loadChecklistForToday();
  }

  Future<void> setItem(ChecklistItemKey key, bool value) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final updated = current.withValue(key, value);
    state = AsyncData(updated);

    final storage = ref.read(localStorageServiceProvider);
    await storage.saveChecklist(updated);
    ref.invalidate(checklistHistoryProvider);
  }
}

class ChecklistHistoryNotifier extends AsyncNotifier<List<DailyChecklist>> {
  @override
  Future<List<DailyChecklist>> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.loadChecklistHistory();
  }
}
