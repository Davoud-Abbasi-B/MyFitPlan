import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_snapshot_view.dart';
import '../../../core/widgets/section_title.dart';
import '../models/exercise_model.dart';
import '../models/workout_day_model.dart';
import '../models/workout_log_model.dart';
import '../models/workout_session_model.dart';
import '../providers/workout_provider.dart';
import 'workout_history_screen.dart';

class WorkoutPlanScreen extends ConsumerWidget {
  const WorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(appSnapshotProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('برنامه تمرین'),
        actions: [
          IconButton(
            tooltip: 'تاریخچه تمرین‌ها',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const WorkoutHistoryScreen(),
              ),
            ),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: AsyncSnapshotView(
        value: snapshot,
        builder: (data) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.workouts.length + 2,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _ProgramGuideCard();
              }
              if (index == 1) {
                return const _VideoAbsGuideCard();
              }

              return _WorkoutDayCard(workout: data.workouts[index - 2]);
            },
          );
        },
      ),
    );
  }
}

class _ProgramGuideCard extends StatelessWidget {
  const _ProgramGuideCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'راهنمای اجرای برنامه هایپرتروفی',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'اصول RIR، استراحت، پیشرفت، نسخه کم‌وقت و چرخه ۱۲ هفته‌ای',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showProgramGuide(context),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('مشاهده راهنمای کامل برنامه'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showProgramGuide(BuildContext context) {
  const sections = <({String title, List<String> items})>[
    (
      title: 'اصول اجرای کل برنامه',
      items: [
        'بیشتر ست‌ها با ۱ تا ۳ تکرار ذخیره تمام شوند.',
        'حرکات اصلی حدود RIR ۲ و حرکات ایزوله حدود RIR ۱ تا ۲ داشته باشند.',
        'ناتوانی عضلانی فقط گاهی در آخرین ست حرکات ایزوله امن؛ نه در اسکوات، پرس یا RDL.',
        'پایین رفتن حرکت ۲ تا ۳ ثانیه و بالا آمدن کنترل‌شده باشد.',
        'اول تکرار را کامل کن، بعد وزنه را زیاد کن.',
        'درد زانو، کمر یا شانه یعنی تغییر حرکت، کاهش دامنه یا کاهش وزنه.',
      ],
    ),
    (
      title: 'استراحت بین ست‌ها',
      items: [
        'حرکات سنگین: ۲ تا ۳ دقیقه',
        'حرکات ایزوله: ۶۰ تا ۱۲۰ ثانیه',
        'RDL: ۲.۵ تا ۴ دقیقه',
        'شکم: ۶۰ تا ۹۰ ثانیه',
      ],
    ),
    (
      title: 'نسخه کوتاه‌تر برای روزهای کم‌وقت',
      items: [
        'پایین‌تنه A: Leg Curl را از ۲ ست به ۱ ست کاهش بده، ولی کامل حذف نکن.',
        'بالاتنه A: Hammer/Reverse Curl یا شکم آخر جلسه را حذف کن.',
        'پایین‌تنه B: Leg Extension را حذف کن، ولی RDL، Hip Thrust و Leg Curl را نگه دار.',
        'بالاتنه B: Machine Chest Press یا یکی از حرکات بازو را حذف کن.',
        'قاعده مهم: حرکات اصلی پا حذف نشوند؛ حرکات بازو و شکم قابل کاهش‌اند.',
      ],
    ),
    (
      title: 'تمرین شکم نهایی در هفته',
      items: [
        'پایین‌تنه A: Cable Crunch، ۳×۸-۱۵',
        'بالاتنه A: Plank یا Cable Crunch سبک، ۲ ست و اختیاری',
        'پایین‌تنه B: Reverse Crunch، ۲×۱۰-۲۰ + Pallof Press، ۲×۱۰-۱۵',
        'بالاتنه B: Ab Wheel، ۳×۶-۱۲',
      ],
    ),
    (
      title: 'حجم هفتگی تقریبی برنامه',
      items: [
        'چهارسر: ۱۱ تا ۱۳ ست؛ همسترینگ: ۸ تا ۱۰ ست؛ سرینی: ۹ تا ۱۲ ست؛ ساق: ۸ ست',
        'سینه: ۷ تا ۱۰ ست؛ پشت/لت: ۱۲ ست',
        'سرشانه میانی/خلفی: ۸ تا ۱۰ ست',
        'جلو بازو: ۵ تا ۷ ست مستقیم؛ پشت بازو: ۵ تا ۷ ست مستقیم',
        'ساعد/گریپ: ۴ ست مستقیم یا نیمه‌مستقیم؛ شکم: ۱۰ تا ۱۲ ست',
      ],
    ),
    (
      title: 'چرخه ۱۲ هفته‌ای برنامه',
      items: [
        'هفته ۱ تا ۲: RIR ۲ تا ۳، تثبیت وزنه؛ یک ست کمتر در حرکات فرعی قابل قبول است.',
        'هفته ۳ تا ۵: برنامه کامل؛ اول افزایش تکرار و سپس افزایش وزنه.',
        'هفته ۶: کاهش فشار؛ ست‌ها حدود ۵۰ تا ۶۰٪ و RIR ۳ تا ۴.',
        'هفته ۷ تا ۹: بازگشت به حجم کامل و پیشرفت تدریجی.',
        'هفته ۱۰ تا ۱۱: فشار کمی بیشتر؛ آخرین ست ایزوله می‌تواند RIR ۰ تا ۱ باشد.',
        'هفته ۱۲: کاهش فشار و ارزیابی وزن، دور شکم، رکوردها و دردها.',
      ],
    ),
    (
      title: 'روش پیشرفت در هر حرکت',
      items: [
        'اگر در همه ست‌ها به بالاترین تکرار رسیدی و RIR حفظ شد، جلسه بعد وزنه را کمی زیاد کن.',
        'اگر ست اول خوب بود ولی ست‌های بعد افت شدید داشت، استراحت را بیشتر کن.',
        'اگر دو جلسه پیاپی افت عملکرد داشتی، ۱ تا ۲ ست از همان عضله کم کن.',
        'با درد مفصلی، حرکت، دامنه یا وزنه را تغییر بده؛ سوزش عضله با فرم خوب قابل قبول است.',
        'اگر حرکت خیلی آسان شد، تکرار یا وزنه را افزایش بده.',
      ],
    ),
    (
      title: 'افزایش وزنه پیشنهادی',
      items: [
        'حرکات بالاتنه: حدود ۲ تا ۵٪',
        'حرکات پایین‌تنه: حدود ۲.۵ تا ۵٪',
        'دستگاه‌های سبک: گاهی ۵ تا ۱۰٪، فقط اگر فرم خراب نشود.',
        'حرکات ایزوله: اول تکرار اضافه کن، بعد وزنه.',
      ],
    ),
    (
      title: 'گرم‌کردن استاندارد هر جلسه',
      items: [
        'هوازی سبک: ۵ تا ۸ دقیقه',
        'حرکات پویا: ۳ تا ۵ دقیقه',
        'ست گرم‌کردنی حرکت اصلی: ۲ تا ۴ ست افزایشی',
        'کشش ایستا قبل تمرین سنگین لازم نیست؛ اگر انجام می‌دهی کوتاه باشد.',
      ],
    ),
    (
      title: 'برنامه هوازی و قدم برای کاهش دور شکم',
      items: [
        'هوازی بعد تمرین: ۴ جلسه × ۲۰ تا ۲۵ دقیقه با شدت متوسط و قابل گفت‌وگو.',
        'قدم روزانه: ۸۵۰۰ تا ۹۵۰۰',
        'پیاده‌روی آخر هفته: ۴۵ تا ۶۰ دقیقه',
        'اگر دور شکم ۲ هفته دیگر ثابت ماند، اول ۱۵۰۰ قدم اضافه کن و بعد کالری را کم کن.',
      ],
    ),
  ];

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'راهنمای کامل برنامه',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 16),
              ...sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
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
    ),
  );
}

class _VideoAbsGuideCard extends StatelessWidget {
  const _VideoAbsGuideCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.ondemand_video_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'برنامه مکمل شکم از ویدئو',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'راهنمای آموزشی ۳ جلسه‌ای؛ جایگزین برنامه فعلی نیست',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showVideoAbsGuide(context),
              icon: const Icon(Icons.menu_book_outlined),
              label: const Text('مشاهده راهنمای مکمل شکم'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showVideoAbsGuide(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        28 + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'برنامه مکمل شکم از ویدئو',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'این راهنما در کنار برنامه اصلی استفاده می‌شود و هیچ‌کدام از حرکات فعلی برنامه را حذف یا جایگزین نمی‌کند.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 18),
                          _VideoGuidePanel(
                            child: _GuideSection(
                              title: 'نحوه استفاده از برنامه',
                              child: _BulletList(
                                items: const [
                                  'این برنامه جایگزین برنامه فعلی نیست.',
                                  'این ۳ حرکت به‌عنوان مکمل تمرین شکم استفاده می‌شوند.',
                                  'تمرین شکم باید آخر تمرین انجام شود، نه اول تمرین.',
                                  'هدف این حرکات ساخت عضلات شکم است، نه چربی‌سوزی موضعی.',
                                  'برای دیده شدن شکم، کنترل کالری، قدم روزانه، هوازی و کاهش ریزه‌خواری مهم است.',
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const SectionTitle('راهنمای حرکات ویدئو'),
                          const SizedBox(height: 12),
                          ..._videoAbsExercises.map(
                            (exercise) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _VideoAbsExerciseCard(exercise: exercise),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SectionTitle('جلسات قابل اجرا'),
                          const SizedBox(height: 12),
                          ..._videoAbsSessions.map(
                            (session) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _VideoAbsSessionCard(session: session),
                            ),
                          ),
                          const _VideoGuidePanel(
                            child: _GuideSection(
                              title: 'روز ۲؛ بالاتنه A',
                              child: Text(
                                'در این برنامه مکمل، برای روز بالاتنه A تمرین شکم جداگانه اضافه نشده است. اگر احساس خستگی نداری، فقط کشش سبک یا تمرینات تنفسی و ثباتی خیلی سبک انجام بده. برنامه فعلی اپ را تغییر نده.',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _VideoGuidePanel(
                            child: _GuideSection(
                              title: 'روز ۵؛ پیاده‌روی سبک',
                              child: Text(
                                'در روز پیاده‌روی، تمرین شکم جداگانه لازم نیست. تمرکز روی ریکاوری، قدم روزانه و چربی‌سوزی سبک باشد.',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _VideoGuidePanel(
                            child: _GuideSection(
                              title: 'نکات مهم اجرای حرکات شکم',
                              child: _BulletList(
                                items: [
                                  'Tuck Crunch: گردن را نکش؛ حرکت از شکم باشد، نه از گردن.',
                                  'Side Plank Hip Dip: اگر کمر یا شانه اذیت شد، به‌جای حرکت لگن، پلانک پهلو ثابت بگیر.',
                                  'Lying Leg Raise: اگر کمرت گود می‌شود، پاها را کامل پایین نبر یا زانوها را کمی خم کن.',
                                  'همه حرکات آهسته و کنترل‌شده انجام شوند؛ کیفیت مهم‌تر از تعداد تکرار است.',
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const _VideoGuidePanel(
                            child: _GuideSection(
                              title: 'نکته مهم درباره چربی شکم',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'این ۳ حرکت برای ساختن و قوی‌تر شدن عضلات شکم خوب هستند، اما چربی روی شکم را مستقیم آب نمی‌کنند. برای دیده شدن شکم، این حرکات باید کنار برنامه اصلی، کنترل کالری، پروتئین کافی، هوازی، قدم روزانه و کنترل ریزه‌خواری اجرا شوند.',
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      'تمرین شکم: ۳ جلسه در هفته، آخر تمرین',
                                      'تمرین پا: حفظ شود و سبک یا حذف نشود',
                                      'کالری روز تمرین: ۲۳۰۰ تا ۲۴۰۰',
                                      'کالری روز غیرتمرین: ۲۱۰۰ تا ۲۲۰۰',
                                      'پروتئین: حدود ۱۵۰ گرم در روز',
                                      'قدم روزانه: ۸۵۰۰ تا ۹۵۰۰',
                                      'پیاده‌روی آخر هفته: ۴۵ تا ۶۰ دقیقه',
                                      'شیرینی و ریزه‌خواری عصر: کنترل جدی',
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _VideoGuidePanel extends StatelessWidget {
  const _VideoGuidePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _VideoAbsExerciseCard extends StatelessWidget {
  const _VideoAbsExerciseCard({required this.exercise});

  final _VideoAbsExercise exercise;

  @override
  Widget build(BuildContext context) {
    return _VideoGuidePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${exercise.englishName} / ${exercise.persianName}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          _OptionalVideoExerciseImage(
            imageAssetPath: exercise.imageAssetPath,
          ),
          const SizedBox(height: 12),
          Text(
            exercise.prescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          _GuideSection(
            title: 'عضلات درگیر',
            child: _BulletList(items: exercise.targetMuscles),
          ),
          const SizedBox(height: 10),
          _GuideSection(
            title: 'نحوه انجام حرکت',
            child: Text(exercise.instruction),
          ),
          const SizedBox(height: 10),
          _GuideSection(
            title: 'نکات مهم',
            child: _BulletList(items: exercise.tips),
          ),
        ],
      ),
    );
  }
}

class _OptionalVideoExerciseImage extends StatelessWidget {
  const _OptionalVideoExerciseImage({required this.imageAssetPath});

  final String imageAssetPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            imageAssetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const _ExerciseGuidePlaceholder();
            },
          ),
        ),
      ),
    );
  }
}

class _VideoAbsSessionCard extends StatelessWidget {
  const _VideoAbsSessionCard({required this.session});

  final _VideoAbsSession session;

  @override
  Widget build(BuildContext context) {
    return _VideoGuidePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            session.relatedDay,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 10),
          _BulletList(items: session.exercises),
        ],
      ),
    );
  }
}

class _VideoAbsExercise {
  const _VideoAbsExercise({
    required this.englishName,
    required this.persianName,
    required this.prescription,
    required this.targetMuscles,
    required this.instruction,
    required this.tips,
    required this.imageAssetPath,
  });

  final String englishName;
  final String persianName;
  final String prescription;
  final List<String> targetMuscles;
  final String instruction;
  final List<String> tips;
  final String imageAssetPath;
}

class _VideoAbsSession {
  const _VideoAbsSession({
    required this.title,
    required this.relatedDay,
    required this.exercises,
  });

  final String title;
  final String relatedDay;
  final List<String> exercises;
}

const _videoAbsExercises = [
  _VideoAbsExercise(
    englishName: 'Tuck Crunch',
    persianName: 'کرانچ جمع‌کردن زانو',
    prescription: '۳ ست × ۱۰ تا ۱۲ تکرار',
    targetMuscles: [
      'شکم مرکزی',
      'شکم بالایی',
      'عضلات مرکزی بدن',
    ],
    instruction:
        'از حالت درازکش، زانوها را به سمت بدن جمع کن و هم‌زمان بالاتنه را کمی بالا بیاور. حرکت باید آرام و کنترل‌شده باشد.',
    tips: [
      'گردن را نکش.',
      'حرکت از شکم باشد، نه از گردن.',
      'کمر را کنترل کن.',
      'کیفیت حرکت مهم‌تر از تعداد تکرار است.',
    ],
    imageAssetPath: 'assets/exercises/tuck_crunch.png',
  ),
  _VideoAbsExercise(
    englishName: 'Side Plank Hip Dip',
    persianName: 'پلانک پهلو با حرکت لگن',
    prescription: '۳ ست × ۱۰ تا ۱۵ تکرار برای هر سمت',
    targetMuscles: [
      'پهلوها',
      'عضلات مورب شکم',
      'عضلات مرکزی',
      'تثبیت‌کننده‌های لگن و شانه',
    ],
    instruction:
        'در حالت پلانک پهلو قرار بگیر، بدن را صاف نگه دار، لگن را کنترل‌شده کمی پایین ببر و دوباره بالا بیاور.',
    tips: [
      'بدن صاف بماند.',
      'لگن را با کنترل حرکت بده.',
      'اگر کمر یا شانه اذیت شد، به‌جای حرکت لگن، پلانک پهلو ثابت انجام بده.',
      'حرکت نباید با تاب خوردن انجام شود.',
    ],
    imageAssetPath: 'assets/exercises/side_plank_hip_dip.png',
  ),
  _VideoAbsExercise(
    englishName: 'Lying Leg Raise',
    persianName: 'بالا آوردن پا خوابیده',
    prescription: '۳ ست × ۸ تا ۱۲ تکرار',
    targetMuscles: [
      'پایین شکم',
      'راست شکمی',
      'کنترل لگن',
      'عضلات مرکزی',
    ],
    instruction:
        'به پشت بخواب، پاها را صاف یا کمی خم نگه دار، پاها را تا نزدیک ۹۰ درجه بالا بیاور و آرام پایین ببر.',
    tips: [
      'کمر نباید از زمین جدا شود.',
      'اگر کمرت گود می‌شود، پاها را کامل پایین نبر.',
      'در صورت نیاز زانوها را کمی خم کن.',
      'حرکت را آهسته و کنترل‌شده انجام بده.',
    ],
    imageAssetPath: 'assets/exercises/lying_leg_raise.png',
  ),
];

const _videoAbsSessions = [
  _VideoAbsSession(
    title: 'جلسه شکم مکمل ۱؛ بعد پایین‌تنه A',
    relatedDay: 'مرتبط با روز ۱: Lower Body A + Abs 1',
    exercises: [
      'Tuck Crunch / کرانچ جمع‌کردن زانو: ۳ ست، ۱۰ تا ۱۲ تکرار، استراحت ۶۰ تا ۹۰ ثانیه',
      'Lying Leg Raise / بالا آوردن پا خوابیده: ۳ ست، ۸ تا ۱۲ تکرار، استراحت ۶۰ تا ۹۰ ثانیه',
    ],
  ),
  _VideoAbsSession(
    title: 'جلسه شکم مکمل ۲؛ بعد پایین‌تنه B',
    relatedDay: 'مرتبط با روز ۳: Lower Body B + Abs 2',
    exercises: [
      'Side Plank Hip Dip / پلانک پهلو با حرکت لگن: ۳ ست، ۱۰ تا ۱۵ تکرار هر سمت، استراحت ۶۰ تا ۹۰ ثانیه',
      'Lying Leg Raise / بالا آوردن پا خوابیده: ۳ ست، ۸ تا ۱۲ تکرار، استراحت ۶۰ تا ۹۰ ثانیه',
    ],
  ),
  _VideoAbsSession(
    title: 'جلسه شکم مکمل ۳؛ بعد بالاتنه B',
    relatedDay: 'مرتبط با روز ۴: Upper Body B + Corrective + Abs 3',
    exercises: [
      'Tuck Crunch / کرانچ جمع‌کردن زانو: ۳ ست، ۱۰ تا ۱۲ تکرار، استراحت ۶۰ تا ۹۰ ثانیه',
      'Side Plank Hip Dip / پلانک پهلو با حرکت لگن: ۳ ست، ۱۰ تا ۱۵ تکرار هر سمت، استراحت ۶۰ تا ۹۰ ثانیه',
    ],
  ),
];

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

  bool _isExpanded = false;

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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logAsync = ref.watch(workoutLogProvider(widget.workout));
    final historyAsync = ref.watch(workoutHistoryProvider);

    return AppCard(
      child: logAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => Text('بارگذاری تمرین انجام نشد.\n$error'),
        data: (log) {
          final now = DateTime.now();
          final isSubmitted = historyAsync.valueOrNull?.any(
                (session) =>
                    session.workoutDayNumber == widget.workout.dayNumber &&
                    session.completedAt.year == now.year &&
                    session.completedAt.month == now.month &&
                    session.completedAt.day == now.day,
              ) ??
              false;
          final allRequiredCompleted = _allRequiredCompleted(log);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _toggleExpanded,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                Text(
                                  widget.workout.displayScheduleLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                if (_isTodayWorkout())
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'امروز',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                if (isSubmitted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'ثبت‌شده',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SectionTitle(widget.workout.title),
                            const SizedBox(height: 8),
                            Text(
                              widget.workout.focus,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _summaryText(log),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () =>
                                  _showDayGuide(context, widget.workout),
                              icon: const Icon(Icons.info_outline, size: 18),
                              label: const Text('راهنمای روز'),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleExpanded,
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    children: [
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
                          weightFocusNode:
                              _focusNodeFor(_weightFocusNodes, exercise.id),
                          repsController: _syncedController(
                            _repsControllers,
                            _repsFocusNodes,
                            exercise.id,
                            logEntry.actualReps ?? '',
                          ),
                          repsFocusNode:
                              _focusNodeFor(_repsFocusNodes, exercise.id),
                          durationMinutesController: _syncedController(
                            _durationMinuteControllers,
                            _durationMinuteFocusNodes,
                            exercise.id,
                            logEntry.durationMinutes?.toString() ?? '',
                          ),
                          durationMinutesFocusNode: _focusNodeFor(
                            _durationMinuteFocusNodes,
                            exercise.id,
                          ),
                          durationSecondsController: _syncedController(
                            _durationSecondControllers,
                            _durationSecondFocusNodes,
                            exercise.id,
                            logEntry.durationSeconds?.toString() ?? '',
                          ),
                          durationSecondsFocusNode: _focusNodeFor(
                            _durationSecondFocusNodes,
                            exercise.id,
                          ),
                          noteController: _syncedController(
                            _noteControllers,
                            _noteFocusNodes,
                            exercise.id,
                            logEntry.note ?? '',
                          ),
                          noteFocusNode:
                              _focusNodeFor(_noteFocusNodes, exercise.id),
                        );
                      }),
                      if (widget.workout.isGymWorkout) ...[
                        const SizedBox(height: 12),
                        _KneePainSection(
                          kneePain: log.kneePain,
                          onChanged: (value) {
                            ref
                                .read(
                                    workoutLogProvider(widget.workout).notifier)
                                .setKneePain(value);
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: allRequiredCompleted && !isSubmitted
                              ? () => _submitSession(context)
                              : null,
                          icon: Icon(
                            isSubmitted
                                ? Icons.check_circle
                                : Icons.save_outlined,
                          ),
                          label: Text(
                            isSubmitted ? 'ثبت‌شده' : 'ثبت جلسه تمرین',
                          ),
                        ),
                      ),
                      if (!allRequiredCompleted && !isSubmitted) ...[
                        const SizedBox(height: 6),
                        Text(
                          'برای ثبت جلسه، همه حرکات الزامی را کامل کن.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 180),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  String _summaryText(WorkoutLog log) {
    final requiredIds = widget.workout.exercises
        .where((exercise) => !exercise.isOptional)
        .map((exercise) => exercise.id)
        .toSet();
    final total = requiredIds.length;
    final completed = log.exerciseLogs
        .where((entry) =>
            entry.completed && requiredIds.contains(entry.exerciseId))
        .length;
    final completedLabel = AppDateUtils.toPersianDigits(completed.toString());
    final totalLabel = AppDateUtils.toPersianDigits(total.toString());
    return '$completedLabel از $totalLabel حرکت تکمیل شده';
  }

  bool _allRequiredCompleted(WorkoutLog log) {
    final completedIds = log.exerciseLogs
        .where((entry) => entry.completed)
        .map((entry) => entry.exerciseId)
        .toSet();
    return widget.workout.exercises
        .where((exercise) => !exercise.isOptional)
        .every((exercise) => completedIds.contains(exercise.id));
  }

  Future<void> _submitSession(BuildContext context) async {
    final result = await ref
        .read(workoutLogProvider(widget.workout).notifier)
        .submitSession();
    if (!context.mounted) return;

    final message = switch (result) {
      WorkoutSubmissionResult.submitted => 'جلسه تمرین با موفقیت ثبت شد.',
      WorkoutSubmissionResult.duplicate =>
        'این جلسه برای امروز قبلاً ثبت شده است.',
      WorkoutSubmissionResult.incomplete =>
        'برای ثبت جلسه، همه حرکات الزامی را کامل کن.',
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _isTodayWorkout() {
    switch (DateTime.now().weekday) {
      case DateTime.saturday:
        return widget.workout.dayNumber == 1;
      case DateTime.sunday:
        return widget.workout.dayNumber == 2;
      case DateTime.tuesday:
        return widget.workout.dayNumber == 3;
      case DateTime.wednesday:
        return widget.workout.dayNumber == 4;
      case DateTime.thursday:
        return widget.workout.dayNumber == 5;
      default:
        return false;
    }
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
            constraints:
                BoxConstraints(maxHeight: mediaQuery.size.height * 0.9),
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

Future<void> _showExerciseHistory(
  BuildContext context,
  WidgetRef ref,
  Exercise exercise,
) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Consumer(
          builder: (context, ref, child) {
            final history = ref.watch(workoutHistoryProvider);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                4,
                16,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سوابق ${exercise.name}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: history.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) =>
                          Text('بارگذاری سوابق انجام نشد.\n$error'),
                      data: (sessions) {
                        final records = <({
                          WorkoutSession session,
                          WorkoutExerciseRecord exercise
                        })>[];
                        for (final session in sessions) {
                          for (final record in session.exercises) {
                            if (record.exerciseId == exercise.id ||
                                _normalizeExerciseName(record.exerciseName)
                                        .toLowerCase() ==
                                    _normalizeExerciseName(exercise.name)
                                        .toLowerCase()) {
                              records.add((session: session, exercise: record));
                            }
                          }
                        }

                        if (records.isEmpty) {
                          return const Center(
                            child: Text(
                                'هنوز سابقه‌ای برای این حرکت ثبت نشده است.'),
                          );
                        }

                        return ListView.separated(
                          itemCount: records.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = records[index];
                            final details =
                                exerciseRecordDetails(item.exercise);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.session.jalaliDate),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.session.workoutTitle),
                                  if (details.isNotEmpty)
                                    Text(details.join(' • ')),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
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
                    exercise.isOptional
                        ? '${exercise.name} (اختیاری)'
                        : exercise.name,
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
                onPressed: () => _showGuide(context, ref, exercise),
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
                    onChanged: (value) =>
                        notifier.updateWeight(exercise.id, value),
                    decoration: const InputDecoration(
                      labelText: 'وزنه / کیلوگرم',
                      hintText: 'مثلا 150.5',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: exercise.targetDurationSeconds != null &&
                            exercise.reps == null
                        ? durationSecondsController
                        : repsController,
                    focusNode: exercise.targetDurationSeconds != null &&
                            exercise.reps == null
                        ? durationSecondsFocusNode
                        : repsFocusNode,
                    keyboardType: exercise.targetDurationSeconds != null &&
                            exercise.reps == null
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: exercise.targetDurationSeconds != null &&
                            exercise.reps == null
                        ? [FilteringTextInputFormatter.digitsOnly]
                        : null,
                    onChanged: (value) =>
                        exercise.targetDurationSeconds != null &&
                                exercise.reps == null
                            ? notifier.updateDurationSeconds(exercise.id, value)
                            : notifier.updateActualReps(exercise.id, value),
                    decoration: InputDecoration(
                      labelText: exercise.targetDurationSeconds != null &&
                              exercise.reps == null
                          ? 'زمان / ثانیه'
                          : 'تکرار واقعی',
                      hintText: exercise.targetDurationSeconds != null &&
                              exercise.reps == null
                          ? 'مثلا ${exercise.targetDurationSeconds}'
                          : 'مثلا 12',
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
    final prescription = switch (exercise.type) {
      ExerciseType.strength =>
        exercise.targetDurationSeconds != null && exercise.reps == null
            ? '${exercise.sets ?? 0}×${exercise.targetDurationSeconds} ثانیه'
            : '${exercise.sets ?? 0}×${exercise.reps ?? ''}',
      ExerciseType.cardio =>
        'هدف ${log.durationMinutes ?? exercise.targetDurationMinutes ?? 0} دقیقه',
      ExerciseType.bodyweight => exercise.targetDurationSeconds != null
          ? '${exercise.sets ?? 0}×${exercise.targetDurationSeconds} ثانیه'
          : '${exercise.sets ?? 0}×${exercise.reps ?? ''}',
    };
    final metadata = <String>[
      prescription,
      if ((exercise.targetRirText ?? '').isNotEmpty)
        'RIR ${exercise.targetRirText}',
      if ((exercise.restText ?? '').isNotEmpty) 'استراحت ${exercise.restText}',
      if (exercise.notes.isNotEmpty) exercise.notes,
    ];
    return metadata.join(' | ');
  }

  Future<void> _showGuide(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final alternativeGuide = _alternativeGuideFor(exercise.alternativeText);
    final tips = exercise.keyTips.isNotEmpty
        ? exercise.keyTips
        : [
            if ((exercise.safetyTip ?? '').trim().isNotEmpty)
              exercise.safetyTip!,
          ];

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: mediaQuery.size.height * 0.88),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          _showExerciseHistory(context, ref, exercise),
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('سوابق این حرکت'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GuideSection(
                    title: 'نحوه انجام حرکت',
                    child: Text(
                      exercise.instructionText ??
                          exercise.guideText ??
                          exercise.notes,
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
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
                  if (alternativeGuide != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'راهنمای ${alternativeGuide.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _OptionalVideoExerciseImage(
                      imageAssetPath: alternativeGuide.imageAssetPath,
                    ),
                    const SizedBox(height: 12),
                    _GuideSection(
                      title: 'نحوه انجام حرکت',
                      child: Text(alternativeGuide.instruction),
                    ),
                    const SizedBox(height: 10),
                    _GuideSection(
                      title: 'عضلات درگیر',
                      child: Text(alternativeGuide.muscles),
                    ),
                    const SizedBox(height: 10),
                    _GuideSection(
                      title: 'نکات مهم',
                      child: _BulletList(items: alternativeGuide.tips),
                    ),
                    if (alternativeGuide.alternative != null) ...[
                      const SizedBox(height: 10),
                      _GuideSection(
                        title: 'جایگزین پیشنهادی',
                        child: Text(alternativeGuide.alternative!),
                      ),
                    ],
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

class _AlternativeExerciseGuide {
  const _AlternativeExerciseGuide({
    required this.name,
    required this.instruction,
    required this.muscles,
    required this.tips,
    required this.imageAssetPath,
    this.alternative,
  });

  final String name;
  final String instruction;
  final String muscles;
  final List<String> tips;
  final String imageAssetPath;
  final String? alternative;
}

_AlternativeExerciseGuide? _alternativeGuideFor(String? alternativeText) {
  if (alternativeText == null) return null;
  for (final entry in _alternativeExerciseGuides.entries) {
    if (alternativeText.toLowerCase().contains(entry.key.toLowerCase())) {
      return entry.value;
    }
  }
  return null;
}

const _alternativeExerciseGuides = <String, _AlternativeExerciseGuide>{
  'Hack Squat': _AlternativeExerciseGuide(
    name: 'Hack Squat',
    instruction:
        'پشت و لگن را به پشتی دستگاه بچسبان، پاها را در جای بدون درد قرار بده و با کنترل پایین برو و از وسط پا بالا بیا.',
    muscles: 'چهارسر ران، سرینی؛ همسترینگ و ساق به‌عنوان عضلات کمکی',
    tips: [
      'زانوها داخل نروند.',
      'کمر از پشتی جدا نشود.',
      'دامنه بدون درد باشد.'
    ],
    imageAssetPath: 'assets/exercises/hack_squat.png',
    alternative: 'Goblet Squat یا Leg Press',
  ),
  'Chest-Supported Row': _AlternativeExerciseGuide(
    name: 'Chest-Supported Row',
    instruction:
        'سینه را روی پد ثابت نگه دار، آرنج‌ها را عقب بکش و کتف‌ها را بدون بلند کردن شانه جمع کن.',
    muscles: 'پشت میانی و لت؛ جلو بازو و پشت شانه به‌عنوان عضلات کمکی',
    tips: [
      'سینه از پد جدا نشود.',
      'در انتهای حرکت مکث کوتاه کن.',
      'وزنه را رها نکن.'
    ],
    imageAssetPath: 'assets/exercises/chest_supported_row.png',
    alternative: 'Seated Row',
  ),
  'Preacher Curl': _AlternativeExerciseGuide(
    name: 'Preacher Curl',
    instruction:
        'بازوها را روی پد ثابت کن، وزنه را با خم کردن آرنج بالا بیاور و تا کشش کنترل‌شده پایین ببر.',
    muscles: 'جلو بازو؛ براکیالیس و ساعد به‌عنوان عضلات کمکی',
    tips: [
      'آرنج از پد جدا نشود.',
      'پایین حرکت آرنج را قفل نکن.',
      'برگشت را آهسته اجرا کن.'
    ],
    imageAssetPath: 'assets/exercises/preacher_curl.png',
    alternative: 'Cable Curl',
  ),
  'Reverse Curl': _AlternativeExerciseGuide(
    name: 'Reverse Curl',
    instruction:
        'میله یا کابل را با کف دست رو به پایین بگیر و با آرنج‌های ثابت تا دامنه کنترل‌شده بالا بیاور.',
    muscles: 'براکیالیس و ساعد؛ جلو بازو به‌عنوان عضله کمکی',
    tips: [
      'مچ‌ها صاف بمانند.',
      'از تاب تنه کمک نگیر.',
      'وزنه سبک‌تر از جلو بازوی معمولی انتخاب کن.'
    ],
    imageAssetPath: 'assets/exercises/reverse_curl.png',
    alternative: 'Hammer Curl',
  ),
  'Landmine Press': _AlternativeExerciseGuide(
    name: 'Landmine Press',
    instruction:
        'انتهای میله را جلوی شانه بگیر و در مسیر مورب رو به بالا پرس کن؛ دنده‌ها و لگن را ثابت نگه دار.',
    muscles: 'سرشانه و بالای سینه؛ پشت بازو و میان‌تنه به‌عنوان عضلات کمکی',
    tips: ['شانه را بالا نکش.', 'کمر گود نشود.', 'مسیر طبیعی کتف را حفظ کن.'],
    imageAssetPath: 'assets/exercises/landmine_press.png',
    alternative: 'Shoulder Press دستگاهی بدون درد',
  ),
  'Bayesian Cable Curl': _AlternativeExerciseGuide(
    name: 'Bayesian Cable Curl',
    instruction:
        'پشت به کابل بایست، بازو را کمی عقب بدن نگه دار و بدون جلو آوردن شانه آرنج را خم کن.',
    muscles: 'جلو بازو در طول عضلانی بلند؛ براکیالیس به‌عنوان عضله کمکی',
    tips: [
      'بازو عقب و ثابت بماند.',
      'کشش پایین حرکت را کنترل کن.',
      'بدن را نچرخان.'
    ],
    imageAssetPath: 'assets/exercises/bayesian_cable_curl.png',
    alternative: 'Incline DB Curl',
  ),
  'Body Saw': _AlternativeExerciseGuide(
    name: 'Body Saw',
    instruction:
        'در پلانک ساعد قرار بگیر و بدن صاف را با حرکت شانه‌ها کمی جلو و عقب ببر، بدون اینکه کمر گود شود.',
    muscles: 'راست شکمی و عضلات عمقی مرکزی؛ سرشانه و لت به‌عنوان عضلات کمکی',
    tips: [
      'لگن ثابت بماند.',
      'دامنه کوتاه و کنترل‌شده باشد.',
      'با خستگی کمر حرکت را متوقف کن.'
    ],
    imageAssetPath: 'assets/exercises/body_saw.png',
    alternative: 'Ab Wheel با دامنه کوتاه یا Plank',
  ),
};

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
    case 'hypertrophy-day-1':
      return _DayGuideContent(
        summary:
            'تمرکز این روز روی چهارسر، کنترل زانو، حجم پا و شکم جلسه ۱ است.',
        sections: [
          const _DayGuideSection(
            title: 'نکات اختصاصی روز ۱',
            items: [
              'اگر زانو حساس بود، Leg Press را پیش از Smith Squat انجام بده.',
              'Leg Curl این روز تعادل حجم جلوی ران و همسترینگ را حفظ می‌کند.',
              'Cable Crunch حرکت اصلی و قابل‌پیشرفت شکم این روز است.',
              'برای هوازی انتهای جلسه، شیب ملایم یا الپتیکال مناسب است.',
            ],
          ),
          ...commonSections,
        ],
      );
    case 'hypertrophy-day-2':
      return _DayGuideContent(
        summary:
            'این روز روی فشار و کشش بالاتنه، حجم مستقیم بازو و یک بخش اختیاری شکم تمرکز دارد.',
        sections: [
          const _DayGuideSection(
            title: 'نکات اختصاصی روز ۲',
            items: [
              'Plank در روز کم‌وقت اختیاری است و بعد از حرکات بازو انجام می‌شود.',
              'در پرس‌ها، کتف باید عقب، پایین و کنترل‌شده بماند.',
              'Bench Press در صورت نیاز با Chest Press Machine قابل جایگزینی است.',
            ],
          ),
          ...commonSections,
        ],
      );
    case 'hypertrophy-day-3':
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
    case 'hypertrophy-day-4':
      return _DayGuideContent(
        summary:
            'این روز روی لت، سرشانه، بازو، ساعد و قدرت ضد اکستنشن شکم تمرکز دارد.',
        sections: [
          const _DayGuideSection(
            title: 'نکات اختصاصی روز ۴',
            items: [
              'Assisted Pull-up، Single-Arm Cable Row و Farmer Carry با تمرکز روی ثبات کتف اجرا شوند.',
              'Lateral Raise و Rear Delt Fly با وزنه سبک و فرم تمیز بهتر جواب می‌دهند.',
              'Ab Wheel بعد از Farmer Carry و پیش از هوازی قرار می‌گیرد.',
            ],
          ),
          ...commonSections,
        ],
      );
    case 'hypertrophy-day-5':
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
    'Hack Squat': 'assets/exercises/hack_squat.png',
    'hack squat': 'assets/exercises/hack_squat.png',
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
    'Tuck Crunch': 'assets/exercises/tuck_crunch.png',
    'tuck crunch': 'assets/exercises/tuck_crunch.png',
    'Side Plank Hip Dip': 'assets/exercises/side_plank_hip_dip.png',
    'side plank hip dip': 'assets/exercises/side_plank_hip_dip.png',
    'Lying Leg Raise': 'assets/exercises/lying_leg_raise.png',
    'lying leg raise': 'assets/exercises/lying_leg_raise.png',
    'Bench Press': 'assets/exercises/bench_press.png',
    'bench press': 'assets/exercises/bench_press.png',
    'Lat Pulldown': 'assets/exercises/lat_pulldown.png',
    'lat pulldown': 'assets/exercises/lat_pulldown.png',
    'Lat Pulldown دست جمع': 'assets/exercises/lat_pulldown.png',
    'lat pulldown دست جمع': 'assets/exercises/lat_pulldown.png',
    'Seated Row': 'assets/exercises/seated_row.png',
    'seated row': 'assets/exercises/seated_row.png',
    'Chest-Supported Row': 'assets/exercises/chest_supported_row.png',
    'chest-supported row': 'assets/exercises/chest_supported_row.png',
    'Dumbbell Shoulder Press': 'assets/exercises/shoulder_press.png',
    'dumbbell shoulder press': 'assets/exercises/shoulder_press.png',
    'Landmine Press': 'assets/exercises/landmine_press.png',
    'landmine press': 'assets/exercises/landmine_press.png',
    'Face Pull': 'assets/exercises/face_pull.png',
    'face pull': 'assets/exercises/face_pull.png',
    'Cable Triceps Pushdown': 'assets/exercises/triceps_pushdown.png',
    'cable triceps pushdown': 'assets/exercises/triceps_pushdown.png',
    'Overhead Cable Triceps Extension':
        'assets/exercises/overhead_triceps_extension.png',
    'overhead cable triceps extension':
        'assets/exercises/overhead_triceps_extension.png',
    'Dumbbell Curl': 'assets/exercises/biceps_curl.png',
    'dumbbell curl': 'assets/exercises/biceps_curl.png',
    'Cable Curl': 'assets/exercises/cable_curl.png',
    'cable curl': 'assets/exercises/cable_curl.png',
    'Preacher Curl': 'assets/exercises/preacher_curl.png',
    'preacher curl': 'assets/exercises/preacher_curl.png',
    'Hammer Curl': 'assets/exercises/hammer_curl.png',
    'hammer curl': 'assets/exercises/hammer_curl.png',
    'Reverse Curl': 'assets/exercises/reverse_curl.png',
    'reverse curl': 'assets/exercises/reverse_curl.png',
    'Incline DB Curl': 'assets/exercises/incline_db_curl.png',
    'incline db curl': 'assets/exercises/incline_db_curl.png',
    'Bayesian Cable Curl': 'assets/exercises/bayesian_cable_curl.png',
    'bayesian cable curl': 'assets/exercises/bayesian_cable_curl.png',
    'Pallof Press': 'assets/exercises/pallof_press.png',
    'pallof press': 'assets/exercises/pallof_press.png',
    'Reverse Crunch': 'assets/exercises/reverse_crunch.png',
    'reverse crunch': 'assets/exercises/reverse_crunch.png',
    'Ab Wheel': 'assets/exercises/ab_wheel.png',
    'ab wheel': 'assets/exercises/ab_wheel.png',
    'Body Saw': 'assets/exercises/body_saw.png',
    'body saw': 'assets/exercises/body_saw.png',
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
  return value.trim().replaceAll('\u200c', ' ').replaceAll(RegExp(r'\s+'), ' ');
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
