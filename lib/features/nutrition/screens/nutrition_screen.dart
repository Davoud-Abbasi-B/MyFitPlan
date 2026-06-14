import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_snapshot_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../craving/widgets/craving_control_sheet.dart';
import '../models/meal_model.dart';
import '../providers/nutrition_provider.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(appSnapshotProvider);
    final nutritionLogAsync = ref.watch(nutritionLogProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تغذیه')),
      body: AsyncSnapshotView(
        value: snapshot,
        builder: (data) {
          final nutritionLog = nutritionLogAsync.valueOrNull;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('کنترل هوس'),
                    const SizedBox(height: 8),
                    Text(
                      'اگر هوس خوردن پیدا کردی، از ابزار کنترل هوس استفاده کن.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => showCravingControlSheet(context),
                        child: const Text('الان هوس کردم'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _TrainingGuidanceCard(),
              const SizedBox(height: 12),
              ...data.mealPlans.map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(plan.title),
                        const SizedBox(height: 8),
                        Text(
                          'پروتئین تقریبی: ${plan.totalProtein} گرم',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 14),
                        ...plan.meals.map(
                          (meal) => _MealTile(
                            meal: meal,
                            completed: nutritionLog?.isMealCompleted(meal.id) ?? false,
                            onChanged: (value) {
                              ref
                                  .read(nutritionLogProvider.notifier)
                                  .toggleMeal(meal.id, value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: SectionTitle('عصرانه')),
                        TextButton.icon(
                          onPressed: () => _showMealGuidanceSheet(
                            context,
                            title: 'عصرانه',
                            suggestions: _mealGuidance['عصرانه']!,
                          ),
                          icon: const Icon(Icons.help_outline, size: 18),
                          label: const Text('راهنما'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'یکی از گزینه‌های امروز را انتخاب کن.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._snackOptions.map(
                      (option) => RadioListTile<String>(
                        value: option,
                        groupValue: nutritionLog?.selectedSnackOption,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          ref
                              .read(nutritionLogProvider.notifier)
                              .selectSnackOption(value);
                        },
                        contentPadding: EdgeInsets.zero,
                        title: Text(option),
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
}

class _TrainingGuidanceCard extends StatelessWidget {
  const _TrainingGuidanceCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('راهنمای وعده‌های تمرینی'),
          const SizedBox(height: 10),
          _GuidanceShortcut(
            title: 'میان‌وعده قبل تمرین',
            onTap: () => _showMealGuidanceSheet(
              context,
              title: 'میان‌وعده قبل تمرین',
              suggestions: _mealGuidance['میان‌وعده قبل تمرین']!,
            ),
          ),
          const SizedBox(height: 8),
          _GuidanceShortcut(
            title: 'بعد تمرین',
            onTap: () => _showMealGuidanceSheet(
              context,
              title: 'بعد تمرین',
              suggestions: _mealGuidance['بعد تمرین']!,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceShortcut extends StatelessWidget {
  const _GuidanceShortcut({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title)),
            const Icon(Icons.chevron_left),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({
    required this.meal,
    required this.completed,
    required this.onChanged,
  });

  final Meal meal;
  final bool completed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final guidanceTitle = _guidanceTitleForMeal(meal.title);
    final suggestions = _mealGuidance[guidanceTitle] ?? const <_MealSuggestion>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: meal.isPriority ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: completed,
                  onChanged: (value) => onChanged(value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    meal.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      meal.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showMealGuidanceSheet(
                  context,
                  title: guidanceTitle,
                  suggestions: suggestions,
                ),
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text('راهنما'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showMealGuidanceSheet(
  BuildContext context, {
  required String title,
  required List<_MealSuggestion> suggestions,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                ...suggestions.map(
                  (item) => AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(item.portion),
                        const SizedBox(height: 4),
                        Text(
                          item.note,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _guidanceTitleForMeal(String title) {
  if (title.contains('صبحانه')) {
    return 'صبحانه';
  }
  if (title.contains('ناهار')) {
    return 'ناهار';
  }
  if (title.contains('شام')) {
    return 'شام';
  }
  if (title.contains('عصرانه')) {
    return 'عصرانه';
  }
  return title;
}

class _MealSuggestion {
  const _MealSuggestion({
    required this.title,
    required this.portion,
    required this.note,
  });

  final String title;
  final String portion;
  final String note;
}

const _snackOptions = [
  'ماست چکیده',
  'سیب + بادام',
  'تخم‌مرغ آب‌پز',
  'وی پروتئین',
  'شیر کم‌چرب',
];

const _mealGuidance = <String, List<_MealSuggestion>>{
  'صبحانه': [
    _MealSuggestion(
      title: 'صبحانه',
      portion: '۲ عدد تخم‌مرغ کامل + ۲ عدد سفیده + ۱ کف دست نان سنگک + خیار و گوجه',
      note: 'پروتئین بالا و سیرکننده برای شروع روز.',
    ),
    _MealSuggestion(
      title: 'صبحانه',
      portion: 'املت با ۲ عدد تخم‌مرغ کامل + ۲ سفیده + ۱ قاشق چای‌خوری روغن زیتون + ۱ کف دست نان',
      note: 'اگر صبح وقت کم داری گزینه ساده‌تری است.',
    ),
    _MealSuggestion(
      title: 'صبحانه',
      portion: 'جو دوسر ۵۰ گرم + شیر کم‌چرب ۲۵۰ میلی‌لیتر + دارچین + ۱۰ عدد بادام',
      note: 'برای انرژی پایدار تا ظهر مناسب است.',
    ),
    _MealSuggestion(
      title: 'صبحانه',
      portion: 'ماست یونانی ۲۵۰ گرم + موز نصف عدد + گردو ۲ عدد',
      note: 'اگر صبحانه سبک‌تر می‌خواهی این گزینه مناسب است.',
    ),
  ],
  'میان‌وعده قبل تمرین': [
    _MealSuggestion(
      title: 'میان‌وعده قبل تمرین',
      portion: 'موز ۱ عدد متوسط',
      note: 'هضم آسان و مناسب برای انرژی سریع.',
    ),
    _MealSuggestion(
      title: 'میان‌وعده قبل تمرین',
      portion: 'خرما ۲ عدد + قهوه تلخ',
      note: 'برای تمرین‌های کم‌حجم و تمرکز بهتر مناسب است.',
    ),
    _MealSuggestion(
      title: 'میان‌وعده قبل تمرین',
      portion: 'نان سنگک نصف کف دست + پنیر کم‌چرب ۳۰ گرم',
      note: 'اگر فاصله تا تمرین بیشتر است انتخاب متعادل‌تری است.',
    ),
    _MealSuggestion(
      title: 'میان‌وعده قبل تمرین',
      portion: 'سیب ۱ عدد',
      note: 'اگر اشتها کم است گزینه سبک‌تری است.',
    ),
  ],
  'بعد تمرین': [
    _MealSuggestion(
      title: 'بعد تمرین',
      portion: 'وی پروتئین ۱ پیمانه با آب',
      note: 'سریع و ساده برای بعد تمرین.',
    ),
    _MealSuggestion(
      title: 'بعد تمرین',
      portion: 'شیر کم‌چرب ۱ لیوان + موز نصف عدد',
      note: 'اگر وی در دسترس نیست این ترکیب مناسب است.',
    ),
    _MealSuggestion(
      title: 'بعد تمرین',
      portion: 'تخم‌مرغ آب‌پز ۲ عدد، ترجیحاً ۱ زرده + ۲ سفیده',
      note: 'برای ریکاوری و سیری مناسب است.',
    ),
    _MealSuggestion(
      title: 'بعد تمرین',
      portion: 'ماست یونانی ۲۰۰ گرم',
      note: 'ساده، پرپروتئین و کم‌حجم.',
    ),
  ],
  'ناهار': [
    _MealSuggestion(
      title: 'ناهار',
      portion: 'مرغ پخته یا گریل ۱۵۰ تا ۲۰۰ گرم + برنج پخته ۶ تا ۸ قاشق غذاخوری + سالاد زیاد',
      note: 'انتخاب پایه و مطمئن برای روزهای تمرین.',
    ),
    _MealSuggestion(
      title: 'ناهار',
      portion: 'گوشت قرمز کم‌چرب ۱۲۰ تا ۱۵۰ گرم + نان سنگک ۱ کف دست + سبزیجات',
      note: 'برای تنوع هفتگی مناسب است.',
    ),
    _MealSuggestion(
      title: 'ناهار',
      portion: 'ماهی ۱۸۰ تا ۲۰۰ گرم + سیب‌زمینی آب‌پز متوسط ۱ عدد + سالاد',
      note: 'هضم خوب و چربی مفید.',
    ),
    _MealSuggestion(
      title: 'ناهار',
      portion: 'تن ماهی آبکش‌شده ۱ قوطی + نان سنگک ۱ کف دست + خیار و گوجه',
      note: 'وقتی زمان کم داری گزینه کاربردی است.',
    ),
  ],
  'عصرانه': [
    _MealSuggestion(
      title: 'عصرانه',
      portion: 'ماست چکیده کم‌چرب ۲۰۰ تا ۲۵۰ گرم',
      note: 'ساده و سیرکننده برای کنترل ریزه‌خواری.',
    ),
    _MealSuggestion(
      title: 'عصرانه',
      portion: 'سیب ۱ عدد + بادام ۱۵ عدد',
      note: 'هم فیبر دارد هم چربی مفید.',
    ),
    _MealSuggestion(
      title: 'عصرانه',
      portion: 'تخم‌مرغ آب‌پز ۲ عدد',
      note: 'اگر گرسنگی واقعی داری انتخاب خوبی است.',
    ),
    _MealSuggestion(
      title: 'عصرانه',
      portion: 'وی پروتئین نصف تا ۱ پیمانه',
      note: 'برای روزهای تمرین یا وقتی وقت کم داری مناسب است.',
    ),
    _MealSuggestion(
      title: 'عصرانه',
      portion: 'شیر کم‌چرب ۱ لیوان',
      note: 'اگر اشتها کم است گزینه سبک‌تری است.',
    ),
    _MealSuggestion(
      title: 'عصرانه',
      portion: 'خیار و هویج + ماست',
      note: 'حجم خوب با کالری پایین و سیری مناسب.',
    ),
  ],
  'شام': [
    _MealSuggestion(
      title: 'شام',
      portion: 'مرغ یا ماهی ۱۵۰ گرم + سبزیجات پخته یا سالاد زیاد',
      note: 'سبک و مناسب آخر شب.',
    ),
    _MealSuggestion(
      title: 'شام',
      portion: 'تخم‌مرغ ۲ عدد کامل + ۲ سفیده + سبزیجات',
      note: 'سریع آماده می‌شود و پروتئین خوبی دارد.',
    ),
    _MealSuggestion(
      title: 'شام',
      portion: 'ماست یونانی ۲۵۰ گرم + خیار + گردو ۲ عدد',
      note: 'برای شام سبک‌تر انتخاب خوبی است.',
    ),
    _MealSuggestion(
      title: 'شام',
      portion: 'گوشت کم‌چرب ۱۲۰ گرم + سبزیجات',
      note: 'اگر در ناهار گوشت نخورده‌ای این گزینه مناسب است.',
    ),
    _MealSuggestion(
      title: 'شام',
      portion: 'تن ماهی نصف تا ۱ قوطی + سالاد',
      note: 'وقتی زمان پخت نداری کاربردی است.',
    ),
  ],
};
