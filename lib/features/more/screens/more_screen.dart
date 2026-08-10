import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/build_identity.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_snapshot_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../supplements/providers/supplement_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(appSnapshotProvider);
    final supplementsState = ref.watch(supplementsStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('بیشتر')),
      body: AsyncSnapshotView(
        value: snapshot,
        builder: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('پروفایل'),
                    const SizedBox(height: 12),
                    Text('سن: ${data.profile.age} سال'),
                    Text('قد: ${data.profile.heightCm} سانتی‌متر'),
                    Text('سطح تمرین: ${data.profile.fitnessLevel}'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: data.profile.goals
                          .map(
                            (goal) => Chip(
                              label: Text(goal),
                              backgroundColor: AppColors.primaryLight,
                              side: BorderSide.none,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              supplementsState.when(
                loading: () => const AppCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stackTrace) => AppCard(
                  child: Text('بارگذاری مکمل‌ها انجام نشد.\n$error'),
                ),
                data: (supplementsData) {
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('چک‌لیست مکمل‌های امروز'),
                        const SizedBox(height: 12),
                        ...supplementsData.supplements.map(
                          (item) => CheckboxListTile(
                            value: supplementsData.todayLog.isTaken(item.id),
                            onChanged: (value) {
                              ref
                                  .read(supplementsStateProvider.notifier)
                                  .toggleSupplement(item.id, value ?? false);
                            },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(item.name),
                            subtitle: Text(item.note ?? ''),
                            secondary: Text(
                              item.scheduleLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Expanded(
                                child: SectionTitle('یادآور ویتامین D')),
                            Switch(
                              value: supplementsData
                                  .reminderSettings.vitaminDEnabled,
                              onChanged: (value) {
                                ref
                                    .read(supplementsStateProvider.notifier)
                                    .setVitaminDReminderEnabled(value);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'برنامه یادآوری: هر یکشنبه ساعت ۱۲:۰۰ ظهر به مدت ۸ هفته',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          supplementsData.reminderStatusText,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle('گزارش و تنظیمات'),
                    SizedBox(height: 8),
                    Text(
                      'صفحه‌های گزارش هفتگی، تنظیمات بیشتر یادآورها و مدیریت داده در فازهای بعدی تکمیل می‌شوند.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'نسخه $fitoraBuildLabel',
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
