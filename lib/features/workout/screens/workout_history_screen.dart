import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../models/workout_session_model.dart';
import '../providers/workout_provider.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تاریخچه تمرین‌ها')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('بارگذاری تاریخچه انجام نشد.\n$error'),
          ),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('هنوز جلسه تمرینی ثبت نشده است.'),
              ),
            );
          }

          final grouped = <String, List<WorkoutSession>>{};
          for (final session in sessions) {
            grouped.putIfAbsent(session.dateKey, () => []).add(session);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HistorySummary(sessions: sessions),
              const SizedBox(height: 18),
              for (final group in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 8),
                  child: Text(
                    group.value.first.jalaliDate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                for (final session in group.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _WorkoutSessionCard(session: session),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.sessions});

  final List<WorkoutSession> sessions;

  @override
  Widget build(BuildContext context) {
    final count = AppDateUtils.toPersianDigits(sessions.length.toString());
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.primary, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count جلسه ثبت‌شده',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'آخرین جلسه: ${sessions.first.jalaliDate} • ${sessions.first.workoutTitle}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutSessionCard extends ConsumerWidget {
  const _WorkoutSessionCard({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = AppDateUtils.toPersianDigits(
      session.completedExerciseCount.toString(),
    );
    final total =
        AppDateUtils.toPersianDigits(session.exercises.length.toString());

    return GestureDetector(
      onLongPress: () => _confirmDelete(context, ref),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            session.workoutTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.workoutFocus),
                const SizedBox(height: 4),
                Text('$completed از $total حرکت تکمیل شده • ثبت‌شده'),
              ],
            ),
          ),
          leading: const Icon(Icons.check_circle, color: AppColors.primary),
          children: [
            const Divider(),
            for (final exercise in session.exercises)
              _ExerciseRecordTile(exercise: exercise),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف جلسه تمرین'),
        content: const Text('آیا از حذف این جلسه تمرین مطمئن هستید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(workoutHistoryProvider.notifier).deleteSession(session.id);
  }
}

class _ExerciseRecordTile extends StatelessWidget {
  const _ExerciseRecordTile({required this.exercise});

  final WorkoutExerciseRecord exercise;

  @override
  Widget build(BuildContext context) {
    final details = exerciseRecordDetails(exercise);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            exercise.completed
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 20,
            color: exercise.completed
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    details.join(' • '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<String> exerciseRecordDetails(WorkoutExerciseRecord exercise) {
  String digits(Object value) => AppDateUtils.toPersianDigits(value.toString());
  String weight(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  return [
    if (exercise.weightKg != null)
      'وزنه: ${digits(weight(exercise.weightKg!))} کیلو',
    if ((exercise.actualReps ?? '').isNotEmpty)
      'تکرار: ${digits(exercise.actualReps!)}',
    if (exercise.durationMinutes != null)
      'زمان ثبت‌شده: ${digits(exercise.durationMinutes!)} دقیقه',
    if (exercise.durationSeconds != null)
      'زمان ثبت‌شده: ${digits(exercise.durationSeconds!)} ثانیه',
    if ((exercise.targetRirText ?? '').isNotEmpty)
      'RIR هدف: ${digits(exercise.targetRirText!)}',
    if ((exercise.restText ?? '').isNotEmpty) 'استراحت: ${exercise.restText}',
    if ((exercise.note ?? '').isNotEmpty) 'یادداشت: ${exercise.note}',
  ];
}
