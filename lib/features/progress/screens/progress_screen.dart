import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_snapshot_view.dart';
import '../../../core/widgets/section_title.dart';
import '../models/body_progress_model.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _waistController;
  late final TextEditingController _stepsController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _waistController = TextEditingController();
    _stepsController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _stepsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(progressEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('پیشرفت')),
      body: AsyncSnapshotView(
        value: progressAsync,
        builder: (entries) {
          final latest = entries.isNotEmpty ? entries.last : null;
          final first = entries.isNotEmpty ? entries.first : null;

          _prefillTodayEntry(entries);

          final weightChange = first != null && latest != null
              ? latest.weightKg - first.weightKg
              : null;
          final waistChange = first != null && latest != null
              ? latest.waistCm - first.waistCm
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('ثبت پیشرفت امروز'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'وزن / کیلوگرم',
                        hintText: 'مثلا 86.5',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _waistController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'دور شکم / سانتی‌متر',
                        hintText: 'مثلا 99.5',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _stepsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'تعداد قدم',
                        hintText: 'مثلا 8000',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'یادداشت',
                        hintText: 'اختیاری',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          final weight = double.tryParse(_weightController.text.trim());
                          final waist = double.tryParse(_waistController.text.trim());
                          final steps = int.tryParse(_stepsController.text.trim());
                          final note = _noteController.text.trim();

                          if (weight == null || waist == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('وزن و دور شکم را درست وارد کن.'),
                              ),
                            );
                            return;
                          }

                          await ref.read(progressEntriesProvider.notifier).saveTodayProgress(
                                weightKg: weight,
                                waistCm: waist,
                                steps: steps,
                                note: note.isEmpty ? null : note,
                              );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('پیشرفت امروز ذخیره شد.'),
                              ),
                            );
                          }
                        },
                        child: const Text('ذخیره پیشرفت امروز'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('آخرین وضعیت'),
                    const SizedBox(height: 12),
                    if (latest == null)
                      const Text('هنوز رکوردی ثبت نشده است.')
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'وزن',
                              value: '${latest.weightKg} کیلو',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricTile(
                              label: 'دور شکم',
                              value: '${latest.waistCm} سانتی‌متر',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'قدم',
                              value: '${latest.steps ?? 0}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MetricTile(
                              label: 'آخرین به‌روزرسانی',
                              value: _formatDate(latest.date),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TrendCard(
                      title: 'روند وزن',
                      value: weightChange == null
                          ? '—'
                          : '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} کیلو',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TrendCard(
                      title: 'روند دور شکم',
                      value: waistChange == null
                          ? '—'
                          : '${waistChange >= 0 ? '+' : ''}${waistChange.toStringAsFixed(1)} سانتی‌متر',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('تاریخچه ثبت‌ها'),
                    const SizedBox(height: 12),
                    if (entries.isEmpty)
                      const Text('هنوز سابقه‌ای ثبت نشده است.')
                    else
                      ...entries.reversed.map(
                        (entry) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(entry.date),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'وزن: ${entry.weightKg} کیلو • دور شکم: ${entry.waistCm} سانتی‌متر • قدم: ${entry.steps ?? 0}',
                              ),
                              if (entry.note != null && entry.note!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  entry.note!,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _prefillTodayEntry(List<BodyProgress> entries) {
    final today = DateTime.now();
    final todayEntry = entries.where((entry) {
      return entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day;
    }).cast<BodyProgress?>().firstWhere((entry) => entry != null, orElse: () => null);

    if (todayEntry == null) {
      return;
    }

    final weightText = todayEntry.weightKg.toString();
    final waistText = todayEntry.waistCm.toString();
    final stepsText = todayEntry.steps?.toString() ?? '';
    final noteText = todayEntry.note ?? '';

    if (_weightController.text != weightText) {
      _weightController.text = weightText;
    }
    if (_waistController.text != waistText) {
      _waistController.text = waistText;
    }
    if (_stepsController.text != stepsText) {
      _stepsController.text = stepsText;
    }
    if (_noteController.text != noteText) {
      _noteController.text = noteText;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
