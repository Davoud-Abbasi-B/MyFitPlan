import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_title.dart';
import '../models/craving_log_model.dart';
import '../providers/craving_provider.dart';

Future<void> showCravingControlSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CravingControlSheet(),
  );
}

class _CravingControlSheet extends ConsumerStatefulWidget {
  const _CravingControlSheet();

  @override
  ConsumerState<_CravingControlSheet> createState() => _CravingControlSheetState();
}

class _CravingControlSheetState extends ConsumerState<_CravingControlSheet> {
  String? _selectedTrigger;
  String? _selectedAlternative;
  String? _selectedResult;

  @override
  Widget build(BuildContext context) {
    final cravingLogs = ref.watch(cravingLogsProvider).valueOrNull ?? const <CravingLog>[];
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('الان هوس کردم'),
              const SizedBox(height: 8),
              Text(
                'اول محرک هوس را مشخص کن، بعد یک جایگزین سالم انتخاب کن.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              const Text('محرک هوس'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cravingTriggers.map((trigger) {
                  return ChoiceChip(
                    label: Text(trigger),
                    selected: _selectedTrigger == trigger,
                    onSelected: (_) {
                      setState(() => _selectedTrigger = trigger);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle('راهنمای سریع'),
                    SizedBox(height: 10),
                    Text('• یک لیوان آب بخور'),
                    Text('• ۱۰ دقیقه صبر کن'),
                    Text('• ۵ نفس عمیق بکش'),
                    Text('• اگر هنوز گرسنه‌ای، یک میان‌وعده سالم انتخاب کن'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('جایگزین سالم'),
              const SizedBox(height: 8),
              ..._healthyAlternatives.map(
                (option) => RadioListTile<String>(
                  value: option,
                  groupValue: _selectedAlternative,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() => _selectedAlternative = value);
                  },
                  title: Text(option),
                ),
              ),
              const SizedBox(height: 16),
              const Text('نتیجه'),
              const SizedBox(height: 8),
              ..._cravingResults.map(
                (result) => RadioListTile<String>(
                  value: result,
                  groupValue: _selectedResult,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() => _selectedResult = value);
                  },
                  title: Text(result),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedTrigger != null &&
                          _selectedAlternative != null &&
                          _selectedResult != null
                      ? () async {
                          final log = CravingLog(
                            id: DateTime.now().toIso8601String(),
                            date: DateTime.now(),
                            trigger: _selectedTrigger!,
                            healthyAlternative: _selectedAlternative!,
                            result: _selectedResult!,
                          );
                          await ref.read(cravingLogsProvider.notifier).addLog(log);
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      : null,
                  child: const Text('ذخیره نتیجه'),
                ),
              ),
              if (cravingLogs.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionTitle('تاریخچه اخیر'),
                const SizedBox(height: 8),
                ...cravingLogs.take(5).map(
                  (log) => AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.trigger,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text('جایگزین: ${log.healthyAlternative}'),
                        Text(
                          'نتیجه: ${log.result}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

const _cravingTriggers = [
  'استرس',
  'گرسنگی واقعی',
  'خستگی',
  'بی‌حوصلگی',
  'هوس شیرینی',
  'هوس تنقلات',
];

const _healthyAlternatives = [
  'ماست چکیده کم‌چرب ۲۰۰ گرم',
  'سیب ۱ عدد + بادام ۱۵ عدد',
  'تخم‌مرغ آب‌پز ۲ عدد',
  'وی پروتئین ۱ پیمانه با آب',
  'شیر کم‌چرب ۱ لیوان',
  'خیار و هویج + ماست',
];

const _cravingResults = [
  'کنترل شد',
  'کنترل نشد',
  'میان‌وعده سالم خوردم',
];
