import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../models/daily_nutrition_model.dart';
import '../models/food_analysis_result.dart';
import '../providers/daily_nutrition_provider.dart';
import '../services/food_analysis_service.dart';

class DailyCalorieTrackerCard extends ConsumerStatefulWidget {
  const DailyCalorieTrackerCard({super.key});

  @override
  ConsumerState<DailyCalorieTrackerCard> createState() =>
      _DailyCalorieTrackerCardState();
}

class _DailyCalorieTrackerCardState
    extends ConsumerState<DailyCalorieTrackerCard> {
  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();
  FoodAnalysisResult? _preview;
  bool _isAnalyzing = false;
  String? _inputError;

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() => _inputError = 'لطفاً خوراکی و مقدار آن را وارد کنید.');
      return;
    }
    setState(() {
      _isAnalyzing = true;
      _inputError = null;
      _preview = null;
    });
    try {
      final result = await ref.read(foodAnalysisServiceProvider).analyze(input);
      if (!mounted) return;
      setState(() => _preview = result);
    } on FoodNotRecognizedException {
      if (!mounted) return;
      setState(() {
        _inputError = 'این خوراکی در نسخه فعلی قابل محاسبه نیست.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _inputError = 'محاسبه انجام نشد؛ دوباره تلاش کنید.');
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _addPreview() async {
    final preview = _preview;
    if (preview == null) return;
    await ref.read(dailyNutritionProvider.notifier).addAnalysis(preview);
    if (!mounted) return;
    setState(() {
      _preview = null;
      _inputError = null;
      _inputController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خوراکی به فهرست امروز افزوده شد.')),
    );
  }

  void _editInput() {
    setState(() => _preview = null);
    _inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final dailyAsync = ref.watch(dailyNutritionProvider);
    return AppCard(
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.calculate_outlined, color: AppColors.primary),
        title: Text(
          'کالری‌شمار روزانه',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        children: [
          dailyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('اطلاعات کالری‌شمار بارگذاری نشد.'),
            ),
            data: (daily) => _buildContent(context, daily),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, DailyNutritionState daily) {
    final totals = daily.totals;
    final isTraining = daily.dayType == NutritionDayType.training;
    final lowerCalories = isTraining ? 2300 : 2100;
    final upperCalories = isTraining ? 2400 : 2200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DailySummary(
          totals: totals,
          lowerCalories: lowerCalories,
          upperCalories: upperCalories,
          isTraining: isTraining,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _inputController,
          focusNode: _inputFocusNode,
          enabled: !_isAnalyzing,
          minLines: 1,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _isAnalyzing ? null : _analyze(),
          decoration: InputDecoration(
            labelText: 'چه چیزی خوردی؟',
            hintText: 'مثلاً ۴ عدد تخم‌مرغ یا ۱۰۰ گرم نان بربری',
            errorText: _inputError,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isAnalyzing ? null : _analyze,
            icon: _isAnalyzing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_outlined),
            label: const Text('محاسبه'),
          ),
        ),
        if (_preview != null) ...[
          const SizedBox(height: 12),
          _AnalysisPreview(
            result: _preview!,
            onAdd: _addPreview,
            onEdit: _editInput,
            onCancel: () => setState(() => _preview = null),
          ),
        ],
        if (daily.entries.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'خوراکی‌های امروز',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          ...daily.entries.map(
            (entry) => _FoodEntryTile(
              entry: entry,
              onDelete: () => _confirmDeleteEntry(context, entry),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (daily.isSubmitted)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.verified_outlined,
                    size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'ثبت‌شده',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: daily.entries.isEmpty ? null : _submitReport,
            icon: const Icon(Icons.task_alt_outlined),
            label: const Text('ثبت گزارش غذایی امروز'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteEntry(
    BuildContext context,
    DailyNutritionEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف خوراکی'),
        content: const Text(
          'آیا این خوراکی از فهرست امروز حذف شود؟',
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
      await ref.read(dailyNutritionProvider.notifier).deleteEntry(entry.id);
    }
  }

  Future<void> _submitReport() async {
    final result =
        await ref.read(dailyNutritionProvider.notifier).submitReport();
    if (!mounted) return;
    final message = switch (result) {
      NutritionReportSubmissionResult.submitted =>
        'گزارش غذایی امروز با موفقیت ثبت شد.',
      NutritionReportSubmissionResult.duplicate =>
        'گزارش غذایی امروز قبلاً ثبت شده است.',
      NutritionReportSubmissionResult.empty =>
        'برای ثبت گزارش، ابتدا یک خوراکی اضافه کنید.',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _DailySummary extends StatelessWidget {
  const _DailySummary({
    required this.totals,
    required this.lowerCalories,
    required this.upperCalories,
    required this.isTraining,
  });

  final DailyNutritionTotals totals;
  final int lowerCalories;
  final int upperCalories;
  final bool isTraining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isTraining ? 'هدف روز تمرین' : 'هدف روز استراحت',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'کالری: ${_number(totals.calories)} از '
            '${_integer(lowerCalories)} تا ${_integer(upperCalories)}',
          ),
          Text(
            'پروتئین: ${_number(totals.proteinGrams)} از '
            '${_integer(145)} تا ${_integer(160)} گرم',
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text('کربوهیدرات: ${_number(totals.carbsGrams)} گرم'),
              Text('چربی: ${_number(totals.fatGrams)} گرم'),
            ],
          ),
          if (totals.calories > upperCalories) ...[
            const SizedBox(height: 8),
            const Text(
              'کالری امروز از هدف تعیین‌شده بیشتر شده است.',
              style: TextStyle(color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalysisPreview extends StatelessWidget {
  const _AnalysisPreview({
    required this.result,
    required this.onAdd,
    required this.onEdit,
    required this.onCancel,
  });

  final FoodAnalysisResult result;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.foodName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const Text(
                'مقدار تقریبی',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('مقدار: ${result.quantityText}'),
          Text('کالری: ${_number(result.calories)}'),
          Text('پروتئین: ${_number(result.proteinGrams)} گرم'),
          Text('کربوهیدرات: ${_number(result.carbsGrams)} گرم'),
          Text('چربی: ${_number(result.fatGrams)} گرم'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              FilledButton(
                onPressed: onAdd,
                child: const Text('افزودن به امروز'),
              ),
              TextButton(onPressed: onEdit, child: const Text('ویرایش متن')),
              TextButton(onPressed: onCancel, child: const Text('لغو')),
            ],
          ),
        ],
      ),
    );
  }
}

class _FoodEntryTile extends StatelessWidget {
  const _FoodEntryTile({required this.entry, required this.onDelete});

  final DailyNutritionEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = '${entry.createdAt.hour.toString().padLeft(2, '0')}:'
        '${entry.createdAt.minute.toString().padLeft(2, '0')}';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.foodName} • ${entry.quantityText}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_number(entry.calories)} کالری | '
                  'پروتئین ${_number(entry.proteinGrams)} | '
                  'کربوهیدرات ${_number(entry.carbsGrams)} | '
                  'چربی ${_number(entry.fatGrams)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${entry.isEstimated ? 'تقریبی • ' : ''}'
                  '${AppDateUtils.toPersianDigits(time)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'حذف خوراکی',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

String _number(double value) {
  final text = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  return AppDateUtils.toPersianDigits(text);
}

String _integer(int value) => AppDateUtils.toPersianDigits(value.toString());
