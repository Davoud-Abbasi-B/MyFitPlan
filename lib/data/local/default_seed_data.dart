import '../../core/utils/date_utils.dart';
import '../../features/checklist/models/daily_checklist_model.dart';
import '../../features/nutrition/models/meal_model.dart';
import '../../features/nutrition/models/meal_plan_model.dart';
import '../../features/progress/models/body_progress_model.dart';
import '../../features/settings/models/user_profile_model.dart';
import '../../features/supplements/models/supplement_model.dart';
import '../../features/workout/models/exercise_model.dart';
import '../../features/workout/models/workout_day_model.dart';
import 'hypertrophy_workout_seed.dart';

abstract final class DefaultSeedData {
  static const int workoutSeedVersion = 6;

  static List<WorkoutDay> workouts() => hypertrophyWorkoutPlan();

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

  static List<WorkoutDay> legacyWorkouts() {
    return const [
      WorkoutDay(
        id: 'day-1',
        title: 'Day 1: Lower Body A + Abs 1',
        focus: 'پایین‌تنه A + شکم جلسه ۱',
        dayNumber: 1,
        cardioMinutes: 25,
        location: WorkoutLocation.gym,
        exercises: [
          Exercise(
            id: 'd1-e1',
            name: 'دوچرخه ثابت یا الپتیکال',
            type: ExerciseType.cardio,
            targetDurationMinutes: 8,
            notes: 'گرم‌کردن سبک',
            instructionText:
                'با شدت سبک شروع کن تا زانو، لگن و پایین‌تنه برای تمرین اصلی آماده شوند.',
            targetMuscles: ['چهارسر ران', 'همسترینگ'],
            secondaryMuscles: ['باسن', 'ساق پا'],
            keyTips: [
              'ریتم یکنواخت و سبک نگه داشته شود.',
              'اگر زانو حساس بود، الپتیکال انتخاب امن‌تری است.',
              'در این بخش دنبال خستگی نیستیم؛ فقط آماده‌سازی انجام می‌شود.',
            ],
            imageAssetPath: 'assets/exercises/bicycle.png',
          ),
          Exercise(
            id: 'd1-e2',
            name: 'Leg Press',
            type: ExerciseType.strength,
            sets: 4,
            reps: '10-12',
            notes: 'زانو داخل نرود',
            instructionText:
                'روی دستگاه بنشین، پاها را به اندازه عرض شانه روی صفحه قرار بده و وزنه را با کنترل پایین و بالا ببر.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'ساق پا'],
            keyTips: [
              'زانوها با پنجه هم‌راستا بمانند.',
              'وزنه را با کنترل پایین بیاور.',
              'در بالا زانو را کامل قفل نکن.',
            ],
            imageAssetPath: 'assets/exercises/leg_press.png',
          ),
          Exercise(
            id: 'd1-e3',
            name: 'Smith Squat',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10',
            notes: 'دامنه بدون درد',
            instructionText:
                'زیر دستگاه اسمیت قرار بگیر، پاها کمی جلوتر باشند و با کنترل تا دامنه بدون درد پایین برو و بالا بیا.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'عضلات مرکزی'],
            keyTips: [
              'دامنه حرکت کاملا بدون درد باشد.',
              'زانو با پنجه هم‌راستا بماند.',
              'کمر خنثی و سینه بالا حفظ شود.',
            ],
            imageAssetPath: 'assets/exercises/smith_squat.png',
          ),
          Exercise(
            id: 'd1-e4',
            name: 'Step-up',
            type: ExerciseType.strength,
            sets: 3,
            reps: '8 هر پا',
            notes:
                'ارتفاع پله کم و کنترل‌شده باشد؛ اگر زانو اذیت شد، حرکت همان جلسه حذف شود یا با Leg Press سبک جایگزین شود.',
            instructionText:
                'یک پا را روی جعبه یا پله بگذار، با فشار همان پا بالا برو و آرام پایین بیا.',
            targetMuscles: ['چهارسر ران', 'باسن', 'همسترینگ'],
            secondaryMuscles: ['ساق پا', 'عضلات مرکزی'],
            keyTips: [
              'ارتفاع پله کم و متناسب با زانو باشد.',
              'زانو به داخل جمع نشود.',
              'حرکت کاملا کنترل‌شده انجام شود.',
            ],
            alternativeText:
                'اگر زانو در همان جلسه اذیت شد، حرکت حذف شود یا با Leg Press سبک جایگزین شود.',
            imageAssetPath: 'assets/exercises/step_up.png',
          ),
          Exercise(
            id: 'd1-e5',
            name: 'Leg Extension',
            type: ExerciseType.strength,
            sets: 3,
            reps: '12-15',
            notes: 'مکث کوتاه بالا',
            instructionText:
                'ساق را تا نزدیکی صاف شدن زانو بالا بیاور، یک مکث کوتاه داشته باش و آرام پایین برگرد.',
            targetMuscles: ['چهارسر ران'],
            secondaryMuscles: ['فلکسورهای ران'],
            keyTips: [
              'وزنه کنترل‌شده باشد.',
              'بالای حرکت یک مکث کوتاه نگه دار.',
              'در پایین حرکت وزنه را رها نکن.',
            ],
            imageAssetPath: 'assets/exercises/leg_extension.png',
          ),
          Exercise(
            id: 'd1-e6',
            name: 'Seated Calf Raise',
            type: ExerciseType.strength,
            sets: 4,
            reps: '12-15',
            notes: 'کنترل کامل',
            instructionText:
                'پاشنه را پایین ببر و سپس با فشار پنجه‌ها تا انقباض کامل ساق بالا بیاور.',
            targetMuscles: ['ساق پا'],
            secondaryMuscles: ['عضلات کف پا'],
            keyTips: [
              'در پایین کشش کامل بگیر.',
              'بالا مکث کوتاه داشته باش.',
              'حرکت را پرشی انجام نده.',
            ],
            imageAssetPath: 'assets/exercises/seated_calf_raise.png',
          ),
          Exercise(
            id: 'd1-e6a',
            name: 'Cable Crunch',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '12-15',
            notes: 'وزنه کنترل‌شده، شکم را جمع کن',
            instructionText:
                'روبه‌روی دستگاه کابل زانو بزن، طناب را کنار سر نگه دار و با جمع کردن شکم، تنه را به سمت پایین خم کن.',
            targetMuscles: ['راست شکمی', 'عضلات مرکزی'],
            secondaryMuscles: ['مورب‌های شکم'],
            keyTips: [
              'حرکت را با دست نکش.',
              'تمرکز روی جمع شدن شکم باشد.',
              'وزنه کنترل‌شده انتخاب شود.',
            ],
            imageAssetPath: 'assets/exercises/cable_crunch.png',
          ),
          Exercise(
            id: 'd1-e7',
            name: 'Plank',
            type: ExerciseType.bodyweight,
            sets: 3,
            targetDurationSeconds: 60,
            notes: 'بدن صاف، کمر گود نشود',
            instructionText:
                'ساعدها روی زمین، بدن در یک خط صاف، شکم منقبض و لگن ثابت باشد.',
            targetMuscles: ['عضلات مرکزی شکم', 'راست شکمی'],
            secondaryMuscles: ['سرشانه', 'باسن', 'پایین کمر'],
            keyTips: [
              'هدف واقعی این حرکت ۴۵ تا ۶۰ ثانیه با فرم خوب است.',
              'کمر را گود نکن.',
              'باسن را بیش از حد بالا نبر.',
            ],
            imageAssetPath: 'assets/exercises/plank.png',
          ),
          Exercise(
            id: 'd1-e8',
            name: 'هوازی',
            type: ExerciseType.cardio,
            targetDurationMinutes: 25,
            notes: 'شیب ملایم یا الپتیکال',
            instructionText:
                'بعد از وزنه، ۲۰ تا ۲۵ دقیقه هوازی با شدت متوسط انجام بده. اگر فقط یک عدد لازم است، ۲۵ دقیقه را ثبت کن.',
            targetMuscles: ['سیستم قلبی تنفسی'],
            secondaryMuscles: ['پایین‌تنه'],
            keyTips: [
              'شدت متوسط باشد.',
              'اگر زانو حساس شد، الپتیکال یا دوچرخه ثابت بهتر است.',
              'هوازی بعد از تمرین قدرتی انجام شود.',
            ],
            imageAssetPath: 'assets/exercises/elliptical.png',
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-2',
        title: 'Day 2: Upper Body A',
        focus: 'بالاتنه A',
        dayNumber: 2,
        cardioMinutes: 20,
        location: WorkoutLocation.gym,
        exercises: [
          Exercise(
            id: 'd2-e0',
            name: 'هوازی سبک + گرم‌کردن شانه',
            type: ExerciseType.cardio,
            targetDurationMinutes: 8,
            notes: 'آماده‌سازی',
            instructionText:
                '۵ تا ۸ دقیقه هوازی سبک انجام بده و شانه‌ها را با حرکات کنترل‌شده برای پرس و کشش آماده کن.',
            targetMuscles: ['سیستم قلبی تنفسی'],
            secondaryMuscles: ['سرشانه', 'پشت بالا'],
            keyTips: [
              'فشار این بخش سبک بماند.',
              'حرکات شانه بدون درد انجام شوند.',
              'اگر گردن سفت بود، چند تکرار face pull سبک اضافه کن.',
            ],
            imageAssetPath: 'assets/exercises/elliptical.png',
          ),
          Exercise(
            id: 'd2-e1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: 4,
            reps: '8-10',
            notes: 'کنترل مسیر حرکت',
            instructionText:
                'روی نیمکت دراز بکش، میله را با کنترل تا نزدیکی سینه پایین بیاور و با ثبات شانه‌ها پرس کن.',
            targetMuscles: ['سینه', 'جلوی سرشانه'],
            secondaryMuscles: ['پشت بازو', 'عضلات مرکزی'],
            keyTips: [
              'تیغه‌های کتف جمع بمانند.',
              'مچ را نشکن.',
              'مسیر حرکت کنترل‌شده باشد.',
            ],
            alternativeText:
                'در صورت نیاز Chest Press Machine می‌تواند جایگزین باشد.',
            imageAssetPath: 'assets/exercises/bench_press.png',
          ),
          Exercise(
            id: 'd2-e2',
            name: 'Lat Pulldown',
            type: ExerciseType.strength,
            sets: 4,
            reps: '10-12',
            notes: 'کشش کامل',
            instructionText:
                'میله را به سمت بالای سینه بکش و در مسیر برگشت هم کنترل را حفظ کن.',
            targetMuscles: ['زیربغل', 'پشت میانی'],
            secondaryMuscles: ['جلو بازو', 'پشت شانه'],
            keyTips: [
              'شانه‌ها را بالا نینداز.',
              'بدن را زیاد عقب نبر.',
              'کشش بالا و جمع کردن پایین هر دو کامل باشند.',
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
            instructionText:
                'دسته را به سمت شکم بکش و در انتهای حرکت تیغه‌های کتف را به هم نزدیک کن.',
            targetMuscles: ['پشت میانی', 'زیربغل'],
            secondaryMuscles: ['جلو بازو', 'پشت شانه'],
            keyTips: [
              'کمر خنثی بماند.',
              'حرکت را با تاب انجام نده.',
              'در انتهای حرکت مکث کوتاه داشته باش.',
            ],
            imageAssetPath: 'assets/exercises/seated_row.png',
          ),
          Exercise(
            id: 'd2-e4',
            name: 'Dumbbell Shoulder Press',
            type: ExerciseType.strength,
            sets: 3,
            reps: '8-10',
            notes: 'بدون فشار به گردن',
            instructionText:
                'دمبل‌ها را از کنار شانه به بالای سر پرس کن و با کنترل پایین بیاور.',
            targetMuscles: ['سرشانه جلویی', 'سرشانه میانی'],
            secondaryMuscles: ['پشت بازو', 'تثبیت‌کننده‌های کتف'],
            keyTips: [
              'گردن را جمع نکن.',
              'کمر را زیاد گود نکن.',
              'مسیر حرکت کنترل‌شده باشد.',
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
            instructionText:
                'طناب را هم‌سطح صورت بگیر و با باز شدن دست‌ها آن را به سمت بینی و پیشانی بکش.',
            targetMuscles: ['پشت شانه', 'عضلات بین کتف'],
            secondaryMuscles: ['روتاتور کاف', 'کول میانی'],
            keyTips: [
              'گردن جلو نرود.',
              'در انتهای حرکت مکث کوتاه داشته باش.',
              'وزنه متوسط و کنترل‌شده باشد.',
            ],
            imageAssetPath: 'assets/exercises/face_pull.png',
          ),
          Exercise(
            id: 'd2-e6',
            name: 'Cable Triceps Pushdown',
            type: ExerciseType.strength,
            sets: 3,
            reps: '12',
            notes: 'آرنج ثابت',
            instructionText:
                'طناب یا میله را به سمت پایین فشار بده و فقط از مفصل آرنج حرکت کن.',
            targetMuscles: ['پشت بازو'],
            secondaryMuscles: ['ساعد'],
            keyTips: [
              'آرنج‌ها نزدیک بدن بمانند.',
              'شانه‌ها را بالا نبر.',
              'برگشت حرکت آرام باشد.',
            ],
            imageAssetPath: 'assets/exercises/triceps_pushdown.png',
          ),
          Exercise(
            id: 'd2-e7',
            name: 'Dumbbell Curl',
            type: ExerciseType.strength,
            sets: 3,
            reps: '12',
            notes: 'کنترل کامل',
            instructionText:
                'دمبل‌ها را تا نزدیکی شانه بالا بیاور و بدون تاب دادن بدن پایین برگردان.',
            targetMuscles: ['جلو بازو'],
            secondaryMuscles: ['ساعد'],
            keyTips: [
              'آرنج جلو نرود.',
              'بدن تاب نخورد.',
              'فاز منفی آرام باشد.',
            ],
            imageAssetPath: 'assets/exercises/biceps_curl.png',
          ),
          Exercise(
            id: 'd2-e8',
            name: 'Pallof Press',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '12 هر سمت',
            notes: 'ضدچرخش؛ عالی برای میان‌تنه',
            instructionText:
                'کنار کابل بایست، دسته را جلوی سینه بگیر و بدون چرخش تنه دست‌ها را به جلو پرس کن.',
            targetMuscles: ['عضلات مرکزی', 'مورب‌های شکم'],
            secondaryMuscles: ['سرشانه', 'باسن'],
            keyTips: [
              'تنه را نچرخان.',
              'شکم را سفت نگه دار.',
              'هر دو سمت با کنترل یکسان انجام شود.',
            ],
            imageAssetPath: 'assets/exercises/pallof_press.png',
          ),
          Exercise(
            id: 'd2-e9',
            name: 'Reverse Crunch',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '12-15',
            notes: 'آرام و کنترل‌شده',
            instructionText:
                'به پشت بخواب، زانوها خم باشند و لگن را آرام از زمین جدا کن و زانوها را به سمت سینه بیاور.',
            targetMuscles: ['پایین شکم', 'راست شکمی', 'عضلات مرکزی'],
            secondaryMuscles: ['فلکسورهای ران'],
            keyTips: [
              'تاب نخور.',
              'حرکت را آرام انجام بده.',
              'کمر را کنترل کن.',
            ],
            imageAssetPath: 'assets/exercises/reverse_crunch.png',
          ),
          Exercise(
            id: 'd2-e10',
            name: 'هوازی',
            type: ExerciseType.cardio,
            targetDurationMinutes: 20,
            notes: 'شدت متوسط',
            instructionText:
                'در پایان جلسه ۲۰ دقیقه هوازی با شدت متوسط انجام بده.',
            targetMuscles: ['سیستم قلبی تنفسی'],
            secondaryMuscles: ['پایین‌تنه'],
            keyTips: [
              'هوازی بعد از وزنه انجام شود.',
              'شدت متوسط و قابل‌ادامه باشد.',
              'تردمیل، دوچرخه یا الپتیکال مناسب هستند.',
            ],
            imageAssetPath: 'assets/exercises/treadmill.png',
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-4',
        title: 'Day 3: Lower Body B + Abs 2',
        focus: 'پایین‌تنه B + شکم جلسه ۲',
        dayNumber: 3,
        cardioMinutes: 25,
        location: WorkoutLocation.gym,
        exercises: [
          Exercise(
            id: 'd4-e1',
            name: 'دوچرخه ثابت',
            type: ExerciseType.cardio,
            targetDurationMinutes: 8,
            notes: 'گرم‌کردن زانو‌دوست',
            instructionText:
                'با ریتم آرام شروع کن تا زانو و پایین‌تنه برای حرکات پشت پا و باسن آماده شوند.',
            targetMuscles: ['چهارسر ران', 'همسترینگ'],
            secondaryMuscles: ['باسن', 'ساق پا'],
            keyTips: [
              'شدت سبک تا متوسط باشد.',
              'اگر زانو حساس بود، این گرم‌کردن اولویت دارد.',
              'هدف، آماده‌سازی است نه خستگی.',
            ],
            imageAssetPath: 'assets/exercises/bicycle.png',
          ),
          Exercise(
            id: 'd4-e2',
            name: 'Romanian Deadlift',
            type: ExerciseType.strength,
            sets: 4,
            reps: '8-10',
            notes: 'کمر صاف، کشش پشت پا',
            instructionText:
                'لگن را عقب ببر، کمر را صاف نگه دار و وزنه را نزدیک بدن پایین بیاور تا کشش پشت پا را حس کنی.',
            targetMuscles: ['همسترینگ', 'باسن'],
            secondaryMuscles: ['پایین کمر', 'عضلات مرکزی'],
            keyTips: [
              'کمر صاف بماند.',
              'حرکت از لگن شروع شود.',
              'وزنه از بدن دور نشود.',
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
            instructionText:
                'با فشار پاشنه‌ها لگن را بالا بیاور و در بالای حرکت باسن را کامل منقبض کن.',
            targetMuscles: ['باسن'],
            secondaryMuscles: ['همسترینگ', 'چهارسر ران'],
            keyTips: [
              'بالای حرکت مکث کوتاه داشته باش.',
              'کمر را بیش از حد قوس نده.',
              'چانه را کنترل‌شده نگه دار.',
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
            instructionText:
                'در نوع خوابیده یا نشسته، پد دستگاه را به سمت بدن بکش و در برگشت وزنه را آرام پایین بیاور.',
            targetMuscles: ['همسترینگ'],
            secondaryMuscles: ['ساق پا'],
            keyTips: [
              'دامنه کامل حفظ شود.',
              'وزنه در برگشت رها نشود.',
              'لگن از دستگاه جدا نشود.',
            ],
            alternativeText:
                'بسته به باشگاه می‌توان از نوع خوابیده یا نشسته استفاده کرد.',
            imageAssetPath: 'assets/exercises/leg_curl.png',
          ),
          Exercise(
            id: 'd4-e6',
            name: 'Reverse Lunge',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10 هر پا',
            notes: 'زانو‌دوست‌تر از لانج جلو',
            instructionText:
                'یک پا را به عقب ببر، با کنترل پایین برو و با فشار پای جلو برگرد.',
            targetMuscles: ['چهارسر ران', 'باسن'],
            secondaryMuscles: ['همسترینگ', 'عضلات مرکزی'],
            keyTips: [
              'زانوی جلو به داخل نرود.',
              'قدم عقب خیلی کوتاه نباشد.',
              'حرکت بدون ضربه انجام شود.',
            ],
            imageAssetPath: 'assets/exercises/reverse_lunge.png',
          ),
          Exercise(
            id: 'd4-e7',
            name: 'Hip Abduction Machine',
            type: ExerciseType.strength,
            sets: 3,
            reps: '15',
            notes: 'ثبات لگن و زانو',
            instructionText:
                'روی دستگاه بنشین، لگن را ثابت نگه دار و پاها را با کنترل به طرفین باز کن.',
            targetMuscles: ['سرینی میانی', 'سرینی کوچک'],
            secondaryMuscles: ['تثبیت‌کننده‌های لگن'],
            keyTips: [
              'از تاب کمر کمک نگیر.',
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
            instructionText:
                'از مچ پا بالا برو، در بالا کمی مکث کن و سپس پاشنه را با کنترل پایین ببر.',
            targetMuscles: ['ساق پا'],
            secondaryMuscles: ['عضلات کف پا'],
            keyTips: [
              'بالا رفتن پرشی نباشد.',
              'در پایین کشش کامل بگیر.',
              'مکث کوتاه بالا حفظ شود.',
            ],
            imageAssetPath: 'assets/exercises/standing_calf_raise.png',
          ),
          Exercise(
            id: 'd4-e9',
            name: 'Captain Chair',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '10-15',
            notes: 'لگن را جمع کن، تاب نخور',
            instructionText:
                'روی دستگاه قرار بگیر، بدن ثابت باشد و زانوها را کنترل‌شده بالا بیاور.',
            targetMuscles: ['پایین شکم', 'راست شکمی'],
            secondaryMuscles: ['خم‌کننده‌های ران'],
            keyTips: [
              'تاب نخور.',
              'لگن را جمع کن.',
              'با کنترل پایین بیا.',
            ],
            imageAssetPath: 'assets/exercises/captain_chair.png',
          ),
          Exercise(
            id: 'd4-e5',
            name: 'Dead Bug',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '10 هر سمت',
            notes: 'کنترل کمر',
            instructionText:
                'به پشت بخواب، دست و پای مخالف را با کنترل دور کن و تماس کمر با زمین را حفظ کن.',
            targetMuscles: ['عضلات مرکزی', 'پایدارکننده‌های ستون فقرات'],
            secondaryMuscles: ['فلکسورهای ران', 'سرشانه'],
            keyTips: [
              'کمر از زمین جدا نشود.',
              'حرکت آهسته انجام شود.',
              'اگر فرم خراب شد دامنه را کمتر کن.',
            ],
            imageAssetPath: 'assets/exercises/dead_bug.png',
          ),
          Exercise(
            id: 'd4-e10',
            name: 'هوازی',
            type: ExerciseType.cardio,
            targetDurationMinutes: 25,
            notes: 'اگر پا خسته بود دوچرخه سبک',
            instructionText:
                'در پایان جلسه ۲۰ تا ۲۵ دقیقه هوازی متوسط انجام بده. اگر پا خسته بود دوچرخه سبک گزینه بهتری است.',
            targetMuscles: ['سیستم قلبی تنفسی'],
            secondaryMuscles: ['پایین‌تنه'],
            keyTips: [
              'اگر پا سنگین بود، دوچرخه سبک انتخاب کن.',
              'شدت متوسط حفظ شود.',
              'هدف ریکاوری فعال و چربی‌سوزی است.',
            ],
            imageAssetPath: 'assets/exercises/bicycle.png',
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-5',
        title: 'Day 4: Upper Body B + Corrective + Abs 3',
        focus: 'بالاتنه B + اصلاحی + شکم جلسه ۳',
        dayNumber: 4,
        cardioMinutes: 25,
        location: WorkoutLocation.gym,
        exercises: [
          Exercise(
            id: 'd5-e0',
            name: 'هوازی سبک + گرم‌کردن کتف',
            type: ExerciseType.cardio,
            targetDurationMinutes: 8,
            notes: 'آماده‌سازی',
            instructionText:
                '۵ تا ۸ دقیقه هوازی سبک انجام بده و کتف و شانه را برای جلسه اصلاحی آماده کن.',
            targetMuscles: ['سیستم قلبی تنفسی'],
            secondaryMuscles: ['شانه', 'پشت بالا'],
            keyTips: [
              'گرم‌کردن این روز سبک بماند.',
              'تمرکز روی آماده‌سازی کتف باشد.',
              'اگر شانه خشک بود چند تکرار face pull سبک انجام بده.',
            ],
            imageAssetPath: 'assets/exercises/elliptical.png',
          ),
          Exercise(
            id: 'd5-e1',
            name: 'Incline Dumbbell Press',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10',
            notes: 'کنترل کامل',
            instructionText:
                'روی نیمکت شیبدار بنشین و دمبل‌ها را با کنترل به بالا پرس کن و آرام پایین بیاور.',
            targetMuscles: ['بالای سینه', 'جلوی سرشانه'],
            secondaryMuscles: ['پشت بازو', 'عضلات مرکزی'],
            keyTips: [
              'آرنج خیلی باز نشود.',
              'دمبل‌ها به هم نکوبند.',
              'فاز منفی آرام باشد.',
            ],
            imageAssetPath: 'assets/exercises/incline_dumbbell_press.png',
          ),
          Exercise(
            id: 'd5-e6',
            name: 'Lat Pulldown دست جمع',
            type: ExerciseType.strength,
            sets: 3,
            reps: '10',
            notes: 'کشش کامل',
            instructionText:
                'میله را با دست جمع بگیر، آن را کنترل‌شده به سمت بالای سینه بکش و آرام بالا برگردان.',
            targetMuscles: ['زیربغل', 'پشت میانی'],
            secondaryMuscles: ['جلو بازو'],
            keyTips: [
              'شانه‌ها را بالا نینداز.',
              'میله را کنترل‌شده پایین بکش.',
              'بدن را زیاد عقب نبر.',
            ],
            imageAssetPath: 'assets/exercises/lat_pulldown.png',
          ),
          Exercise(
            id: 'd5-e2',
            name: 'Cable Row تک‌دست',
            type: ExerciseType.strength,
            sets: 3,
            reps: '12 هر سمت',
            notes: 'تمرکز روی کتف',
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
            instructionText:
                'دمبل‌ها را با آرنج کمی خم تا ارتفاع شانه بالا بیاور و آرام پایین بده.',
            targetMuscles: ['سرشانه میانی'],
            secondaryMuscles: ['پشت شانه', 'کول فوقانی'],
            keyTips: [
              'بدن تاب نخورد.',
              'شانه‌ها بالا نروند.',
              'وزنه سبک اما فرم تمیز باشد.',
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
            instructionText:
                'با تنه ثابت، دست‌ها را به طرفین باز کن تا پشت شانه درگیر شود و سپس آرام برگردان.',
            targetMuscles: ['پشت شانه'],
            secondaryMuscles: ['عضلات بین کتف', 'کول میانی'],
            keyTips: [
              'گردن را سفت نکن.',
              'تاب نده.',
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
            instructionText:
                'دو وزنه را در دو دست بگیر، بدن را صاف نگه دار و مسیر ۳۰ تا ۴۰ متر را با قدم‌های کنترل‌شده طی کن.',
            targetMuscles: ['ساعد', 'کول', 'سرشانه', 'عضلات مرکزی'],
            secondaryMuscles: ['باسن'],
            keyTips: [
              'شکم سفت بماند.',
              'شانه‌ها عقب و پایین باشند.',
              'قدم‌ها کنترل‌شده و یکنواخت باشند.',
            ],
            imageAssetPath: 'assets/exercises/farmer_carry.png',
          ),
          Exercise(
            id: 'd5-e4',
            name: 'Pallof Press',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '12 هر سمت',
            notes: 'ضدچرخش؛ عالی برای میان‌تنه',
            instructionText:
                'کنار کابل بایست، دسته را جلوی سینه بگیر و بدون چرخش تنه دست‌ها را به جلو پرس کن.',
            targetMuscles: ['عضلات مرکزی', 'مورب‌های شکم'],
            secondaryMuscles: ['سرشانه', 'باسن'],
            keyTips: [
              'تنه نچرخد.',
              'شکم سفت بماند.',
              'هر دو سمت با کنترل برابر انجام شود.',
            ],
            imageAssetPath: 'assets/exercises/pallof_press.png',
          ),
          Exercise(
            id: 'd5-e5',
            name: 'Reverse Crunch',
            type: ExerciseType.bodyweight,
            sets: 3,
            reps: '12-15',
            notes: 'آرام و کنترل‌شده',
            instructionText:
                'به پشت بخواب، زانوها خم، لگن را آرام از زمین جدا کن و زانوها را به سمت سینه بیاور.',
            targetMuscles: ['پایین شکم', 'راست شکمی', 'عضلات مرکزی'],
            secondaryMuscles: ['فلکسورهای ران'],
            keyTips: [
              'تاب نخور.',
              'حرکت آرام باشد.',
              'کمر را کنترل کن.',
            ],
            imageAssetPath: 'assets/exercises/reverse_crunch.png',
          ),
          Exercise(
            id: 'd5-e10',
            name: 'هوازی',
            type: ExerciseType.cardio,
            targetDurationMinutes: 25,
            notes: 'شدت متوسط',
            instructionText:
                'در پایان جلسه ۲۰ تا ۲۵ دقیقه هوازی متوسط انجام بده. اگر فقط یک عدد لازم است ۲۵ دقیقه را ثبت کن.',
            targetMuscles: ['سیستم قلبی تنفسی'],
            secondaryMuscles: ['پایین‌تنه'],
            keyTips: [
              'هوازی بعد از وزنه انجام شود.',
              'شدت متوسط باشد.',
              'الپتیکال یا تردمیل شیب ملایم مناسب است.',
            ],
            imageAssetPath: 'assets/exercises/elliptical.png',
          ),
        ],
      ),
      WorkoutDay(
        id: 'day-outdoor',
        title: 'Day 5: Outdoor Walking',
        focus: 'پیاده‌روی سبک',
        dayNumber: 5,
        cardioMinutes: 60,
        location: WorkoutLocation.outdoor,
        exercises: [
          Exercise(
            id: 'outdoor-walk',
            name: 'پیاده‌روی',
            type: ExerciseType.cardio,
            targetDurationMinutes: 60,
            notes: 'چربی‌سوزی و ریکاوری',
            instructionText:
                'با قامت صاف و سرعت قابل‌ادامه راه برو تا بین ۴۵ تا ۶۰ دقیقه فعال بمانی. هدف پیش‌فرض این روز ۶۰ دقیقه است.',
            targetMuscles: ['سیستم قلبی تنفسی'],
            secondaryMuscles: ['چهارسر ران', 'باسن', 'ساق پا'],
            keyTips: [
              'شدت در حد قابل گفت‌وگو باشد.',
              'برای ریکاوری فعال عجله نکن.',
              'در صورت خستگی چند دقیقه آرام‌تر راه برو.',
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
