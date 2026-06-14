import '../../core/utils/date_utils.dart';
import '../../features/checklist/models/daily_checklist_model.dart';
import '../../features/nutrition/models/meal_model.dart';
import '../../features/nutrition/models/meal_plan_model.dart';
import '../../features/progress/models/body_progress_model.dart';
import '../../features/settings/models/user_profile_model.dart';
import '../../features/supplements/models/supplement_model.dart';
import '../../features/workout/models/exercise_model.dart';
import '../../features/workout/models/workout_day_model.dart';

abstract final class DefaultSeedData {
  static UserProfile profile() {
    return const UserProfile(
      age: 34,
      gender: 'مرد',
      heightCm: 185,
      currentWeightKg: 87,
      targetWeightKg: 84,
      currentWaistCm: 100,
      weeklyWorkoutDays: 4,
      fitnessLevel: 'متوسط',
      goals: [
        'کاهش چربی شکم',
        'عضله‌سازی پایین‌تنه',
        'سلامت عمومی',
        'مراقبت از زانو',
      ],
    );
  }

  static DailyChecklist checklistForToday() {
    final now = DateTime.now();

    return DailyChecklist(
      id: 'checklist-${AppDateUtils.dateKey(now)}',
      date: now,
      workoutDone: false,
      enoughProtein: false,
      healthySnack: false,
      noSugaryDrink: false,
      supplementsDone: false,
      stepsDone: false,
      enoughWater: false,
      cravingControlled: false,
    );
  }

  static List<WorkoutDay> workouts() {
    return [
      WorkoutDay(
        id: 'day-1',
        title: 'Day 1: Lower Body A',
        focus: 'چهارسر و زانو',
        dayNumber: 1,
        cardioMinutes: 25,
        location: WorkoutLocation.gym,
        exercises: const [
          Exercise(
            id: 'd1-e1',
            name: 'دوچرخه ثابت',
            type: ExerciseType.cardio,
            targetDurationMinutes: 8,
            notes: 'شدت سبک تا متوسط',
            guideText: 'برای گرم‌کردن پیش از تمرین پایین‌تنه استفاده شود.',
            instructionText:
                'روی دوچرخه با ریتم آرام شروع کن و طی چند دقیقه شدت را به آرامی تا حد متوسط بالا ببر.',
            targetMuscles: ['چهارسر ران', 'همسترینگ'],
            secondaryMuscles: ['باسن', 'ساق پا'],
            keyTips: [
              'گرم‌کردن این بخش برای زانو مهم است.',
              'سرعت را ناگهانی زیاد نکن.',
              'زانو را در مسیر طبیعی نگه دار.',
            ],
            safetyTip: 'اگر از همان ابتدا درد زانو داشتی شدت را کمتر کن.',
            imageAssetPath: 'assets/exercises/bicycle.png',
          ),
          Exercise(
            id: 'd1-e2',
            name: 'Leg Press',
            type: ExerciseType.strength,
            sets: 4,
            reps: '10-12',
            notes: 'زانو داخل نرود، کنترل کامل',
            guideText: 'پرس پا با کنترل کامل و دامنه بدون درد انجام شود.',
            instructionText:
                'کف پاها را روی صفحه بگذار، زانوها هم‌راستا با پنجه‌ها باشد، پایین رفتن کنترل‌شده و بالا آمدن بدون قفل شدید زانو انجام شود.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'ساق پا'],
            keyTips: [
              'زانوها به داخل نریزند.',
              'کمر از تکیه‌گاه جدا نشود.',
              'دامنه حرکت بدون درد باشد.',
            ],
            imageAssetPath: 'assets/exercises/leg_press.png',
          ),
          Exercise(
            id: 'd1-e3',
            name: 'Goblet Squat',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10',
            notes: 'دامنه بدون درد',
            guideText: 'اسکوات با دمبل جلوی سینه و کنترل کامل انجام شود.',
            instructionText:
                'دمبل را جلوی سینه نگه دار، لگن را عقب ببر و با سینه بالا تا دامنه بدون درد پایین برو، سپس با فشار پاشنه‌ها بالا برگرد.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'عضلات مرکزی'],
            keyTips: [
              'پاشنه از زمین جدا نشود.',
              'کمر را گرد نکن.',
              'دامنه را به درد تحمیل نکن.',
            ],
            alternativeText: 'در صورت نیاز Smith Squat می‌تواند جایگزین باشد.',
            imageAssetPath: 'assets/exercises/goblet_squat.png',
          ),
          Exercise(
            id: 'd1-e4',
            name: 'Bulgarian Split Squat',
            type: ExerciseType.strength,
            sets: 3,
            reps: '8 هر پا',
            notes: 'اگر زانو اذیت شد، Step-up جایگزین شود',
            guideText: 'حرکت تک‌پا با تمرکز روی کنترل زانو و تعادل انجام شود.',
            instructionText:
                'پای عقب را روی نیمکت قرار بده، پای جلو را محکم روی زمین نگه دار و با کنترل پایین برو و بالا برگرد.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'عضلات مرکزی'],
            keyTips: [
              'زانو در راستای پنجه بماند.',
              'بیش از حد به جلو خم نشو.',
              'تعادل را با عجله به هم نزن.',
            ],
            alternativeText: 'اگر زانو اذیت شد Step-up جایگزین شود.',
            imageAssetPath: 'assets/exercises/bulgarian_split_squat.png',
          ),
          Exercise(
            id: 'd1-e5',
            name: 'Leg Extension',
            type: ExerciseType.strength,
            sets: 3,
            reps: '12-15',
            notes: 'مکث کوتاه بالا',
            guideText: 'بالا آوردن ساق با مکث کوتاه و بازگشت کنترل‌شده انجام شود.',
            instructionText:
                'روی دستگاه بنشین، ساق را تا نزدیک صاف شدن زانو بالا بیاور، یک مکث کوتاه داشته باش و آرام پایین برگرد.',
            targetMuscles: ['چهارسر ران'],
            secondaryMuscles: ['فلکسورهای ران'],
            keyTips: [
              'وزنه را تاب نده.',
              'در پایین حرکت زانو را رها نکن.',
              'کنترل در تمام مسیر حفظ شود.',
            ],
            imageAssetPath: 'assets/exercises/leg_extension.png',
          ),
          Exercise(
            id: 'd1-e6',
            name: 'Seated Calf Raise',
            type: ExerciseType.strength,
            sets: 4,
            reps: '12-15',
            notes: 'کنترل در پایین و بالا',
            guideText: 'ساق نشسته با دامنه کامل و مکث کوتاه بالا انجام شود.',
            instructionText:
                'روی دستگاه بنشین، پاشنه را پایین ببر و سپس با فشار پنجه‌ها تا انقباض کامل ساق بالا بیاور.',
            targetMuscles: ['ساق پا'],
            secondaryMuscles: ['عضلات کف پا'],
            keyTips: [
              'در پایین کشش کامل بگیر.',
              'در بالا یک مکث کوتاه داشته باش.',
              'حرکت را پرشی انجام نده.',
            ],
            imageAssetPath: 'assets/exercises/seated_calf_raise.png',
          ),
          Exercise(
            id: 'd1-e7',
            name: 'Plank',
            type: ExerciseType.bodyweight,
            sets: 3,
            targetDurationSeconds: 45,
            notes: 'بازه هدف 40 تا 60 ثانیه',
            guideText: 'ساعدها روی زمین، بدن در یک خط صاف، شکم و باسن سفت.',
            instructionText:
                'ساعدها را روی زمین قرار بده، بدن را در یک خط مستقیم نگه دار و شکم و باسن را منقبض حفظ کن.',
            targetMuscles: ['عضلات مرکزی', 'راست شکمی'],
            secondaryMuscles: ['سرشانه', 'باسن', 'پایین کمر'],
            keyTips: [
              'کمر گود نشود.',
              'گردن خنثی بماند.',
              'زمان را با فرم صحیح نگه دار.',
            ],
            imageAssetPath: 'assets/exercises/plank.png',
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-2',
        title: 'Day 2: Upper Body A',
        focus: 'فشار و کشش بالاتنه',
        dayNumber: 2,
        cardioMinutes: 20,
        location: WorkoutLocation.gym,
        exercises: const [
          Exercise(
            id: 'd2-e1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: 4,
            reps: '8-10',
            notes: 'کنترل مسیر حرکت',
            guideText: 'پرس سینه با کنترل کامل و ثبات شانه انجام شود.',
            instructionText:
                'روی نیمکت دراز بکش، میله را کمی بازتر از عرض شانه بگیر و آن را با کنترل تا نزدیک سینه پایین بیاور و سپس بالا پرس کن.',
            targetMuscles: ['سینه', 'جلوی سرشانه'],
            secondaryMuscles: ['پشت بازو', 'عضلات مرکزی'],
            keyTips: [
              'تیغه‌های کتف را جمع نگه دار.',
              'مچ را نشکن.',
              'میله را با ضربه از سینه جدا نکن.',
            ],
            alternativeText: 'Chest Press Machine می‌تواند جایگزین باشد.',
            imageAssetPath: 'assets/exercises/bench_press.png',
          ),
          Exercise(
            id: 'd2-e2',
            name: 'Lat Pulldown',
            type: ExerciseType.strength,
            sets: 4,
            reps: '10-12',
            notes: 'کشش کامل بالا',
            guideText: 'لت‌پول‌دان با مسیر کامل و کنترل شانه انجام شود.',
            instructionText:
                'میله را با دست باز بگیر و با پایین آوردن آرنج‌ها تا بالای سینه بکش، سپس با کنترل بالا برگردان.',
            targetMuscles: ['زیربغل', 'پشت میانی'],
            secondaryMuscles: ['جلو بازو', 'پشت شانه'],
            keyTips: [
              'شانه‌ها را پایین نگه دار.',
              'بدن را بیش از حد عقب نبر.',
              'میله را پشت گردن نکش.',
            ],
            imageAssetPath: 'assets/exercises/lat_pulldown.png',
          ),
          Exercise(
            id: 'd2-e3',
            name: 'Seated Row',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10-12',
            notes: 'کتف‌ها عقب',
            guideText: 'قایقی نشسته با تمرکز روی جمع شدن کتف انجام شود.',
            instructionText:
                'دسته را به سمت شکم بکش، آرنج‌ها را نزدیک بدن نگه دار و در انتهای حرکت کتف‌ها را به هم نزدیک کن.',
            targetMuscles: ['پشت میانی', 'زیربغل'],
            secondaryMuscles: ['جلو بازو', 'پشت شانه'],
            keyTips: [
              'کمر را گرد نکن.',
              'شانه‌ها بالا نروند.',
              'حرکت را با تاب بدن انجام نده.',
            ],
            imageAssetPath: 'assets/exercises/seated_row.png',
          ),
          Exercise(
            id: 'd2-e4',
            name: 'Shoulder Press',
            type: ExerciseType.strength,
            sets: 3,
            reps: '8-10',
            notes: 'فشار بدون درد گردن',
            guideText: 'پرس سرشانه با ستون بدن پایدار و بدون فشار گردن انجام شود.',
            instructionText:
                'وزنه یا دسته را از کنار شانه‌ها بالای سر پرس کن و با کنترل به نقطه شروع برگرد.',
            targetMuscles: ['سرشانه'],
            secondaryMuscles: ['پشت بازو', 'بالای سینه', 'عضلات مرکزی'],
            keyTips: [
              'کمر را زیاد قوس نده.',
              'شانه‌ها را بالا نبر.',
              'اگر گردن درد گرفت دامنه یا وزنه را کم کن.',
            ],
            imageAssetPath: 'assets/exercises/shoulder_press.png',
          ),
          Exercise(
            id: 'd2-e5',
            name: 'Face Pull',
            type: ExerciseType.strength,
            sets: 3,
            reps: '15',
            notes: 'عالی برای شانه و گردن',
            guideText: 'طناب را به سمت صورت بکش و آرنج‌ها را بالا نگه دار.',
            instructionText:
                'طناب را هم‌سطح صورت بگیر و با باز شدن دست‌ها آن را به سمت بینی و پیشانی بکش.',
            targetMuscles: ['پشت شانه', 'عضلات بین کتف'],
            secondaryMuscles: ['کول میانی', 'روتاتور کاف'],
            keyTips: [
              'سر را جلو نبر.',
              'حرکت را با تاب بدن انجام نده.',
              'در انتهای حرکت مکث کوتاه داشته باش.',
            ],
            imageAssetPath: 'assets/exercises/face_pull.png',
          ),
          Exercise(
            id: 'd2-e6',
            name: 'Triceps Pushdown',
            type: ExerciseType.strength,
            sets: 3,
            reps: '12',
            notes: 'آرنج ثابت',
            guideText: 'پشت بازو سیم‌کش با آرنج ثابت و کنترل کامل اجرا شود.',
            instructionText:
                'طناب یا میله را در کنار بدن پایین فشار بده و فقط از مفصل آرنج حرکت کن.',
            targetMuscles: ['پشت بازو'],
            secondaryMuscles: ['ساعد'],
            keyTips: [
              'آرنج‌ها کنار بدن بمانند.',
              'شانه‌ها را جلو نبر.',
              'بازگشت حرکت آرام باشد.',
            ],
            imageAssetPath: 'assets/exercises/triceps_pushdown.png',
          ),
          Exercise(
            id: 'd2-e7',
            name: 'Biceps Curl',
            type: ExerciseType.strength,
            sets: 3,
            reps: '12',
            notes: 'کنترل کامل',
            guideText: 'جلوبازو با آرنج ثابت و دامنه کامل انجام شود.',
            instructionText:
                'وزنه را از کنار بدن تا نزدیک شانه بالا بیاور و با کنترل کامل پایین برگردان.',
            targetMuscles: ['جلو بازو'],
            secondaryMuscles: ['ساعد'],
            keyTips: [
              'آرنج جلو نرود.',
              'بدن را تاب نده.',
              'در پایین حرکت وزنه را رها نکن.',
            ],
            imageAssetPath: 'assets/exercises/biceps_curl.png',
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-4',
        title: 'Day 3: Lower Body B',
        focus: 'پشت پا و باسن',
        dayNumber: 3,
        cardioMinutes: 25,
        location: WorkoutLocation.gym,
        exercises: const [
          Exercise(
            id: 'd4-e1',
            name: 'الپتیکال',
            type: ExerciseType.cardio,
            targetDurationMinutes: 8,
            notes: 'مناسب زانو',
            guideText: 'برای گرم‌کردن زانو و پایین‌تنه پیش از تمرین استفاده شود.',
            instructionText:
                'روی الپتیکال با ریتم یکنواخت و فشار ملایم تا متوسط حرکت کن تا مفاصل و عضلات آماده شوند.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'ساق پا', 'سرشانه'],
            keyTips: [
              'فشار را تدریجی بالا ببر.',
              'ریتم یکنواخت حفظ شود.',
              'اگر زانو حساس است از این گزینه استفاده کن.',
            ],
            imageAssetPath: 'assets/exercises/elliptical.png',
          ),
          Exercise(
            id: 'd4-e2',
            name: 'Romanian Deadlift',
            type: ExerciseType.strength,
            sets: 4,
            reps: '8-10',
            notes: 'کمر صاف، کشش پشت پا',
            guideText: 'حرکت از مفصل لگن آغاز شود و کشش پشت پا حس شود.',
            instructionText:
                'وزنه را جلوی بدن نگه دار، لگن را عقب ببر و با زانوی نرم تا جایی پایین برو که کشش پشت پا حفظ شود.',
            targetMuscles: ['همسترینگ', 'باسن'],
            secondaryMuscles: ['پایین کمر', 'عضلات مرکزی'],
            keyTips: [
              'کمر صاف بماند.',
              'وزنه از بدن دور نشود.',
              'حرکت را با خم زیاد زانو به اسکوات تبدیل نکن.',
            ],
            imageAssetPath: 'assets/exercises/romanian_deadlift.png',
          ),
          Exercise(
            id: 'd4-e3',
            name: 'Hip Thrust',
            type: ExerciseType.strength,
            sets: 4,
            reps: '10-12',
            notes: 'مکث بالا',
            guideText: 'انقباض کامل باسن در بالای حرکت مهم است.',
            instructionText:
                'پشت بالای بدن را روی نیمکت قرار بده و با فشار پاشنه‌ها لگن را بالا بیاور تا باسن کامل منقبض شود.',
            targetMuscles: ['باسن'],
            secondaryMuscles: ['همسترینگ', 'چهارسر ران'],
            keyTips: [
              'در بالا مکث کوتاه داشته باش.',
              'گردن را رها نکن.',
              'کمر را بیش از حد قوس نده.',
            ],
            imageAssetPath: 'assets/exercises/hip_thrust.png',
          ),
          Exercise(
            id: 'd4-e4',
            name: 'Leg Curl',
            type: ExerciseType.strength,
            sets: 4,
            reps: '10-12',
            notes: 'کنترل کامل',
            guideText: 'پشت پا دستگاه با بازگشت کنترل‌شده انجام شود.',
            instructionText:
                'پد دستگاه را به سمت بدن بکش و در مسیر برگشت وزنه را آرام و تحت کنترل پایین بیاور.',
            targetMuscles: ['همسترینگ'],
            secondaryMuscles: ['ساق پا'],
            keyTips: [
              'لگن از دستگاه جدا نشود.',
              'وزنه را رها نکن.',
              'دامنه کامل را حفظ کن.',
            ],
            imageAssetPath: 'assets/exercises/leg_curl.png',
          ),
          Exercise(
            id: 'd4-e6',
            name: 'Reverse Lunge',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10 هر پا',
            notes: 'معمولاً زانو‌دوست‌تر از لانج جلو',
            guideText: 'لانج عقب با کنترل تعادل و حفظ مسیر زانو انجام شود.',
            instructionText:
                'یک پا را به عقب ببر، زانوی جلو را در راستای پنجه نگه دار و با کنترل پایین برو و بالا برگرد.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'عضلات مرکزی'],
            keyTips: [
              'قدم عقب را خیلی کوتاه نگیر.',
              'زانوی جلو به داخل نرود.',
              'حرکت را آرام و بدون ضربه انجام بده.',
            ],
            imageAssetPath: 'assets/exercises/reverse_lunge.png',
          ),
          Exercise(
            id: 'd4-e7',
            name: 'Hip Abduction Machine',
            type: ExerciseType.strength,
            sets: 3,
            reps: '15',
            notes: 'کمک به ثبات زانو',
            guideText: 'باز کردن پاها روی دستگاه با مکث کوتاه و کنترل کامل انجام شود.',
            instructionText:
                'روی دستگاه بنشین، لگن را ثابت نگه دار و پاها را به طرفین باز کن، سپس با کنترل برگردان.',
            targetMuscles: ['سرینی میانی', 'سرینی کوچک'],
            secondaryMuscles: ['تثبیت‌کننده‌های لگن'],
            keyTips: [
              'با تاب کمر کمک نگیر.',
              'در انتهای باز شدن مکث کوتاه داشته باش.',
              'حرکت برای ثبات زانو مفید است.',
            ],
            imageAssetPath: 'assets/exercises/hip_abduction_machine.png',
          ),
          Exercise(
            id: 'd4-e8',
            name: 'Standing Calf Raise',
            type: ExerciseType.strength,
            sets: 4,
            reps: '12-15',
            notes: 'مکث بالا',
            guideText: 'ساق ایستاده با مکث بالا و کشش پایین انجام شود.',
            instructionText:
                'از مچ پا بالا برو، در بالای حرکت کمی مکث کن و سپس پاشنه را با کنترل پایین ببر.',
            targetMuscles: ['ساق پا'],
            secondaryMuscles: ['عضلات کف پا'],
            keyTips: [
              'بالا رفتن پرشی نباشد.',
              'در پایین کشش کامل بگیر.',
              'مکث کوتاه بالا را حفظ کن.',
            ],
            imageAssetPath: 'assets/exercises/standing_calf_raise.png',
          ),
          Exercise(
            id: 'd4-e5',
            name: 'Dead Bug',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '10 هر سمت',
            notes: 'کنترل کمر',
            guideText: 'پایدارسازی مرکزی با حفظ تماس کمر با زمین.',
            instructionText:
                'به پشت بخواب، دست‌ها و زانوها را بالا نگه دار و هم‌زمان دست و پای مخالف را با کنترل دور کن و برگرد.',
            targetMuscles: ['عضلات مرکزی', 'پایدارکننده‌های ستون فقرات'],
            secondaryMuscles: ['فلکسورهای ران', 'سرشانه'],
            keyTips: [
              'کمر از زمین جدا نشود.',
              'حرکت آهسته انجام شود.',
              'اگر فرم از بین رفت دامنه را کمتر کن.',
            ],
            imageAssetPath: 'assets/exercises/dead_bug.png',
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-5',
        title: 'Day 4: Upper Body B + Corrective',
        focus: 'بالاتنه و اصلاحی',
        dayNumber: 4,
        cardioMinutes: 25,
        location: WorkoutLocation.gym,
        exercises: const [
          Exercise(
            id: 'd5-e1',
            name: 'Incline Dumbbell Press',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10',
            notes: 'کنترل کامل',
            guideText: 'پرس دمبل شیبدار با کنترل کامل و بدون عجله انجام شود.',
            instructionText:
                'روی نیمکت شیبدار بنشین و دمبل‌ها را از کنار سینه با کنترل به بالا پرس کن و آرام پایین بیاور.',
            targetMuscles: ['بالای سینه', 'جلوی سرشانه'],
            secondaryMuscles: ['پشت بازو', 'عضلات مرکزی'],
            keyTips: [
              'دمبل‌ها را به هم نکوب.',
              'آرنج خیلی باز نشود.',
              'در پایین کشش کنترل‌شده حفظ شود.',
            ],
            imageAssetPath: 'assets/exercises/incline_dumbbell_press.png',
          ),
          Exercise(
            id: 'd5-e6',
            name: 'Assisted Pull-up',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10',
            notes: 'در صورت نیاز Lat Pulldown دست جمع جایگزین شود',
            guideText: 'پول‌آپ کمکی با کنترل کامل و دامنه مناسب انجام شود.',
            instructionText:
                'روی دستگاه پول‌آپ کمکی قرار بگیر، با پایین نگه داشتن شانه‌ها بدن را بالا بکش و سپس آرام پایین برگرد.',
            targetMuscles: ['زیربغل', 'پشت میانی'],
            secondaryMuscles: ['جلو بازو', 'پشت شانه', 'عضلات مرکزی'],
            keyTips: [
              'شانه‌ها را بالا ننداز.',
              'بدن را تاب نده.',
              'بازگشت حرکت آرام باشد.',
            ],
            alternativeText: 'در صورت نیاز Close-Grip Lat Pulldown جایگزین شود.',
            imageAssetPath: 'assets/exercises/assisted_pullup.png',
          ),
          Exercise(
            id: 'd5-e2',
            name: 'Cable Row تک‌دست',
            type: ExerciseType.strength,
            sets: 3,
            reps: '12 هر سمت',
            notes: 'تمرکز روی کتف',
            guideText: 'روینگ تک‌دست با تمرکز روی جمع شدن کتف اجرا شود.',
            instructionText:
                'روبه‌روی کابل بنشین یا بایست، دسته را با یک دست بگیر و آرنج را نزدیک بدن به عقب بکش.',
            targetMuscles: ['زیربغل', 'پشت میانی'],
            secondaryMuscles: ['پشت شانه', 'جلو بازو', 'عضلات مرکزی'],
            keyTips: [
              'بدن را نچرخان.',
              'در انتهای حرکت مکث کوتاه داشته باش.',
              'حرکت را با کنترل انجام بده.',
            ],
            imageAssetPath: 'assets/exercises/cable_row_single_arm.png',
          ),
          Exercise(
            id: 'd5-e3',
            name: 'Lateral Raise',
            type: ExerciseType.strength,
            sets: 4,
            reps: '12-15',
            notes: 'وزنه سبک، فرم تمیز',
            guideText: 'نشر جانب با وزنه سبک و فرم تمیز انجام شود.',
            instructionText:
                'دمبل‌ها را در کنار بدن نگه دار و با آرنج کمی خم آن‌ها را تا ارتفاع شانه بالا بیاور.',
            targetMuscles: ['سرشانه میانی'],
            secondaryMuscles: ['پشت شانه', 'کول فوقانی'],
            keyTips: [
              'بدن را تاب نده.',
              'شانه‌ها بالا نروند.',
              'وزنه را بالاتر از خط شانه نبر.',
            ],
            imageAssetPath: 'assets/exercises/lateral_raise.png',
          ),
          Exercise(
            id: 'd5-e7',
            name: 'Rear Delt Fly',
            type: ExerciseType.strength,
            sets: 3,
            reps: '15',
            notes: 'کنترل‌شده',
            guideText: 'پشت شانه با باز شدن دست‌ها و کنترل کامل تمرین داده شود.',
            instructionText:
                'با تنه ثابت و کمی خم، دست‌ها را به طرفین باز کن تا پشت شانه درگیر شود و سپس آرام برگردان.',
            targetMuscles: ['پشت شانه'],
            secondaryMuscles: ['عضلات بین کتف', 'کول میانی'],
            keyTips: [
              'گردن را سفت نکن.',
              'حرکت را با تاب تنه انجام نده.',
              'در انتهای حرکت مکث کوتاه داشته باش.',
            ],
            imageAssetPath: 'assets/exercises/rear_delt_fly.png',
          ),
          Exercise(
            id: 'd5-e8',
            name: 'Farmer Carry',
            type: ExerciseType.strength,
            sets: 3,
            reps: '30 تا 40 متر',
            notes: 'شکم سفت، شانه عقب',
            guideText: 'حمل وزنه با قامت صاف و کنترل تنه انجام شود.',
            instructionText:
                'دو وزنه را در دو دست بگیر، شکم را سفت کن و با قدم‌های کنترل‌شده مسیر 30 تا 40 متر را طی کن.',
            targetMuscles: ['ساعد', 'کول'],
            secondaryMuscles: ['عضلات مرکزی', 'سرشانه'],
            keyTips: [
              'شانه‌ها عقب و پایین بمانند.',
              'به یک سمت خم نشو.',
              'قدم‌ها کوتاه و کنترل‌شده باشد.',
            ],
            imageAssetPath: 'assets/exercises/farmer_carry.png',
          ),
          Exercise(
            id: 'd5-e4',
            name: 'Pallof Press',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '12 هر سمت',
            notes: 'ضدچرخش',
            guideText: 'تمرین ضدچرخش برای پایداری مرکزی تنه.',
            instructionText:
                'کنار کابل بایست، دسته را جلوی سینه بگیر و بدون چرخش تنه دست‌ها را مستقیم به جلو پرس کن.',
            targetMuscles: ['عضلات مرکزی', 'مورب‌های شکم'],
            secondaryMuscles: ['سرشانه', 'باسن'],
            keyTips: [
              'تنه نچرخد.',
              'زانوها قفل نشوند.',
              'شکم در تمام حرکت سفت بماند.',
            ],
            imageAssetPath: 'assets/exercises/pallof_press.png',
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-outdoor',
        title: 'Day 5: Outdoor Walking',
        focus: 'پیاده‌روی آخر هفته',
        dayNumber: 5,
        cardioMinutes: 60,
        location: WorkoutLocation.outdoor,
        exercises: const [
          Exercise(
            id: 'outdoor-walk',
            name: 'پیاده‌روی',
            type: ExerciseType.cardio,
            targetDurationMinutes: 60,
            notes: '45 تا 60 دقیقه آرام',
            guideText: 'پیاده‌روی آرام و پیوسته برای آخر هفته.',
            instructionText:
                'با قامت صاف، قدم‌های یکنواخت و سرعت قابل ادامه راه برو تا بین 45 تا 60 دقیقه فعال بمانی.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'ساق پا'],
            keyTips: [
              'سرعت را قابل‌گفت‌وگو نگه دار.',
              'کفش مناسب بپوش.',
              'اگر خسته شدی چند دقیقه آرام‌تر راه برو.',
            ],
            imageAssetPath: 'assets/exercises/outdoor_walking.png',
          ),
        ],
      ),
    ];
  }

  static List<MealPlan> mealPlans() {
    return [
      MealPlan(
        id: 'training-day',
        title: 'روز تمرین',
        isTrainingDay: true,
        meals: const [
          Meal(
            id: 't-breakfast',
            title: 'صبحانه',
            description: 'نان سنگک، تخم‌مرغ، خیار و گوجه',
            proteinGrams: 30,
          ),
          Meal(
            id: 't-lunch',
            title: 'ناهار',
            description: 'برنج کنترل‌شده، مرغ یا گوشت کم‌چرب، سالاد',
            proteinGrams: 40,
          ),
          Meal(
            id: 't-snack',
            title: 'عصرانه مهم',
            description: 'ماست یونانی یا شیک پروتئینی با میوه',
            proteinGrams: 25,
            isPriority: true,
          ),
          Meal(
            id: 't-dinner',
            title: 'شام',
            description: 'سیب‌زمینی یا نان، پروتئین و سبزیجات',
            proteinGrams: 35,
          ),
        ],
      ),
      MealPlan(
        id: 'rest-day',
        title: 'روز غیرتمرین',
        isTrainingDay: false,
        meals: const [
          Meal(
            id: 'r-breakfast',
            title: 'صبحانه',
            description: 'املت یا پنیر کم‌چرب با سبزیجات',
            proteinGrams: 25,
          ),
          Meal(
            id: 'r-lunch',
            title: 'ناهار',
            description: 'پروتئین اصلی با سبزیجات و سهم کنترل‌شده کربوهیدرات',
            proteinGrams: 35,
          ),
          Meal(
            id: 'r-snack',
            title: 'عصرانه مهم',
            description: 'مغزها + ماست یا شیر کم‌چرب',
            proteinGrams: 20,
            isPriority: true,
          ),
          Meal(
            id: 'r-dinner',
            title: 'شام',
            description: 'سوپ سبک یا مرغ و سالاد',
            proteinGrams: 30,
          ),
        ],
      ),
    ];
  }

  static List<Supplement> supplements() {
    return const [
      Supplement(
        id: 'supp-1',
        name: 'Neuro B-Vit',
        scheduleLabel: 'روزانه',
        note: 'صبح بعد از صبحانه',
      ),
      Supplement(
        id: 'supp-2',
        name: 'Sideral Forte',
        scheduleLabel: 'روزانه',
        note: 'عصر یا شب، با فاصله از چای، قهوه و لبنیات',
      ),
      Supplement(
        id: 'supp-3',
        name: 'Whey Protein',
        scheduleLabel: 'روز تمرین',
        note: 'بعد از تمرین',
      ),
      Supplement(
        id: 'supp-4',
        name: 'Vitamin D 50000',
        scheduleLabel: 'هفتگی',
        note: 'یکشنبه ساعت ۱۲ ظهر',
      ),
    ];
  }

  static List<BodyProgress> progressEntries() {
    return [
      BodyProgress(
        id: 'progress-initial',
        date: DateTime.now(),
        weightKg: 87,
        waistCm: 100,
        steps: 8000,
        note: 'شروع برنامه',
      ),
    ];
  }
}
