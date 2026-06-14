import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_snapshot_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../checklist/models/daily_checklist_model.dart';
import '../../checklist/providers/checklist_provider.dart';
import '../../craving/widgets/craving_control_sheet.dart';
import '../../progress/models/body_progress_model.dart';
import '../../progress/providers/progress_provider.dart';
import '../../workout/models/workout_day_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(appSnapshotProvider);
    final checklistAsync = ref.watch(todayChecklistProvider);
    final checklistHistoryAsync = ref.watch(checklistHistoryProvider);
    final progressEntriesAsync = ref.watch(progressEntriesProvider);

    return AsyncSnapshotView(
      value: snapshot,
      builder: (data) {
        final checklist = checklistAsync.valueOrNull ?? data.todayChecklist;
        final checklistHistory =
            checklistHistoryAsync.valueOrNull ?? <DailyChecklist>[checklist];
        final progressEntries =
            progressEntriesAsync.valueOrNull ?? data.progressEntries;
        final latestProgress =
            progressEntries.isNotEmpty ? progressEntries.last : null;
        final firstProgress =
            progressEntries.isNotEmpty ? progressEntries.first : null;
        final todayWorkout = _workoutForToday(data.workouts, DateTime.now());
        final nextMeal = data.mealPlans.first.meals[2];

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text('امروز'),
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 64, 20, 0),
                  child: Text(
                    AppDateUtils.formattedToday(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _WelcomeCard(
                      score: checklist.score,
                      targetWeight: data.profile.targetWeightKg,
                    ),
                    const SizedBox(height: 16),
                    _TodayWorkoutCard(workout: todayWorkout),
                    const SizedBox(height: 16),
                    _ChecklistPreviewCard(
                      checklist: checklist,
                      onChanged: (key, value) async {
                        await ref
                            .read(todayChecklistProvider.notifier)
                            .setItem(key, value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _TrendSection(
                      checklist: checklist,
                      checklistHistory: checklistHistory,
                      firstProgress: firstProgress,
                      latestProgress: latestProgress,
                      progressEntries: progressEntries,
                    ),
                    const SizedBox(height: 16),
                    _NextMealCard(
                      title: nextMeal.title,
                      description: nextMeal.description,
                    ),
                    const SizedBox(height: 16),
                    _CravingQuickActionCard(
                      onTap: () => showCravingControlSheet(context),
                    ),
                    const SizedBox(height: 16),
                    _ProgressSummaryCard(progress: latestProgress),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.score,
    required this.targetWeight,
  });

  final int score;
  final double targetWeight;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('وضعیت امروز'),
          const SizedBox(height: 12),
          Text(
            'امروز روی نظم، عصرانه سالم و تکمیل تمرین تمرکز کن.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'امتیاز روز',
                  value:
                      '${AppDateUtils.toPersianDigits(score.toString())} از ۱۰۰',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'وزن هدف',
                  value: '${_formatNumber(targetWeight)} کیلو',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({required this.workout});

  final WorkoutDay? workout;

  @override
  Widget build(BuildContext context) {
    if (workout == null) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('تمرین امروز'),
            const SizedBox(height: 12),
            Text(
              'امروز روز استراحت است',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('تمرین امروز'),
          const SizedBox(height: 12),
          Text(
            workout!.displayScheduleLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            workout!.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '${workout!.focus} • ${AppDateUtils.toPersianDigits(workout!.exercises.length.toString())} حرکت • ${AppDateUtils.toPersianDigits(workout!.cardioMinutes.toString())} دقیقه هوازی',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistPreviewCard extends StatelessWidget {
  const _ChecklistPreviewCard({
    required this.checklist,
    required this.onChanged,
  });

  final DailyChecklist checklist;
  final Future<void> Function(ChecklistItemKey key, bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    final completedItems = _completedChecklistCount(checklist);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('چک‌لیست روزانه'),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: checklist.score / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 12),
          Text(
            '${AppDateUtils.toPersianDigits(completedItems.toString())} مورد از ۸ مورد کامل شده است',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          ..._checklistEntries.map(
            (entry) => CheckboxListTile(
              value: checklist.valueFor(entry.key),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                onChanged(entry.key, value);
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              title: Text(entry.title),
              subtitle: Text(
                '${AppDateUtils.toPersianDigits(entry.points.toString())} امتیاز',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _completedChecklistCount(DailyChecklist value) {
    final items = [
      value.workoutDone,
      value.enoughProtein,
      value.healthySnack,
      value.noSugaryDrink,
      value.supplementsDone,
      value.stepsDone,
      value.enoughWater,
      value.cravingControlled,
    ];

    return items.where((item) => item).length;
  }
}

class _TrendSection extends StatelessWidget {
  const _TrendSection({
    required this.checklist,
    required this.checklistHistory,
    required this.firstProgress,
    required this.latestProgress,
    required this.progressEntries,
  });

  final DailyChecklist checklist;
  final List<DailyChecklist> checklistHistory;
  final BodyProgress? firstProgress;
  final BodyProgress? latestProgress;
  final List<BodyProgress> progressEntries;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('روند پیشرفت'),
          const SizedBox(height: 12),
          _TrendCard(
            title: 'روند امتیاز روزانه',
            latestValue:
                '${AppDateUtils.toPersianDigits(checklist.score.toString())} از ۱۰۰',
            changeValue: _scoreChangeLabel(checklistHistory),
            values: checklistHistory.map((item) => item.score.toDouble()).toList(),
            emptyMessage: 'هنوز سابقه کافی برای نمایش روند امتیاز وجود ندارد.',
            maxValue: 100,
          ),
          const SizedBox(height: 12),
          _TrendCard(
            title: 'روند وزن',
            latestValue: latestProgress == null
                ? 'ثبت نشده'
                : '${_formatNumber(latestProgress!.weightKg)} کیلوگرم',
            changeValue: _progressChangeLabel(
              firstProgress?.weightKg,
              latestProgress?.weightKg,
              'کیلوگرم',
            ),
            values: progressEntries.map((entry) => entry.weightKg).toList(),
            emptyMessage: 'هنوز سابقه کافی برای نمایش روند وزن وجود ندارد.',
          ),
          const SizedBox(height: 12),
          _TrendCard(
            title: 'روند دور شکم',
            latestValue: latestProgress == null
                ? 'ثبت نشده'
                : '${_formatNumber(latestProgress!.waistCm)} سانتی‌متر',
            changeValue: _progressChangeLabel(
              firstProgress?.waistCm,
              latestProgress?.waistCm,
              'سانتی‌متر',
            ),
            values: progressEntries.map((entry) => entry.waistCm).toList(),
            emptyMessage: 'هنوز سابقه کافی برای نمایش روند دور شکم وجود ندارد.',
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.latestValue,
    required this.changeValue,
    required this.values,
    required this.emptyMessage,
    this.maxValue,
  });

  final String title;
  final String latestValue;
  final String changeValue;
  final List<double> values;
  final String emptyMessage;
  final double? maxValue;

  @override
  Widget build(BuildContext context) {
    final hasEnoughData = values.length > 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'آخرین مقدار',
                    value: latestValue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'تغییر',
                    value: changeValue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (hasEnoughData)
              _SparkBars(values: values, maxValue: maxValue)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emptyMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _EmptyTrendBar(
                    value: maxValue == null
                        ? 0.35
                        : (values.isEmpty ? 0.0 : (values.last / maxValue!)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NextMealCard extends StatelessWidget {
  const _NextMealCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('وعده بعدی'),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _CravingQuickActionCard extends StatelessWidget {
  const _CravingQuickActionCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('کنترل هوس'),
          const SizedBox(height: 8),
          Text(
            'اگر هوس شیرینی یا تنقلات داشتی، همین حالا ثبتش کن و جایگزین سالم انتخاب کن.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              child: const Text('الان هوس کردم'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  const _ProgressSummaryCard({required this.progress});

  final BodyProgress? progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('خلاصه پیشرفت'),
          const SizedBox(height: 12),
          if (progress == null)
            const Text('هنوز رکوردی ثبت نشده است.')
          else
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'وزن',
                    value: '${_formatNumber(progress!.weightKg)} کیلو',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: 'دور شکم',
                    value: '${_formatNumber(progress!.waistCm)} سانتی‌متر',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkBars extends StatelessWidget {
  const _SparkBars({
    required this.values,
    this.maxValue,
  });

  final List<double> values;
  final double? maxValue;

  @override
  Widget build(BuildContext context) {
    final safeValues = values.isEmpty ? [0.0] : values;
    final min = safeValues.reduce(math.min);
    final max = maxValue ?? safeValues.reduce(math.max);
    final range = math.max(max - min, 1);

    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: safeValues.map((value) {
          final normalized = maxValue != null
              ? (value / maxValue!).clamp(0.12, 1.0)
              : (((value - min) / range) * 0.88 + 0.12).clamp(0.12, 1.0);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 90 * normalized,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyTrendBar extends StatelessWidget {
  const _EmptyTrendBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerRight,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _ChecklistEntry {
  const _ChecklistEntry({
    required this.key,
    required this.title,
    required this.points,
  });

  final ChecklistItemKey key;
  final String title;
  final int points;
}

WorkoutDay? _workoutForToday(List<WorkoutDay> workouts, DateTime now) {
  final dayNumber = switch (now.weekday) {
    DateTime.saturday => 1,
    DateTime.sunday => 2,
    DateTime.tuesday => 3,
    DateTime.wednesday => 4,
    DateTime.thursday => 5,
    _ => null,
  };

  if (dayNumber == null) {
    return null;
  }

  for (final workout in workouts) {
    if (workout.dayNumber == dayNumber) {
      return workout;
    }
  }
  return null;
}

String _formatNumber(double value) {
  final raw = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  return AppDateUtils.toPersianDigits(raw);
}

String _progressChangeLabel(double? first, double? latest, String unit) {
  if (first == null || latest == null) {
    return 'ثبت نشده';
  }

  final change = latest - first;
  final prefix = change > 0 ? '+' : '';
  return '$prefix${_formatNumber(change)} $unit';
}

String _scoreChangeLabel(List<DailyChecklist> history) {
  if (history.length <= 1) {
    return 'ثبت نشده';
  }

  final first = history.first.score;
  final latest = history.last.score;
  final change = latest - first;
  final prefix = change > 0 ? '+' : '';
  return '$prefix${AppDateUtils.toPersianDigits(change.toString())} امتیاز';
}

const _checklistEntries = [
  _ChecklistEntry(
    key: ChecklistItemKey.workoutDone,
    title: 'تمرین یا پیاده‌روی انجام شد',
    points: 20,
  ),
  _ChecklistEntry(
    key: ChecklistItemKey.enoughProtein,
    title: 'پروتئین کافی مصرف شد',
    points: 15,
  ),
  _ChecklistEntry(
    key: ChecklistItemKey.healthySnack,
    title: 'عصرانه سالم خورده شد',
    points: 15,
  ),
  _ChecklistEntry(
    key: ChecklistItemKey.noSugaryDrink,
    title: 'نوشیدنی قندی مصرف نشد',
    points: 10,
  ),
  _ChecklistEntry(
    key: ChecklistItemKey.supplementsDone,
    title: 'مکمل‌های امروز مصرف شد',
    points: 10,
  ),
  _ChecklistEntry(
    key: ChecklistItemKey.stepsDone,
    title: 'هدف قدم کامل شد',
    points: 10,
  ),
  _ChecklistEntry(
    key: ChecklistItemKey.enoughWater,
    title: 'آب کافی مصرف شد',
    points: 10,
  ),
  _ChecklistEntry(
    key: ChecklistItemKey.cravingControlled,
    title: 'ریزه‌خواری کنترل شد',
    points: 10,
  ),
];
