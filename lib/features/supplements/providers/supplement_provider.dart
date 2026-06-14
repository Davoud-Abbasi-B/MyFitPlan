import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/supplement_log_model.dart';
import '../models/supplement_model.dart';
import '../models/supplement_reminder_settings_model.dart';
import '../services/supplement_reminder_service.dart';

final supplementsStateProvider =
    AsyncNotifierProvider<SupplementsStateNotifier, SupplementsState>(
  SupplementsStateNotifier.new,
);

class SupplementsState {
  const SupplementsState({
    required this.supplements,
    required this.todayLog,
    required this.reminderSettings,
  });

  final List<Supplement> supplements;
  final SupplementLog todayLog;
  final SupplementReminderSettings reminderSettings;

  int get remainingWeeks {
    final activatedAt = reminderSettings.activatedAt;
    if (!reminderSettings.vitaminDEnabled || activatedAt == null) {
      return 0;
    }

    var remaining = 0;
    final firstReminder = _nextSundayAtNoon(activatedAt);
    for (var index = 0; index < reminderSettings.totalWeeks; index++) {
      final reminderDate = firstReminder.add(Duration(days: 7 * index));
      if (!reminderDate.isBefore(DateTime.now())) {
        remaining++;
      }
    }
    return remaining;
  }

  String get reminderStatusText {
    if (!reminderSettings.vitaminDEnabled) {
      return 'یادآور غیرفعال است';
    }
    if (remainingWeeks <= 0) {
      return 'یادآور فعال است\nاگر اعلان نمایش داده نشد، مجوز اعلان گوشی را بررسی کن';
    }
    return 'یادآور فعال است - $remainingWeeks هفته باقی مانده\n'
        'اگر اعلان نمایش داده نشد، مجوز اعلان گوشی را بررسی کن';
  }

  SupplementsState copyWith({
    List<Supplement>? supplements,
    SupplementLog? todayLog,
    SupplementReminderSettings? reminderSettings,
  }) {
    return SupplementsState(
      supplements: supplements ?? this.supplements,
      todayLog: todayLog ?? this.todayLog,
      reminderSettings: reminderSettings ?? this.reminderSettings,
    );
  }
}

DateTime _nextSundayAtNoon(DateTime from) {
  final daysUntilSunday = (DateTime.sunday - from.weekday + 7) % 7;
  final candidate = DateTime(from.year, from.month, from.day, 12)
      .add(Duration(days: daysUntilSunday));

  if (!candidate.isAfter(from)) {
    return candidate.add(const Duration(days: 7));
  }

  return candidate;
}

class SupplementsStateNotifier extends AsyncNotifier<SupplementsState> {
  @override
  Future<SupplementsState> build() async {
    final storage = ref.watch(localStorageServiceProvider);
    final supplements = await storage.loadSupplements();
    final todayLog = await storage.loadSupplementLogForToday();
    final reminderSettings = await storage.loadSupplementReminderSettings();

    return SupplementsState(
      supplements: supplements,
      todayLog: todayLog,
      reminderSettings: reminderSettings,
    );
  }

  Future<void> toggleSupplement(String supplementId, bool taken) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final updatedIds = [...current.todayLog.takenSupplementIds];
    if (taken) {
      if (!updatedIds.contains(supplementId)) {
        updatedIds.add(supplementId);
      }
    } else {
      updatedIds.remove(supplementId);
    }

    final updatedLog = current.todayLog.copyWith(takenSupplementIds: updatedIds);
    final updatedState = current.copyWith(todayLog: updatedLog);
    state = AsyncData(updatedState);

    final storage = ref.read(localStorageServiceProvider);
    await storage.saveSupplementLog(updatedLog);
  }

  Future<void> setVitaminDReminderEnabled(bool enabled) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    final storage = ref.read(localStorageServiceProvider);
    final updatedSettings = current.reminderSettings.copyWith(
      vitaminDEnabled: enabled,
      activatedAt: enabled ? DateTime.now() : null,
      clearActivatedAt: !enabled,
    );

    state = AsyncData(
      current.copyWith(reminderSettings: updatedSettings),
    );
    await storage.saveSupplementReminderSettings(updatedSettings);

    final reminderService = SupplementReminderService.instance;
    if (enabled) {
      await reminderService.scheduleVitaminDReminders();
      return;
    }

    await reminderService.cancelVitaminDReminders();
  }
}
