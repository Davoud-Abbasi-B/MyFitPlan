import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../models/daily_nutrition_model.dart';
import '../providers/daily_nutrition_provider.dart';

class NutritionHistoryScreen extends ConsumerWidget {
  const NutritionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(nutritionReportHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('تاریخچه تغذیه')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('تاریخچه تغذیه بارگذاری نشد.'),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(
              child: Text('هنوز گزارش غذایی ثبت نشده است.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _NutritionReportCard(report: reports[index]),
          );
        },
      ),
    );
  }
}

class _NutritionReportCard extends ConsumerWidget {
  const _NutritionReportCard({required this.report});

  final DailyNutritionReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 10),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          AppDateUtils.formatJalaliNumeric(report.submittedAt),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${_number(report.totalCalories)} کالری • '
          '${report.dayType == NutritionDayType.training ? 'روز تمرین' : 'روز استراحت'} • ثبت‌شده\n'
          'پروتئین ${_number(report.totalProteinGrams)} • '
          'کربوهیدرات ${_number(report.totalCarbsGrams)} • '
          'چربی ${_number(report.totalFatGrams)} گرم',
        ),
        trailing: PopupMenuButton<String>(
          tooltip: 'گزینه‌های گزارش',
          onSelected: (value) {
            if (value == 'delete') _deleteReport(context, ref);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 8),
                  Text('حذف گزارش'),
                ],
              ),
            ),
          ],
        ),
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'ثبت‌شده',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 10,
              runSpacing: 4,
              children: [
                Text('پروتئین: ${_number(report.totalProteinGrams)} گرم'),
                Text('کربوهیدرات: ${_number(report.totalCarbsGrams)} گرم'),
                Text('چربی: ${_number(report.totalFatGrams)} گرم'),
              ],
            ),
          ),
          const Divider(height: 20),
          ...report.entries.map(
            (entry) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${entry.foodName} • ${entry.quantityText}'),
              subtitle: Text(
                '${_number(entry.calories)} کالری • '
                'پروتئین ${_number(entry.proteinGrams)} گرم',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReport(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف گزارش غذایی'),
        content: const Text(
          'آیا از حذف این گزارش غذایی مطمئن هستید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('لغو'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(nutritionReportHistoryProvider.notifier)
          .deleteReport(report.dateKey);
    }
  }
}

String _number(double value) {
  final text = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  return AppDateUtils.toPersianDigits(text);
}
