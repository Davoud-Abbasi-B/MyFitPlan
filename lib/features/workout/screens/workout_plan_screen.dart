import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_snapshot_view.dart';
import '../../../core/widgets/section_title.dart';
import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../models/workout_log_model.dart';
import '../providers/workout_provider.dart';

class WorkoutPlanScreen extends ConsumerWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(appSnapshotProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('برنامه تمرین')),
      body: AsyncSnapshotView(
        value: snapshot,
        builder: (data) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.workouts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _WorkoutDayCard(workout: data.workouts[index]);
            },
          );
        },
      ),
    );
  }
}

class _WorkoutDayCard extends ConsumerStatefulWidget {
  const _WorkoutDayCard({required this.workout});

  final WorkoutDay workout;

  @override
  ConsumerState<_WorkoutDayCard> createState() => _WorkoutDayCardState();
}

class _WorkoutDayCardState extends ConsumerState<_WorkoutDayCard> {
  final Map<String, TextEditingController> _weightControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _durationMinuteControllers = {};
  final Map<String, TextEditingController> _durationSecondControllers = {};
  final Map<String, TextEditingController> _noteControllers = {};

  final Map<String, FocusNode> _weightFocusNodes = {};
  final Map<String, FocusNode> _repsFocusNodes = {};
  final Map<String, FocusNode> _durationMinuteFocusNodes = {};
  final Map<String, FocusNode> _durationSecondFocusNodes = {};
  final Map<String, FocusNode> _noteFocusNodes = {};

  late final TextEditingController _cardioMinutesController;
  late final FocusNode _cardioMinutesFocusNode;

  @override
  void initState() {
    super.initState();
    _cardioMinutesController = TextEditingController();
    _cardioMinutesFocusNode = FocusNode();
  }

  @override
  void dispose() {
    for (final store in [
      _weightControllers,
      _repsControllers,
      _durationMinuteControllers,
      _durationSecondControllers,
      _noteControllers,
    ]) {
      for (final controller in store.values) {
        controller.dispose();
      }
    }

    for (final store in [
      _weightFocusNodes,
      _repsFocusNodes,
      _durationMinuteFocusNodes,
      _durationSecondFocusNodes,
      _noteFocusNodes,
    ]) {
      for (final focusNode in store.values) {
        focusNode.dispose();
      }
    }

    _cardioMinutesController.dispose();
    _cardioMinutesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logAsync = ref.watch(workoutLogProvider(widget.workout));

    return AppCard(
      child: logAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) =>
            Text('بارگذاری تمرین انجام نشد.\n$error'),
        data: (log) {
          _maybeSyncController(
            _cardioMinutesController,
            _cardioMinutesFocusNode,
            log.cardioMinutes == 0 ? '' : log.cardioMinutes.toString(),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.workout.displayScheduleLabel,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: SectionTitle(widget.workout.title)),
                  TextButton.icon(
                    onPressed: () => _showDayGuide(context, widget.workout),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('راهنمای روز'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.workout.focus,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 14),
              ...widget.workout.exercises.map((exercise) {
                final logEntry = log.exerciseLogs.firstWhere(
                  (entry) => entry.exerciseId == exercise.id,
                  orElse: () => ExerciseLog(
                    exerciseId: exercise.id,
                    name: exercise.name,
                    type: exercise.type,
                    completed: false,
                    plannedSets: exercise.sets,
                    plannedReps: exercise.reps,
                    durationMinutes: exercise.targetDurationMinutes,
                    durationSeconds: exercise.targetDurationSeconds,
                  ),
                );

                return _ExerciseLogEditor(
                  workout: widget.workout,
                  exercise: exercise,
                  exerciseLog: logEntry,
                  weightController: _syncedController(
                    _weightControllers,
                    _weightFocusNodes,
                    exercise.id,
                    logEntry.weightKg?.toString() ?? '',
                  ),
                  weightFocusNode: _focusNodeFor(_weightFocusNodes, exercise.id),
                  repsController: _syncedController(
                    _repsControllers,
                    _repsFocusNodes,
                    exercise.id,
                    logEntry.actualReps ?? '',
                  ),
                  repsFocusNode: _focusNodeFor(_repsFocusNodes, exercise.id),
                  durationMinutesController: _syncedController(
                    _durationMinuteControllers,
                    _durationMinuteFocusNodes,
                    exercise.id,
                    logEntry.durationMinutes?.toString() ?? '',
                  ),
                  durationMinutesFocusNode:
                      _focusNodeFor(_durationMinuteFocusNodes, exercise.id),
                  durationSecondsController: _syncedController(
                    _durationSecondControllers,
                    _durationSecondFocusNodes,
                    exercise.id,
                    logEntry.durationSeconds?.toString() ?? '',
                  ),
                  durationSecondsFocusNode:
                      _focusNodeFor(_durationSecondFocusNodes, exercise.id),
                  noteController: _syncedController(
                    _noteControllers,
                    _noteFocusNodes,
                    exercise.id,
                    logEntry.note ?? '',
                  ),
                  noteFocusNode: _focusNodeFor(_noteFocusNodes, exercise.id),
                );
              }),
              if (widget.workout.isGymWorkout) ...[
                const SizedBox(height: 12),
                _CardioSection(
                  cardioCompleted: log.cardioCompleted,
                  cardioMinutesController: _cardioMinutesController,
                  cardioMinutesFocusNode: _cardioMinutesFocusNode,
                  onCompletedChanged: (value) {
                    ref
                        .read(workoutLogProvider(widget.workout).notifier)
                        .setCardioCompleted(value);
                  },
                  onMinutesChanged: (value) {
                    ref
                        .read(workoutLogProvider(widget.workout).notifier)
                        .updateCardioMinutes(value);
                  },
                ),
                const SizedBox(height: 12),
                _KneePainSection(
                  kneePain: log.kneePain,
                  onChanged: (value) {
                    ref
                        .read(workoutLogProvider(widget.workout).notifier)
                        .setKneePain(value);
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  TextEditingController _syncedController(
    Map<String, TextEditingController> controllers,
    Map<String, FocusNode> focusNodes,
    String key,
    String value,
  ) {
    final controller = controllers.putIfAbsent(
      key,
      () => TextEditingController(text: value),
    );
    final focusNode = _focusNodeFor(focusNodes, key);
    _maybeSyncController(controller, focusNode, value);
    return controller;
  }

  FocusNode _focusNodeFor(Map<String, FocusNode> store, String key) {
    return store.putIfAbsent(key, FocusNode.new);
  }

  void _maybeSyncController(
    TextEditingController controller,
    FocusNode focusNode,
    String value,
  ) {
    if (focusNode.hasFocus || controller.text == value) {
      return;
    }

    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  Future<void> _showDayGuide(BuildContext context, WorkoutDay workout) {
    final content = _dayGuideForWorkout(workout);
    final mediaQuery = MediaQuery.of(context);

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24 + mediaQuery.padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${workout.displayScheduleLabel} • ${workout.title}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 14),
                  ...content.sections.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _GuideSection(
                        title: section.title,
                        child: _BulletList(items: section.items),
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
}

class _ExerciseLogEditor extends ConsumerWidget {
  const _ExerciseLogEditor({
    required this.workout,
    required this.exercise,
    required this.exerciseLog,
    required this.weightController,
    required this.weightFocusNode,
    required this.repsController,
    required this.repsFocusNode,
    required this.durationMinutesController,
    required this.durationMinutesFocusNode,
    required this.durationSecondsController,
    required this.durationSecondsFocusNode,
    required this.noteController,
    required this.noteFocusNode,
  });

  final WorkoutDay workout;
  final Exercise exercise;
  final ExerciseLog exerciseLog;
  final TextEditingController weightController;
  final FocusNode weightFocusNode;
  final TextEditingController repsController;
  final FocusNode repsFocusNode;
  final TextEditingController durationMinutesController;
  final FocusNode durationMinutesFocusNode;
  final TextEditingController durationSecondsController;
  final FocusNode durationSecondsFocusNode;
  final TextEditingController noteController;
  final FocusNode noteFocusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(workoutLogProvider(workout).notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: exerciseLog.completed,
                  onChanged: (value) =>
                      notifier.toggleExercise(exercise.id, value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  subtitle: Text(
                    _exerciseSubtitle(exercise, exerciseLog),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _showGuide(context, exercise),
                icon: const Icon(Icons.help_outline, size: 18),
                label: const Text('راهنما'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (exercise.type == ExerciseType.strength)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    focusNode: weightFocusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) => notifier.updateWeight(exercise.id, value),
                    decoration: const InputDecoration(
                      labelText: 'وزنه / کیلوگرم',
                      hintText: 'مثلا 150.5',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    focusNode: repsFocusNode,
                    onChanged: (value) =>
                        notifier.updateActualReps(exercise.id, value),
                    decoration: const InputDecoration(
                      labelText: 'تکرار واقعی',
                      hintText: 'مثلا 12',
                    ),
                  ),
                ),
              ],
            ),
          if (exercise.type == ExerciseType.cardio)
            Column(
              children: [
                TextField(
                  controller: durationMinutesController,
                  focusNode: durationMinutesFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) =>
                      notifier.updateDurationMinutes(exercise.id, value),
                  decoration: InputDecoration(
                    labelText: 'زمان / دقیقه',
                    hintText: 'مثلا ${exercise.targetDurationMinutes ?? 20}',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ExerciseIntensity?>(
                  value: exerciseLog.intensity,
                  items: const [
                    DropdownMenuItem<ExerciseIntensity?>(
                      value: null,
                      child: Text('شدت را انتخاب کن'),
                    ),
                    DropdownMenuItem(
                      value: ExerciseIntensity.light,
                      child: Text('سبک'),
                    ),
                    DropdownMenuItem(
                      value: ExerciseIntensity.medium,
                      child: Text('متوسط'),
                    ),
                    DropdownMenuItem(
                      value: ExerciseIntensity.heavy,
                      child: Text('سنگین'),
                    ),
                  ],
                  onChanged: (value) =>
                      notifier.updateIntensity(exercise.id, value),
                  decoration: const InputDecoration(labelText: 'شدت'),
                ),
              ],
            ),
          if (exercise.type == ExerciseType.bodyweight)
            Row(
              children: [
                if (exercise.reps != null)
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      focusNode: repsFocusNode,
                      onChanged: (value) =>
                          notifier.updateActualReps(exercise.id, value),
                      decoration: const InputDecoration(
                        labelText: 'تکرار واقعی',
                        hintText: 'مثلا 12',
                      ),
                    ),
                  ),
                if (exercise.reps != null &&
                    exercise.targetDurationSeconds != null)
                  const SizedBox(width: 10),
                if (exercise.targetDurationSeconds != null)
                  Expanded(
                    child: TextField(
                      controller: durationSecondsController,
                      focusNode: durationSecondsFocusNode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) =>
                          notifier.updateDurationSeconds(exercise.id, value),
                      decoration: const InputDecoration(
                        labelText: 'زمان / ثانیه',
                        hintText: 'مثلا 45',
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          TextField(
            controller: noteController,
            focusNode: noteFocusNode,
            onChanged: (value) => notifier.updateNote(exercise.id, value),
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'یادداشت کوتاه',
              hintText: 'مثلا فرم خوب بود',
            ),
          ),
        ],
      ),
    );
  }

  String _exerciseSubtitle(Exercise exercise, ExerciseLog log) {
    switch (exercise.type) {
      case ExerciseType.strength:
        return '${exercise.sets ?? 0} ست • ${exercise.reps ?? ''}';
      case ExerciseType.cardio:
        return 'هدف ${log.durationMinutes ?? exercise.targetDurationMinutes ?? 0} دقیقه';
      case ExerciseType.bodyweight:
        if (exercise.targetDurationSeconds != null) {
          return '${exercise.sets ?? 0} ست • ${exercise.targetDurationSeconds} ثانیه';
        }
        return '${exercise.sets ?? 0} ست • ${exercise.reps ?? ''}';
    }
  }

  Future<void> _showGuide(BuildContext context, Exercise exercise) {
    final mediaQuery = MediaQuery.of(context);
    final tips = exercise.keyTips.isNotEmpty
        ? exercise.keyTips
        : [
            if ((exercise.safetyTip ?? '').trim().isNotEmpty) exercise.safetyTip!,
          ];

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.88),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24 + mediaQuery.padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _ExerciseGuideImage(exercise: exercise),
                  const SizedBox(height: 12),
                  _GuideSection(
                    title: 'نحوه انجام حرکت',
                    child: Text(
                      exercise.instructionText ?? exercise.guideText ?? exercise.notes,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GuideSection(
                    title: 'عضلات درگیر',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.targetMuscles.isEmpty
                              ? 'اطلاعات ثبت نشده است'
                              : 'عضلات اصلی: ${exercise.targetMuscles.join('، ')}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (exercise.secondaryMuscles.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'عضلات کمکی: ${exercise.secondaryMuscles.join('، ')}',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (tips.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _GuideSection(
                      title: 'نکات مهم',
                      child: _BulletList(items: tips),
                    ),
                  ],
                  if ((exercise.alternativeText ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _GuideSection(
                      title: 'جایگزین پیشنهادی',
                      child: Text(
                        exercise.alternativeText!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ExerciseGuideImage extends StatelessWidget {
  const _ExerciseGuideImage({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final imageAssetPath = _resolvedExerciseImagePath(exercise);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;
        final preferredHeight = width / (4 / 3);
        final clampedHeight = preferredHeight.clamp(220.0, 280.0);

        return Container(
          width: double.infinity,
          height: clampedHeight,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageAssetPath == null || imageAssetPath.isEmpty
              ? const _ExerciseGuidePlaceholder()
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    imageAssetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _ExerciseGuidePlaceholder(label: imageAssetPath);
                    },
                  ),
                ),
        );
      },
    );
  }
}

class _ExerciseGuidePlaceholder extends StatelessWidget {
  const _ExerciseGuidePlaceholder({this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: AppColors.primaryLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_outlined,
            size: 40,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Text(label ?? 'جای تصویر تمرین'),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayGuideContent {
  const _DayGuideContent({
    required this.summary,
    required this.sections,
  });

  final String summary;
  final List<_DayGuideSection> sections;
}

class _DayGuideSection {
  const _DayGuideSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}

_DayGuideContent _dayGuideForWorkout(WorkoutDay workout) {
  final commonSections = [
    const _DayGuideSection(
      title: 'قانون اجرای برنامه',
      items: [
        'تمرین پا به هیچ‌وجه سبک یا حذف نشود.',
        'تمرین شکم آخر تمرین انجام شود، نه اول تمرین.',
        'شدت شکم مثل عضله معمولی باشد؛ با کنترل و پیشرفت تدریجی.',
        'هوازی بعد از وزنه و با شدت متوسط انجام شود.',
        'اگر هر حرکت درد مفصلی داد، همان جلسه جایگزین شود.',
        'وقتی همه ست‌ها تمیز انجام شد، کمی وزنه یا تکرار اضافه کن.',
        'اگر روز پایین‌تنه خیلی سنگین شد، هوازی را دوچرخه سبک بزن.',
      ],
    ),
    const _DayGuideSection(
      title: 'شدت و استراحت',
      items: [
        'حرکات سنگین: استراحت ۹۰ تا ۱۲۰ ثانیه',
        'حرکات سبک‌تر و تک‌مفصلی: استراحت ۴۵ تا ۷۵ ثانیه',
        'شدت مناسب یعنی بیشتر ست‌ها با ۱ تا ۲ تکرار ذخیره تمام شوند.',
        'درد عضلانی طبیعی است؛ درد مفصلی هشدار است.',
      ],
    ),
    const _DayGuideSection(
      title: 'راهنمای هوازی',
      items: [
        'اولویت هوازی: الپتیکال، دوچرخه ثابت، تردمیل شیب ملایم.',
        'برای روزهای باشگاه، هوازی بعد از وزنه و با شدت متوسط انجام شود.',
        'اگر پا یا زانو خسته بود، دوچرخه سبک یا الپتیکال انتخاب بهتری است.',
      ],
    ),
    const _DayGuideSection(
      title: 'هدف ۱۲ هفته‌ای با این برنامه',
      items: [
        'وزن: حدود ۸۳.۵ تا ۸۴.۵ کیلو',
        'دور شکم: حدود ۹۰ تا ۹۳ سانتی‌متر',
        'قدرت پا: حفظ یا افزایش رکوردها',
        'فرم شکم: شروع خط افتادن شکم',
        'هوازی: ۴ جلسه منظم در هفته',
        'قدم روزانه: ۸۰۰۰ تا ۱۰۰۰۰ قدم',
      ],
    ),
  ];

  switch (workout.id) {
    case 'day-1':
      return _DayGuideContent(
        summary: 'تمرکز این روز روی چهارسر، کنترل زانو، حجم پا و شکم جلسه ۱ است.',
        sections: [
          const _DayGuideSection(
            title: 'نکات اختصاصی روز ۱',
            items: [
              'Step-up با ارتفاع کم و کنترل‌شده انجام شود.',
              'اگر زانو اذیت شد، Step-up همان جلسه حذف شود یا با Leg Press سبک جایگزین شود.',
              'Plank با فرم خوب ۴۵ تا ۶۰ ثانیه هدف‌گذاری شود.',
              'برای هوازی انتهای جلسه، شیب ملایم یا الپتیکال مناسب است.',
            ],
          ),
          ...commonSections,
        ],
      );
    case 'day-2':
      return _DayGuideContent(
        summary:
            'این روز روی فشار و کشش بالاتنه تمرکز دارد و در پایان Pallof Press و Reverse Crunch هم اضافه می‌شود.',
        sections: [
          const _DayGuideSection(
            title: 'نکات اختصاصی روز ۲',
            items: [
              'Pallof Press و Reverse Crunch باید بعد از حرکات بازو و قبل از هوازی انجام شوند.',
              'در پرس‌های سرشانه، گردن و کتف باید آرام و کنترل‌شده بمانند.',
              'Bench Press در صورت نیاز با Chest Press Machine قابل جایگزینی است.',
            ],
          ),
          ...commonSections,
        ],
      );
    case 'day-4':
      return _DayGuideContent(
        summary: 'تمرکز این روز روی باسن، پشت پا، همسترینگ و شکم جلسه ۲ است.',
        sections: [
          const _DayGuideSection(
            title: 'نکات اختصاصی روز ۳',
            items: [
              'Leg Curl می‌تواند به‌صورت خوابیده یا نشسته اجرا شود.',
              'Reverse Lunge معمولا از لانج جلو برای زانو مناسب‌تر است.',
              'اگر پا خیلی خسته بود، هوازی پایانی را با دوچرخه سبک انجام بده.',
            ],
          ),
          ...commonSections,
        ],
      );
    case 'day-5':
      return _DayGuideContent(
        summary:
            'این روز ترکیبی از بالاتنه، حرکات اصلاحی و شکم جلسه ۳ برای ثبات بدن است.',
        sections: [
          const _DayGuideSection(
            title: 'نکات اختصاصی روز ۴',
            items: [
              'Lat Pulldown دست جمع، Cable Row تک‌دست و Farmer Carry با تمرکز روی ثبات کتف اجرا شوند.',
              'Lateral Raise و Rear Delt Fly با وزنه سبک و فرم تمیز بهتر جواب می‌دهند.',
              'Reverse Crunch بعد از Pallof Press و قبل از هوازی قرار بگیرد.',
            ],
          ),
          ...commonSections,
        ],
      );
    case 'day-outdoor':
      return const _DayGuideContent(
        summary:
            'این روز برای ریکاوری فعال، چربی‌سوزی و کامل کردن قدم روزانه طراحی شده است.',
        sections: [
          _DayGuideSection(
            title: 'نکات اختصاصی روز ۵',
            items: [
              'هدف پیش‌فرض این روز ۶۰ دقیقه پیاده‌روی است.',
              'شدت در حد قابل گفت‌وگو بماند.',
              'اگر خسته شدی، چند دقیقه آرام‌تر راه برو ولی حرکت را حفظ کن.',
            ],
          ),
          _DayGuideSection(
            title: 'هدف ۱۲ هفته‌ای با این برنامه',
            items: [
              'وزن: حدود ۸۳.۵ تا ۸۴.۵ کیلو',
              'دور شکم: حدود ۹۰ تا ۹۳ سانتی‌متر',
              'قدم روزانه: ۸۰۰۰ تا ۱۰۰۰۰ قدم',
            ],
          ),
        ],
      );
    default:
      return _DayGuideContent(
        summary: 'راهنمایی برای این روز ثبت نشده است.',
        sections: commonSections,
      );
  }
}

String? _resolvedExerciseImagePath(Exercise exercise) {
  if (exercise.imageAssetPath != null && exercise.imageAssetPath!.isNotEmpty) {
    return exercise.imageAssetPath;
  }

  final normalizedName = _normalizeExerciseName(exercise.name);
  final normalizedLowerName = normalizedName.toLowerCase();

  const imageMap = {
    'Leg Press': 'assets/exercises/leg_press.png',
    'leg press': 'assets/exercises/leg_press.png',
    'Smith Squat': 'assets/exercises/smith_squat.png',
    'smith squat': 'assets/exercises/smith_squat.png',
    'Step-up': 'assets/exercises/step_up.png',
    'step-up': 'assets/exercises/step_up.png',
    'Leg Extension': 'assets/exercises/leg_extension.png',
    'leg extension': 'assets/exercises/leg_extension.png',
    'Seated Calf Raise': 'assets/exercises/seated_calf_raise.png',
    'seated calf raise': 'assets/exercises/seated_calf_raise.png',
    'Cable Crunch': 'assets/exercises/cable_crunch.png',
    'cable crunch': 'assets/exercises/cable_crunch.png',
    'Plank': 'assets/exercises/plank.png',
    'plank': 'assets/exercises/plank.png',
    'Bench Press': 'assets/exercises/bench_press.png',
    'bench press': 'assets/exercises/bench_press.png',
    'Lat Pulldown': 'assets/exercises/lat_pulldown.png',
    'lat pulldown': 'assets/exercises/lat_pulldown.png',
    'Lat Pulldown دست جمع': 'assets/exercises/lat_pulldown.png',
    'lat pulldown دست جمع': 'assets/exercises/lat_pulldown.png',
    'Seated Row': 'assets/exercises/seated_row.png',
    'seated row': 'assets/exercises/seated_row.png',
    'Dumbbell Shoulder Press': 'assets/exercises/shoulder_press.png',
    'dumbbell shoulder press': 'assets/exercises/shoulder_press.png',
    'Face Pull': 'assets/exercises/face_pull.png',
    'face pull': 'assets/exercises/face_pull.png',
    'Cable Triceps Pushdown': 'assets/exercises/triceps_pushdown.png',
    'cable triceps pushdown': 'assets/exercises/triceps_pushdown.png',
    'Dumbbell Curl': 'assets/exercises/biceps_curl.png',
    'dumbbell curl': 'assets/exercises/biceps_curl.png',
    'Pallof Press': 'assets/exercises/pallof_press.png',
    'pallof press': 'assets/exercises/pallof_press.png',
    'Reverse Crunch': 'assets/exercises/reverse_crunch.png',
    'reverse crunch': 'assets/exercises/reverse_crunch.png',
    'Romanian Deadlift': 'assets/exercises/romanian_deadlift.png',
    'romanian deadlift': 'assets/exercises/romanian_deadlift.png',
    'Hip Thrust': 'assets/exercises/hip_thrust.png',
    'hip thrust': 'assets/exercises/hip_thrust.png',
    'Leg Curl': 'assets/exercises/leg_curl.png',
    'leg curl': 'assets/exercises/leg_curl.png',
    'Lying/Seated Leg Curl': 'assets/exercises/leg_curl.png',
    'lying/seated leg curl': 'assets/exercises/leg_curl.png',
    'Reverse Lunge': 'assets/exercises/reverse_lunge.png',
    'reverse lunge': 'assets/exercises/reverse_lunge.png',
    'Hip Abduction Machine': 'assets/exercises/hip_abduction_machine.png',
    'hip abduction machine': 'assets/exercises/hip_abduction_machine.png',
    'Standing Calf Raise': 'assets/exercises/standing_calf_raise.png',
    'standing calf raise': 'assets/exercises/standing_calf_raise.png',
    'Captain Chair': 'assets/exercises/captain_chair.png',
    'captain chair': 'assets/exercises/captain_chair.png',
    'Dead Bug': 'assets/exercises/dead_bug.png',
    'dead bug': 'assets/exercises/dead_bug.png',
    'Incline Dumbbell Press': 'assets/exercises/incline_dumbbell_press.png',
    'incline dumbbell press': 'assets/exercises/incline_dumbbell_press.png',
    'Cable Row تک دست': 'assets/exercises/cable_row_single_arm.png',
    'Cable Row تک‌دست': 'assets/exercises/cable_row_single_arm.png',
    'cable row تک دست': 'assets/exercises/cable_row_single_arm.png',
    'cable row تک‌دست': 'assets/exercises/cable_row_single_arm.png',
    'Lateral Raise': 'assets/exercises/lateral_raise.png',
    'lateral raise': 'assets/exercises/lateral_raise.png',
    'Rear Delt Fly': 'assets/exercises/rear_delt_fly.png',
    'rear delt fly': 'assets/exercises/rear_delt_fly.png',
    'Farmer Carry': 'assets/exercises/farmer_carry.png',
    'farmer carry': 'assets/exercises/farmer_carry.png',
    'دوچرخه ثابت': 'assets/exercises/bicycle.png',
    'دوچرخه ثابت یا الپتیکال': 'assets/exercises/bicycle.png',
    'Bicycle': 'assets/exercises/bicycle.png',
    'الپتیکال': 'assets/exercises/elliptical.png',
    'Elliptical': 'assets/exercises/elliptical.png',
    'تردمیل': 'assets/exercises/treadmill.png',
    'Treadmill': 'assets/exercises/treadmill.png',
    'هوازی سبک + گرم‌کردن شانه': 'assets/exercises/elliptical.png',
    'هوازی سبک + گرم‌کردن کتف': 'assets/exercises/elliptical.png',
    'هوازی': 'assets/exercises/treadmill.png',
    'پیاده‌روی': 'assets/exercises/outdoor_walking.png',
    'Outdoor Walking': 'assets/exercises/outdoor_walking.png',
  };

  return imageMap[normalizedName] ?? imageMap[normalizedLowerName];
}

String _normalizeExerciseName(String value) {
  return value
      .trim()
      .replaceAll('\u200c', ' ')
      .replaceAll(RegExp(r'\s+'), ' ');
}

class _CardioSection extends StatelessWidget {
  const _CardioSection({
    required this.cardioCompleted,
    required this.cardioMinutesController,
    required this.cardioMinutesFocusNode,
    required this.onCompletedChanged,
    required this.onMinutesChanged,
  });

  final bool cardioCompleted;
  final TextEditingController cardioMinutesController;
  final FocusNode cardioMinutesFocusNode;
  final ValueChanged<bool> onCompletedChanged;
  final ValueChanged<String> onMinutesChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: cardioCompleted,
            onChanged: (value) => onCompletedChanged(value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('هوازی'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: cardioMinutesController,
            focusNode: cardioMinutesFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onMinutesChanged,
            decoration: const InputDecoration(
              labelText: 'زمان / دقیقه',
              hintText: 'مثلا 25',
            ),
          ),
        ],
      ),
    );
  }
}

class _KneePainSection extends StatelessWidget {
  const _KneePainSection({
    required this.kneePain,
    required this.onChanged,
  });

  final bool kneePain;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'درد زانو داشتی؟',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ChoiceChip(
            label: const Text('خیر'),
            selected: !kneePain,
            onSelected: (_) => onChanged(false),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('بله'),
            selected: kneePain,
            onSelected: (_) => onChanged(true),
          ),
        ],
      ),
    );
  }
}
