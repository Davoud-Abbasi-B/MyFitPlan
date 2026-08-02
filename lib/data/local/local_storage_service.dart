import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/date_utils.dart';
import '../../features/checklist/models/daily_checklist_model.dart';
import '../../features/craving/models/craving_log_model.dart';
import '../../features/nutrition/models/meal_plan_model.dart';
import '../../features/nutrition/models/daily_nutrition_model.dart';
import '../../features/nutrition/models/nutrition_log_model.dart';
import '../../features/progress/models/body_progress_model.dart';
import '../../features/settings/models/user_profile_model.dart';
import '../../features/supplements/models/supplement_log_model.dart';
import '../../features/supplements/models/supplement_model.dart';
import '../../features/supplements/models/supplement_reminder_settings_model.dart';
import '../../features/workout/models/workout_day_model.dart';
import '../../features/workout/models/workout_log_model.dart';
import '../../features/workout/models/workout_session_model.dart';
import 'app_snapshot.dart';
import 'default_seed_data.dart';
import 'hive_boxes.dart';
import 'storage_keys.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  late Box _box;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(HiveBoxes.app);
  }

  Future<void> seedDefaultsIfNeeded() async {
    final seeded = _box.get(StorageKeys.seeded, defaultValue: false) as bool;
    if (seeded) return;

    await _box.put(StorageKeys.profile, DefaultSeedData.profile().toJson());
    await _box.put(
      StorageKeys.workouts,
      DefaultSeedData.workouts().map((item) => item.toJson()).toList(),
    );
    await _box.put(
      StorageKeys.workoutSeedVersion,
      DefaultSeedData.workoutSeedVersion,
    );
    await _box.put(
      StorageKeys.meals,
      DefaultSeedData.mealPlans().map((item) => item.toJson()).toList(),
    );
    await _box.put(
      StorageKeys.supplements,
      DefaultSeedData.supplements().map((item) => item.toJson()).toList(),
    );
    await _box.put(
      StorageKeys.progress,
      DefaultSeedData.progressEntries().map((item) => item.toJson()).toList(),
    );
    await saveChecklist(DefaultSeedData.checklistForToday());
    await _box.put(StorageKeys.seeded, true);
  }

  Future<AppSnapshot> loadSnapshot() async {
    await ensureWorkoutPlanCurrent();

    final profileMap = Map<String, dynamic>.from(
      _box.get(StorageKeys.profile) as Map,
    );
    final workoutsList = _mapList(StorageKeys.workouts);
    final mealsList = _mapList(StorageKeys.meals);
    final supplementsList = _mapList(StorageKeys.supplements);
    final progressList = _mapList(StorageKeys.progress);

    final checklist = await loadChecklistForToday();

    return AppSnapshot(
      profile: UserProfile.fromJson(profileMap),
      workouts: workoutsList.map(WorkoutDay.fromJson).toList(),
      mealPlans: mealsList.map(MealPlan.fromJson).toList(),
      supplements: supplementsList.map(Supplement.fromJson).toList(),
      progressEntries: progressList.map(BodyProgress.fromJson).toList(),
      todayChecklist: checklist,
    );
  }

  Future<DailyChecklist> loadChecklistForToday() async {
    final stored = _box.get(StorageKeys.checklist);
    if (stored is Map) {
      final checklist =
          DailyChecklist.fromJson(Map<String, dynamic>.from(stored));
      final todayKey = AppDateUtils.dateKey(DateTime.now());

      if (AppDateUtils.dateKey(checklist.date) == todayKey) {
        return checklist;
      }
    }

    final freshChecklist = DefaultSeedData.checklistForToday();
    await saveChecklist(freshChecklist);
    return freshChecklist;
  }

  Future<void> saveChecklist(DailyChecklist checklist) async {
    await _box.put(StorageKeys.checklist, checklist.toJson());
    final history = await loadChecklistHistory();
    final key = AppDateUtils.dateKey(checklist.date);
    final index = history.indexWhere(
      (entry) => AppDateUtils.dateKey(entry.date) == key,
    );

    if (index >= 0) {
      history[index] = checklist;
    } else {
      history.add(checklist);
    }

    history.sort((a, b) => a.date.compareTo(b.date));
    await _box.put(
      StorageKeys.checklistHistory,
      history.map((entry) => entry.toJson()).toList(),
    );
  }

  Future<List<DailyChecklist>> loadChecklistHistory() async {
    final list = _mapList(StorageKeys.checklistHistory);
    final history = list.map(DailyChecklist.fromJson).toList();
    history.sort((a, b) => a.date.compareTo(b.date));
    return history;
  }

  Future<List<BodyProgress>> loadProgressEntries() async {
    final progressList = _mapList(StorageKeys.progress);
    final entries = progressList.map(BodyProgress.fromJson).toList();
    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  Future<List<BodyProgress>> upsertTodayProgress({
    required double weightKg,
    required double waistCm,
    required int? steps,
    required String? note,
  }) async {
    final entries = await loadProgressEntries();
    final todayKey = AppDateUtils.dateKey(DateTime.now());
    final existingIndex = entries.indexWhere(
      (entry) => AppDateUtils.dateKey(entry.date) == todayKey,
    );

    final updatedEntry = BodyProgress(
      id: existingIndex >= 0 ? entries[existingIndex].id : 'progress-$todayKey',
      date: DateTime.now(),
      weightKg: weightKg,
      waistCm: waistCm,
      steps: steps,
      note: note,
    );

    if (existingIndex >= 0) {
      entries[existingIndex] = updatedEntry;
    } else {
      entries.add(updatedEntry);
    }

    entries.sort((a, b) => a.date.compareTo(b.date));
    await _box.put(
      StorageKeys.progress,
      entries.map((entry) => entry.toJson()).toList(),
    );
    return entries;
  }

  Future<List<MealPlan>> loadMealPlans() async {
    final mealsList = _mapList(StorageKeys.meals);
    return mealsList.map(MealPlan.fromJson).toList();
  }

  Future<List<Supplement>> loadSupplements() async {
    final supplementsList = _mapList(StorageKeys.supplements);
    return supplementsList.map(Supplement.fromJson).toList();
  }

  Future<NutritionLog> loadNutritionLogForToday(
      List<MealPlan> mealPlans) async {
    final stored = _box.get(StorageKeys.nutritionLog);
    if (stored is Map) {
      final nutritionLog =
          NutritionLog.fromJson(Map<String, dynamic>.from(stored));
      final todayKey = AppDateUtils.dateKey(DateTime.now());

      if (AppDateUtils.dateKey(nutritionLog.date) == todayKey) {
        return nutritionLog;
      }
    }

    final freshLog = NutritionLog(
      date: DateTime.now(),
      completedMealIds: const [],
      selectedSnackOption: null,
    );
    await saveNutritionLog(freshLog);
    return freshLog;
  }

  Future<void> saveNutritionLog(NutritionLog nutritionLog) async {
    await _box.put(StorageKeys.nutritionLog, nutritionLog.toJson());
  }

  Future<List<DailyNutritionEntry>> loadDailyNutritionDraft(
    String dateKey,
  ) async {
    final drafts = _mapValue(StorageKeys.dailyNutritionDrafts);
    final rawEntries = drafts[dateKey];
    if (rawEntries is! List) return const [];
    return rawEntries
        .whereType<Map>()
        .map((entry) => DailyNutritionEntry.fromJson(
              Map<String, dynamic>.from(entry),
            ))
        .toList(growable: false);
  }

  Future<void> saveDailyNutritionDraft(
    String dateKey,
    List<DailyNutritionEntry> entries,
  ) async {
    final drafts = _mapValue(StorageKeys.dailyNutritionDrafts);
    drafts[dateKey] = entries.map((entry) => entry.toJson()).toList();
    await _box.put(StorageKeys.dailyNutritionDrafts, drafts);
  }

  Future<List<DailyNutritionReport>> loadDailyNutritionReports() async {
    final reports = _mapList(StorageKeys.dailyNutritionReports)
        .map(DailyNutritionReport.fromJson)
        .toList();
    reports.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return reports;
  }

  Future<bool> saveDailyNutritionReport(
    DailyNutritionReport report,
  ) async {
    final reports = await loadDailyNutritionReports();
    if (!canSubmitNutritionReport(reports, report.dateKey)) return false;
    reports.add(report);
    reports.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    await _box.put(
      StorageKeys.dailyNutritionReports,
      reports.map((item) => item.toJson()).toList(),
    );
    return true;
  }

  Future<void> deleteDailyNutritionReport(String dateKey) async {
    final reports = await loadDailyNutritionReports();
    reports.removeWhere((report) => report.dateKey == dateKey);
    await _box.put(
      StorageKeys.dailyNutritionReports,
      reports.map((item) => item.toJson()).toList(),
    );
  }

  Future<List<CravingLog>> loadCravingLogs() async {
    final logs = _mapList(StorageKeys.cravingLogs);
    return logs.map(CravingLog.fromJson).toList();
  }

  Future<void> saveCravingLogs(List<CravingLog> logs) async {
    await _box.put(
      StorageKeys.cravingLogs,
      logs.map((log) => log.toJson()).toList(),
    );
  }

  Future<SupplementLog> loadSupplementLogForToday() async {
    final stored = _box.get(StorageKeys.supplementLog);
    if (stored is Map) {
      final log = SupplementLog.fromJson(Map<String, dynamic>.from(stored));
      final todayKey = AppDateUtils.dateKey(DateTime.now());
      if (AppDateUtils.dateKey(log.date) == todayKey) {
        return log;
      }
    }

    final freshLog = SupplementLog(
      date: DateTime.now(),
      takenSupplementIds: const [],
    );
    await saveSupplementLog(freshLog);
    return freshLog;
  }

  Future<void> saveSupplementLog(SupplementLog log) async {
    await _box.put(StorageKeys.supplementLog, log.toJson());
  }

  Future<SupplementReminderSettings> loadSupplementReminderSettings() async {
    final stored = _box.get(StorageKeys.supplementReminderSettings);
    if (stored is Map) {
      return SupplementReminderSettings.fromJson(
        Map<String, dynamic>.from(stored),
      );
    }

    const settings = SupplementReminderSettings(vitaminDEnabled: false);
    await saveSupplementReminderSettings(settings);
    return settings;
  }

  Future<void> saveSupplementReminderSettings(
    SupplementReminderSettings settings,
  ) async {
    await _box.put(StorageKeys.supplementReminderSettings, settings.toJson());
  }

  Future<WorkoutLog> loadWorkoutLogForToday(WorkoutDay workoutDay) async {
    final key = _workoutLogEntryKey(workoutDay.id);
    final storedLogs = _mapValue(StorageKeys.workoutLogs);
    final storedLog = storedLogs[key];

    if (storedLog is Map) {
      final existing =
          WorkoutLog.fromJson(Map<String, dynamic>.from(storedLog));
      final merged = _mergeWorkoutLogWithDay(existing, workoutDay);
      if (merged != existing) {
        await saveWorkoutLog(merged);
      }
      return merged;
    }

    final freshLog = WorkoutLog.createForToday(workoutDay);
    await saveWorkoutLog(freshLog);
    return freshLog;
  }

  Future<void> saveWorkoutLog(WorkoutLog workoutLog) async {
    final storedLogs = _mapValue(StorageKeys.workoutLogs);
    storedLogs[_workoutLogEntryKey(workoutLog.workoutDayId)] =
        workoutLog.toJson();
    await _box.put(StorageKeys.workoutLogs, storedLogs);
  }

  Future<List<WorkoutSession>> loadWorkoutSessions() async {
    final sessions = _mapList(StorageKeys.workoutSessions)
        .map(WorkoutSession.fromJson)
        .toList();
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return sessions;
  }

  Future<bool> saveWorkoutSession(WorkoutSession session) async {
    final sessions = await loadWorkoutSessions();
    final duplicate = sessions.any(
      (existing) =>
          existing.dateKey == session.dateKey &&
          existing.workoutDayNumber == session.workoutDayNumber,
    );
    if (duplicate) return false;

    sessions.add(session);
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    await _box.put(
      StorageKeys.workoutSessions,
      sessions.map((item) => item.toJson()).toList(),
    );
    return true;
  }

  Future<void> deleteWorkoutSession(String sessionId) async {
    final sessions = await loadWorkoutSessions();
    sessions.removeWhere((session) => session.id == sessionId);
    await _box.put(
      StorageKeys.workoutSessions,
      sessions.map((item) => item.toJson()).toList(),
    );
  }

  Future<void> ensureWorkoutPlanCurrent() async {
    final storedVersion = _box.get(
      StorageKeys.workoutSeedVersion,
      defaultValue: 0,
    ) as int;
    final storedWorkouts = _mapList(StorageKeys.workouts);
    if (storedVersion >= DefaultSeedData.workoutSeedVersion &&
        _hasCurrentWorkoutPlan(storedWorkouts)) {
      return;
    }

    await _box.put(
      StorageKeys.workouts,
      DefaultSeedData.workouts().map((item) => item.toJson()).toList(),
    );
    await _box.put(
      StorageKeys.workoutSeedVersion,
      DefaultSeedData.workoutSeedVersion,
    );
  }

  List<Map<String, dynamic>> _mapList(String key) {
    final value = _box.get(key, defaultValue: <dynamic>[]) as List<dynamic>;
    return value.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Map<String, dynamic> _mapValue(String key) {
    final value = _box.get(key, defaultValue: <String, dynamic>{});
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  String _workoutLogEntryKey(String workoutDayId) {
    return '${AppDateUtils.dateKey(DateTime.now())}:$workoutDayId';
  }

  bool _hasCurrentWorkoutPlan(List<Map<String, dynamic>> storedWorkouts) {
    final expectedWorkouts = DefaultSeedData.workouts();
    if (storedWorkouts.length != expectedWorkouts.length) {
      return false;
    }

    final storedById = {
      for (final workout in storedWorkouts) workout['id'] as String: workout,
    };

    for (final expected in expectedWorkouts) {
      final stored = storedById[expected.id];
      if (stored == null) {
        return false;
      }

      if (stored['title'] != expected.title ||
          stored['focus'] != expected.focus ||
          stored['dayNumber'] != expected.dayNumber) {
        return false;
      }

      final storedExercises =
          (stored['exercises'] as List<dynamic>? ?? const [])
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      if (storedExercises.length != expected.exercises.length) {
        return false;
      }

      for (var index = 0; index < expected.exercises.length; index++) {
        final storedExercise = storedExercises[index];
        final expectedExercise = expected.exercises[index];
        if (storedExercise['id'] != expectedExercise.id ||
            storedExercise['name'] != expectedExercise.name) {
          return false;
        }
      }
    }

    return true;
  }

  WorkoutLog _mergeWorkoutLogWithDay(
      WorkoutLog existing, WorkoutDay workoutDay) {
    final existingById = {
      for (final log in existing.exerciseLogs) log.exerciseId: log,
    };
    var hasChanges =
        existing.exerciseLogs.length != workoutDay.exercises.length;

    final mergedExerciseLogs = workoutDay.exercises.map((exercise) {
      final current = existingById[exercise.id];
      if (current != null) {
        final needsUpdate = current.name != exercise.name ||
            current.type != exercise.type ||
            current.plannedSets != exercise.sets ||
            current.plannedReps != exercise.reps ||
            (current.durationMinutes == null &&
                exercise.targetDurationMinutes != null) ||
            (current.durationSeconds == null &&
                exercise.targetDurationSeconds != null);
        if (needsUpdate) {
          hasChanges = true;
        }
        return current.copyWith(
          name: exercise.name,
          type: exercise.type,
          plannedSets: exercise.sets,
          plannedReps: exercise.reps,
          durationMinutes:
              current.durationMinutes ?? exercise.targetDurationMinutes,
          durationSeconds:
              current.durationSeconds ?? exercise.targetDurationSeconds,
        );
      }

      hasChanges = true;
      return ExerciseLog(
        exerciseId: exercise.id,
        name: exercise.name,
        type: exercise.type,
        plannedSets: exercise.sets,
        plannedReps: exercise.reps,
        completed: false,
        durationMinutes: exercise.targetDurationMinutes,
        durationSeconds: exercise.targetDurationSeconds,
      );
    }).toList();

    if (!hasChanges) {
      return existing;
    }

    return existing.copyWith(exerciseLogs: mergedExerciseLogs);
  }
}
