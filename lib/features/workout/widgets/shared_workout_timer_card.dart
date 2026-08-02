import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/workout_timer_provider.dart';

class SharedWorkoutTimerCard extends ConsumerStatefulWidget {
  const SharedWorkoutTimerCard({super.key});

  @override
  ConsumerState<SharedWorkoutTimerCard> createState() =>
      _SharedWorkoutTimerCardState();
}

class _SharedWorkoutTimerCardState
    extends ConsumerState<SharedWorkoutTimerCard> {
  late final TextEditingController _minutesController;
  late final TextEditingController _secondsController;

  @override
  void initState() {
    super.initState();
    final timer = ref.read(workoutTimerProvider);
    _minutesController =
        TextEditingController(text: timer.selectedMinutes.toString());
    _secondsController =
        TextEditingController(text: timer.selectedSecondPart.toString());
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _applyPreset(int totalSeconds) {
    final notifier = ref.read(workoutTimerProvider.notifier);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    notifier.setDuration(minutes: minutes, seconds: seconds);
    _minutesController.text = minutes.toString();
    _secondsController.text = seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(workoutTimerProvider);
    final notifier = ref.read(workoutTimerProvider.notifier);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تایمر تمرین',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Semantics(
                label: 'زمان باقی‌مانده',
                liveRegion: true,
                child: Text(
                  formatWorkoutDuration(timer.remainingSeconds),
                  key: const ValueKey('workout-timer-countdown'),
                  textDirection: TextDirection.ltr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          if (timer.isComplete) ...[
            const SizedBox(height: 4),
            Text(
              'زمان تمام شد',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeInput(
                  controller: _minutesController,
                  label: 'دقیقه',
                  enabled: !timer.isRunning,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (value.isEmpty) {
                      notifier.setMinutes(0);
                    } else if (parsed != null) {
                      notifier.setMinutes(parsed);
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(':', style: TextStyle(fontSize: 24)),
              ),
              Expanded(
                child: _TimeInput(
                  controller: _secondsController,
                  label: 'ثانیه',
                  enabled: !timer.isRunning,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    const _SecondsInputFormatter(),
                  ],
                  onChanged: (value) =>
                      notifier.setSeconds(int.tryParse(value) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final preset in const [30, 60, 90, 120])
                ActionChip(
                  label: Text(_presetLabel(preset)),
                  onPressed:
                      timer.isRunning ? null : () => _applyPreset(preset),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: timer.canStart ? notifier.start : null,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('شروع'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      timer.canStopOrReset ? notifier.stopAndReset : null,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const FittedBox(child: Text('توقف و بازنشانی')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeInput extends StatelessWidget {
  const _TimeInput({
    required this.controller,
    required this.label,
    required this.enabled,
    required this.inputFormatters,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final List<TextInputFormatter> inputFormatters;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        counterText: '',
      ),
    );
  }
}

class _SecondsInputFormatter extends TextInputFormatter {
  const _SecondsInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    return value != null && value <= 59 ? newValue : oldValue;
  }
}

String _presetLabel(int seconds) {
  if (seconds < 60) return '$seconds ثانیه';
  if (seconds == 60) return '۶۰ ثانیه';
  if (seconds == 90) return '۹۰ ثانیه';
  return '۲ دقیقه';
}
