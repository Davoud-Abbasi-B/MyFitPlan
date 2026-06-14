# سند نیازمندی و راهنمای پیاده‌سازی اپلیکیشن Flutter
# اپلیکیشن شخصی سلامت، تمرین، تغذیه و مکمل

## 1. معرفی پروژه

این پروژه یک اپلیکیشن اندروید شخصی با Flutter است که برای مدیریت برنامه تمرینی، تغذیه، مکمل‌ها، ریزه‌خواری عصر، ثبت وزن/دور شکم و گزارش‌گیری هفتگی طراحی می‌شود.

اپلیکیشن برای استفاده شخصی ساخته می‌شود و در نسخه اول نیاز به بک‌اند، لاگین، سرور یا اتصال آنلاین ندارد. تمام داده‌ها باید به‌صورت local روی موبایل ذخیره شوند.

هدف اصلی اپلیکیشن این است که کاربر بتواند برنامه روزانه سلامت خود را ساده، سریع و منظم پیگیری کند.

---

## 2. مشخصات کاربر هدف

کاربر اصلی اپلیکیشن:

| فیلد | مقدار |
|---|---|
| سن | 34 |
| جنسیت | مرد |
| قد | 185 سانتی‌متر |
| وزن فعلی | 87 کیلوگرم |
| وزن هدف | 84 کیلوگرم |
| دور شکم فعلی | 100 سانتی‌متر |
| سطح تمرین | متوسط |
| تعداد روز تمرین | 4 روز در هفته |
| سبک تمرین | بدنسازی + هوازی |
| هدف اصلی | کاهش چربی شکم، عضله‌سازی پایین‌تنه، سلامت عمومی |
| محدودیت مهم | سابقه کبد چرب، توجه به زانو |
| چالش رفتاری | استرس و ریزه‌خواری عصرها |

---

## 3. هدف نسخه MVP

نسخه اول باید ساده، کاربردی و بدون پیچیدگی باشد.

### فیچرهای ضروری MVP

1. داشبورد امروز
2. چک‌لیست روزانه
3. برنامه تمرین 4 روزه
4. صفحه جزئیات هر جلسه تمرین
5. ثبت انجام حرکات، ست، تکرار و وزنه
6. برنامه غذایی روزانه
7. کنترل ریزه‌خواری عصر
8. یادآور و ثبت مصرف مکمل‌ها
9. ثبت وزن و دور شکم
10. گزارش هفتگی ساده
11. ذخیره‌سازی local

---

## 4. پلتفرم و تکنولوژی پیشنهادی

### Stack

| بخش | تکنولوژی |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Target | Android |
| State Management | Riverpod یا Provider |
| Local Database | Hive یا Isar |
| Notifications | flutter_local_notifications |
| Charts | fl_chart |
| Date/Time | intl |
| Architecture | Feature-based clean structure |

### پیشنهاد فنی

برای نسخه MVP بهتر است از Hive استفاده شود چون ساده، سریع و مناسب ذخیره‌سازی local است.

اگر پروژه بزرگ‌تر شد، بعداً می‌توان به Isar یا Drift مهاجرت کرد.

---

## 5. ساختار پیشنهادی پروژه

```text
lib/
  main.dart
  app.dart

  core/
    constants/
      app_constants.dart
      app_colors.dart
      app_text_styles.dart
    utils/
      date_utils.dart
      score_calculator.dart
    widgets/
      app_card.dart
      checklist_tile.dart
      progress_card.dart
      primary_button.dart

  features/
    dashboard/
      screens/
        dashboard_screen.dart
      widgets/
        today_summary_card.dart
        daily_score_card.dart

    checklist/
      models/
        daily_checklist_model.dart
      screens/
        daily_checklist_screen.dart
      providers/
        checklist_provider.dart

    workout/
      models/
        workout_day_model.dart
        exercise_model.dart
        workout_log_model.dart
      screens/
        workout_plan_screen.dart
        workout_detail_screen.dart
        workout_history_screen.dart
      providers/
        workout_provider.dart
      data/
        default_workout_data.dart

    nutrition/
      models/
        meal_model.dart
        meal_plan_model.dart
      screens/
        nutrition_screen.dart
        meal_detail_screen.dart
      providers/
        nutrition_provider.dart
      data/
        default_meal_data.dart

    craving/
      models/
        craving_log_model.dart
      screens/
        craving_helper_screen.dart
        craving_history_screen.dart
      providers/
        craving_provider.dart

    supplements/
      models/
        supplement_model.dart
        supplement_log_model.dart
      screens/
        supplements_screen.dart
      providers/
        supplement_provider.dart
      data/
        default_supplement_data.dart

    progress/
      models/
        body_progress_model.dart
      screens/
        progress_screen.dart
        add_progress_screen.dart
      providers/
        progress_provider.dart

    reports/
      screens/
        weekly_report_screen.dart
      providers/
        report_provider.dart

    settings/
      screens/
        settings_screen.dart
      models/
        user_profile_model.dart

  data/
    local/
      hive_boxes.dart
      local_storage_service.dart
```

---

## 6. مسیرهای اصلی اپلیکیشن

اپلیکیشن باید Bottom Navigation داشته باشد.

### Bottom Navigation

| Tab | عنوان فارسی | صفحه |
|---|---|---|
| 1 | امروز | DashboardScreen |
| 2 | تمرین | WorkoutPlanScreen |
| 3 | تغذیه | NutritionScreen |
| 4 | پیشرفت | ProgressScreen |
| 5 | بیشتر | Settings / Reports / Supplements |

---

## 7. طراحی کلی UI

### سبک طراحی

- زبان اپلیکیشن: فارسی
- جهت نمایش: RTL
- تم: ساده، تمیز، مدرن
- رنگ اصلی پیشنهادی: آبی یا سبز سلامت
- فونت پیشنهادی: Vazirmatn یا فونت پیش‌فرض سیستم اگر فونت اضافه نشد
- کارت‌های ساده با گوشه گرد
- دکمه‌های بزرگ و واضح
- استفاده زیاد از checkbox و progress indicator

### صفحات باید ساده باشند

هر صفحه باید تمرکز مشخص داشته باشد و کاربر در کمتر از چند ثانیه بتواند وضعیت خود را ثبت کند.

---

## 8. داشبورد امروز

### هدف صفحه

نمایش خلاصه وضعیت امروز و دسترسی سریع به کارهای روزانه.

### اجزای صفحه

1. پیام خوش‌آمدگویی
2. امتیاز امروز از 100
3. تمرین امروز
4. چک‌لیست امروز
5. مکمل‌های امروز
6. وعده بعدی
7. وضعیت قدم روزانه
8. دکمه سریع «الان هوس کردم»
9. خلاصه وزن و دور شکم

### نمونه آیتم‌ها

```text
امروز چه کارهایی داری؟

- تمرین: پایین‌تنه A
- هوازی: 20 تا 25 دقیقه
- عصرانه سالم: ساعت 16:30
- مکمل‌ها: Neuro B-Vit، Sideral Forte
- هدف قدم: 8000 قدم
```

---

## 9. چک‌لیست روزانه

### آیتم‌های ثابت چک‌لیست

| آیتم | امتیاز |
|---|---:|
| تمرین امروز یا پیاده‌روی انجام شد | 20 |
| پروتئین کافی مصرف شد | 15 |
| عصرانه کنترل‌شده خورده شد | 15 |
| نوشیدنی قندی مصرف نشد | 10 |
| مکمل‌های امروز مصرف شد | 10 |
| قدم روزانه کامل شد | 10 |
| آب کافی خورده شد | 10 |
| ریزه‌خواری کنترل شد | 10 |

### مدل داده پیشنهادی

```dart
class DailyChecklist {
  final String id;
  final DateTime date;
  final bool workoutDone;
  final bool enoughProtein;
  final bool healthySnack;
  final bool noSugaryDrink;
  final bool supplementsDone;
  final bool stepsDone;
  final bool enoughWater;
  final bool cravingControlled;

  DailyChecklist({
    required this.id,
    required this.date,
    required this.workoutDone,
    required this.enoughProtein,
    required this.healthySnack,
    required this.noSugaryDrink,
    required this.supplementsDone,
    required this.stepsDone,
    required this.enoughWater,
    required this.cravingControlled,
  });
}
```

### محاسبه امتیاز روزانه

```text
Daily Score = sum(points of completed checklist items)
Maximum Score = 100
```

---

## 10. برنامه تمرینی

### برنامه هفتگی ثابت

| روز | نوع تمرین |
|---|---|
| روز 1 | پایین‌تنه A؛ چهارسر و زانو |
| روز 2 | بالاتنه A |
| روز 3 | استراحت یا پیاده‌روی |
| روز 4 | پایین‌تنه B؛ باسن و پشت پا |
| روز 5 | بالاتنه B + اصلاحی |
| روز 6 | پیاده‌روی سبک |
| روز 7 | استراحت |

### Workout Day Model

```dart
class WorkoutDay {
  final String id;
  final String title;
  final String focus;
  final int dayNumber;
  final List<Exercise> exercises;
  final int cardioMinutes;

  WorkoutDay({
    required this.id,
    required this.title,
    required this.focus,
    required this.dayNumber,
    required this.exercises,
    required this.cardioMinutes,
  });
}
```

### Exercise Model

```dart
class Exercise {
  final String id;
  final String name;
  final int sets;
  final String reps;
  final String notes;
  final bool isCompleted;
  final double? weight;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.notes,
    this.isCompleted = false,
    this.weight,
  });
}
```

---

## 11. دیتای اولیه برنامه تمرین

### روز 1: پایین‌تنه A

| حرکت | ست | تکرار | توضیح |
|---|---:|---|---|
| گرم‌کردن با دوچرخه یا الپتیکال | 1 | 8 دقیقه | شدت سبک تا متوسط |
| Leg Press | 4 | 10-12 | زانو داخل نرود |
| Goblet Squat یا Smith Squat | 3 | 10 | دامنه بدون درد |
| Bulgarian Split Squat سبک | 3 | 8 هر پا | اگر زانو اذیت شد Step-up جایگزین شود |
| Leg Extension | 3 | 12-15 | مکث کوتاه بالا |
| Seated Calf Raise | 4 | 12-15 | کنترل کامل |
| Plank | 3 | 40-60 ثانیه | بدن صاف |
| هوازی | 1 | 20-25 دقیقه | شدت متوسط |

### روز 2: بالاتنه A

| حرکت | ست | تکرار | توضیح |
|---|---:|---|---|
| گرم‌کردن هوازی سبک | 1 | 5-8 دقیقه | آماده‌سازی شانه |
| Bench Press یا Chest Press | 4 | 8-10 | کنترل مسیر حرکت |
| Lat Pulldown | 4 | 10-12 | کشش کامل |
| Seated Row | 3 | 10-12 | کتف‌ها عقب |
| Dumbbell Shoulder Press | 3 | 8-10 | بدون درد گردن |
| Face Pull | 3 | 15 | برای شانه و گردن |
| Cable Triceps Pushdown | 3 | 12 | آرنج ثابت |
| Dumbbell Curl | 3 | 12 | کنترل کامل |
| هوازی | 1 | 20 دقیقه | شدت متوسط |

### روز 4: پایین‌تنه B

| حرکت | ست | تکرار | توضیح |
|---|---:|---|---|
| دوچرخه ثابت | 1 | 8 دقیقه | مناسب زانو |
| Romanian Deadlift | 4 | 8-10 | کمر صاف |
| Hip Thrust | 4 | 10-12 | مکث بالا |
| Lying/Seated Leg Curl | 4 | 10-12 | کنترل کامل |
| Reverse Lunge | 3 | 10 هر پا | زانو‌دوست‌تر |
| Hip Abduction Machine | 3 | 15 | ثبات زانو |
| Standing Calf Raise | 4 | 12-15 | مکث بالا |
| Dead Bug | 3 | 10 هر سمت | کنترل کمر |
| هوازی | 1 | 20-25 دقیقه | شدت متوسط |

### روز 5: بالاتنه B + اصلاحی

| حرکت | ست | تکرار | توضیح |
|---|---:|---|---|
| گرم‌کردن هوازی سبک | 1 | 5-8 دقیقه | آماده‌سازی |
| Incline Dumbbell Press | 3 | 10 | کنترل کامل |
| Assisted Pull-up یا Lat Pulldown دست جمع | 3 | 10 | کشش کامل |
| Cable Row تک‌دست | 3 | 12 هر سمت | تمرکز روی کتف |
| Lateral Raise | 4 | 12-15 | وزنه سبک |
| Rear Delt Fly | 3 | 15 | کنترل‌شده |
| Farmer Carry | 3 | 30-40 متر | شکم سفت |
| Pallof Press | 3 | 12 هر سمت | ضدچرخش |
| هوازی | 1 | 25 دقیقه | شدت متوسط |

---

## 12. ثبت تمرین

در صفحه جزئیات تمرین، کاربر باید بتواند برای هر حرکت این موارد را ثبت کند:

| فیلد | نوع |
|---|---|
| انجام شد / نشد | Checkbox |
| وزنه استفاده‌شده | Number input |
| تکرار واقعی | Text/Number input |
| یادداشت | Text field |
| درد زانو یا درد مفصلی | Dropdown یا Switch |
| شدت تمرین | سبک / متوسط / سنگین |

### Workout Log Model

```dart
class WorkoutLog {
  final String id;
  final DateTime date;
  final String workoutDayId;
  final List<ExerciseLog> exerciseLogs;
  final int cardioMinutes;
  final String feeling;
  final bool kneePain;
  final String? notes;

  WorkoutLog({
    required this.id,
    required this.date,
    required this.workoutDayId,
    required this.exerciseLogs,
    required this.cardioMinutes,
    required this.feeling,
    required this.kneePain,
    this.notes,
  });
}

class ExerciseLog {
  final String exerciseId;
  final bool completed;
  final double? weight;
  final String? actualReps;
  final String? notes;

  ExerciseLog({
    required this.exerciseId,
    required this.completed,
    this.weight,
    this.actualReps,
    this.notes,
  });
}
```

---

## 13. بخش تغذیه

### وعده‌های روز تمرین

| زمان | وعده | پیشنهاد |
|---|---|---|
| قبل تمرین | میان‌وعده سبک | موز یا خرما + قهوه تلخ |
| بعد تمرین | پروتئین | 1 پیمانه وی با آب |
| صبحانه | وعده اصلی | تخم‌مرغ + نان سبوس‌دار + سبزیجات |
| ناهار | وعده اصلی | پروتئین + برنج کنترل‌شده + سالاد |
| عصرانه | وعده مهم | ماست چکیده، سیب و بادام، وی یا تخم‌مرغ |
| شام | سبک | پروتئین + سبزیجات |

### Meal Model

```dart
class Meal {
  final String id;
  final String title;
  final String timeLabel;
  final List<String> options;
  final bool isCompleted;

  Meal({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.options,
    this.isCompleted = false,
  });
}
```

### گزینه‌های عصرانه

| گزینه | مقدار |
|---|---|
| ماست یونانی یا چکیده کم‌چرب | 200 تا 250 گرم |
| سیب + بادام | 1 عدد سیب + 15 عدد بادام |
| تخم‌مرغ آب‌پز | 2 عدد + خیار |
| وی پروتئین | نصف تا 1 پیمانه |
| تن ماهی آبکش‌شده | نصف تا 1 قوطی |
| شیر کم‌چرب | 1 لیوان |
| هویج و خیار + ماست | یک کاسه متوسط |

---

## 14. کنترل ریزه‌خواری عصر

### هدف

کمک به کاربر در لحظه‌ای که دچار هوس شیرینی، تنقلات یا ریزه‌خواری می‌شود.

### دکمه اصلی

در داشبورد یک دکمه با عنوان زیر وجود داشته باشد:

```text
الان هوس کردم
```

### جریان صفحه

وقتی کاربر وارد صفحه شد:

1. سوال: الان واقعاً گرسنه‌ای یا فقط هوس/استرس است؟
2. گزینه‌ها:
   - گرسنگی واقعی
   - استرس
   - خستگی
   - بی‌حوصلگی
   - هوس شیرینی
3. پیشنهاد مرحله‌ای:
   - یک لیوان آب بخور
   - 10 دقیقه صبر کن
   - 5 نفس عمیق بکش
   - اگر هنوز گرسنه‌ای، یک میان‌وعده سالم انتخاب کن
4. دکمه ثبت نتیجه:
   - کنترل شد
   - کنترل نشد
   - میان‌وعده سالم خوردم

### Craving Log Model

```dart
class CravingLog {
  final String id;
  final DateTime dateTime;
  final String trigger;
  final bool controlled;
  final String? selectedAlternative;
  final String? note;

  CravingLog({
    required this.id,
    required this.dateTime,
    required this.trigger,
    required this.controlled,
    this.selectedAlternative,
    this.note,
  });
}
```

---

## 15. مکمل‌ها

### مکمل‌های پیش‌فرض

| مکمل | زمان مصرف | نوع تکرار |
|---|---|---|
| Neuro B-Vit | صبح بعد صبحانه | روزانه |
| Sideral Forte | ظهر یا عصر | روزانه |
| Vitamin D 50000 | همراه ناهار یا شام | هفتگی |
| Whey Protein | بعد تمرین | فقط روز تمرین |
| Creatine | همراه صبحانه یا بعد تمرین | روزانه، اختیاری |
| Omega-3 | همراه غذا | روزانه، اختیاری |

### Supplement Model

```dart
class Supplement {
  final String id;
  final String name;
  final String dosage;
  final String timing;
  final String frequency;
  final bool isOptional;
  final bool reminderEnabled;

  Supplement({
    required this.id,
    required this.name,
    required this.dosage,
    required this.timing,
    required this.frequency,
    required this.isOptional,
    required this.reminderEnabled,
  });
}
```

### Supplement Log Model

```dart
class SupplementLog {
  final String id;
  final String supplementId;
  final DateTime date;
  final bool taken;

  SupplementLog({
    required this.id,
    required this.supplementId,
    required this.date,
    required this.taken,
  });
}
```

---

## 16. پیشرفت بدنی

### داده‌هایی که باید ثبت شوند

| فیلد | تناوب |
|---|---|
| وزن | هفته‌ای 3 بار |
| دور شکم | هفته‌ای 1 بار |
| قدم روزانه | روزانه |
| عکس پیشرفت | نسخه بعدی |
| یادداشت | اختیاری |

### Body Progress Model

```dart
class BodyProgress {
  final String id;
  final DateTime date;
  final double weightKg;
  final double waistCm;
  final int? steps;
  final String? note;

  BodyProgress({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.waistCm,
    this.steps,
    this.note,
  });
}
```

### نمودارها

با fl_chart این نمودارها ساخته شود:

1. روند وزن
2. روند دور شکم
3. میانگین قدم روزانه
4. تعداد تمرین‌های انجام‌شده در هفته
5. تعداد روزهای کنترل ریزه‌خواری

---

## 17. گزارش هفتگی

### اطلاعات گزارش

| شاخص | محاسبه |
|---|---|
| تعداد جلسات تمرین | تعداد WorkoutLog در هفته |
| جلسات پایین‌تنه | تعداد workout با نوع پایین‌تنه |
| میانگین قدم | average steps |
| تغییر وزن | آخرین وزن هفته - اولین وزن هفته |
| تغییر دور شکم | آخرین دور شکم - اولین دور شکم |
| روزهای کنترل ریزه‌خواری | تعداد CravingLog کنترل‌شده |
| درصد مصرف مکمل | taken / total |
| میانگین امتیاز روزانه | average daily score |

### خروجی متنی نمونه

```text
گزارش این هفته

- تمرین: 4 از 4 جلسه
- پایین‌تنه: 2 از 2 جلسه
- میانگین قدم: 8200
- تغییر وزن: -300 گرم
- تغییر دور شکم: -0.5 سانتی‌متر
- کنترل ریزه‌خواری: 5 روز از 7 روز
- مصرف مکمل‌ها: 90 درصد
- جمع‌بندی: هفته خوبی داشتی. تمرکز هفته بعد روی کنترل عصرانه باشد.
```

---

## 18. یادآورها و نوتیفیکیشن‌ها

### نوتیفیکیشن‌های ضروری

| زمان | پیام |
|---|---|
| صبح | مکمل صبح را فراموش نکن |
| بعد تمرین | وی پروتئین و ثبت تمرین |
| 16:30 | عصرانه سالمت را بخور تا ریزه‌خواری کنترل شود |
| عصر | سیدرال فورت را با فاصله از چای/قهوه/لبنیات مصرف کن |
| روز مشخص هفته | ویتامین D هفتگی |
| شب | چک‌لیست امروز را کامل کن |
| آخر هفته | وزن، دور شکم و گزارش هفتگی را ثبت کن |

### نکته پیاده‌سازی

در MVP فقط نوتیفیکیشن‌های local لازم است و نیازی به Firebase Cloud Messaging نیست.

---

## 19. تنظیمات

### موارد تنظیمات

| تنظیم | توضیح |
|---|---|
| ویرایش پروفایل | قد، وزن هدف، دور شکم هدف |
| تنظیم روزهای تمرین | انتخاب روزهای هفته |
| روشن/خاموش کردن یادآورها | مکمل، عصرانه، تمرین |
| تغییر ساعت یادآورها | قابل تنظیم |
| خروجی گرفتن از داده‌ها | نسخه بعدی |
| پاک کردن داده‌ها | با تایید کاربر |

---

## 20. دیتای اولیه برای شروع اپ

در اولین اجرای اپ، داده‌های پیش‌فرض باید ساخته شوند:

1. پروفایل کاربر
2. برنامه تمرین 4 روزه
3. چک‌لیست روزانه
4. برنامه غذایی روز تمرین و غیرتمرین
5. مکمل‌های اصلی
6. اهداف:
   - وزن هدف: 84
   - قدم روزانه: 8000
   - پروتئین روزانه: 135 تا 150 گرم
   - تمرین هفتگی: 4 جلسه

---

## 21. قوانین مهم کسب‌وکار

### قوانین تغذیه

1. حذف کامل برنج و نان لازم نیست؛ مقدار باید کنترل شود.
2. عصرانه پروتئینی برای کنترل ریزه‌خواری ضروری است.
3. نوشیدنی قندی باید محدود شود.
4. مصرف پروتئین باید در وعده‌های اصلی پخش شود.

### قوانین تمرین

1. درد مفصلی هشدار است و باید ثبت شود.
2. افزایش وزنه باید تدریجی باشد.
3. تمرین پایین‌تنه دو بار در هفته اولویت دارد.
4. هوازی بعد تمرین 20 تا 25 دقیقه کافی است.
5. برای زانو، دوچرخه و الپتیکال ترجیح دارند.

### قوانین مکمل

1. مکمل‌ها فقط برای یادآوری و ثبت مصرف هستند.
2. اپ نباید پیشنهاد پزشکی قطعی بدهد.
3. در متن‌های اپ تاکید شود که مصرف مکمل‌ها طبق نظر پزشک است.
4. سیدرال فورت باید با چای، قهوه، لبنیات، کلسیم و منیزیم فاصله داشته باشد.
5. ویتامین D هفتگی باید یادآور مستقل داشته باشد.

---

## 22. Acceptance Criteria

### داشبورد

- کاربر باید بتواند وضعیت امروز را در یک نگاه ببیند.
- امتیاز روزانه باید بر اساس چک‌لیست محاسبه شود.
- دکمه «الان هوس کردم» باید از داشبورد قابل دسترسی باشد.

### تمرین

- کاربر باید لیست روزهای تمرینی را ببیند.
- کاربر باید جزئیات هر تمرین را باز کند.
- کاربر باید بتواند حرکت را done کند.
- کاربر باید بتواند وزنه و یادداشت ثبت کند.
- تاریخچه تمرین باید ذخیره شود.

### تغذیه

- کاربر باید وعده‌های روزانه را ببیند.
- کاربر باید بتواند وعده‌ها را completed کند.
- عصرانه باید به‌عنوان وعده مهم مشخص باشد.

### مکمل‌ها

- کاربر باید مکمل‌های امروز را ببیند.
- کاربر باید مصرف هر مکمل را ثبت کند.
- ویتامین D باید قابلیت یادآور هفتگی داشته باشد.

### پیشرفت

- کاربر باید وزن و دور شکم ثبت کند.
- نمودار وزن و دور شکم باید نمایش داده شود.
- آخرین مقدار وزن و دور شکم باید در داشبورد نمایش داده شود.

### ریزه‌خواری

- کاربر باید بتواند trigger هوس را ثبت کند.
- کاربر باید بتواند نتیجه را ثبت کند: کنترل شد / کنترل نشد.
- تعداد دفعات کنترل موفق در گزارش هفتگی بیاید.

---

## 23. پرامپت پیشنهادی برای Codex در VS Code

از متن زیر می‌توان مستقیم در Codex استفاده کرد:

```text
You are a senior Flutter developer.

Build a Persian RTL Android Flutter app for a personal health, workout, nutrition, supplement, craving-control, and progress tracking system.

Use Flutter and Dart. The app should be offline-first and store all data locally. Use Hive for local storage, Riverpod or Provider for state management, flutter_local_notifications for reminders, and fl_chart for progress charts.

The app language is Persian and all screens must be RTL.

Implement the MVP with these main tabs:
1. امروز / Dashboard
2. تمرین / Workout
3. تغذیه / Nutrition
4. پیشرفت / Progress
5. بیشتر / More

Required features:
- Daily dashboard with today's score, workout, checklist, supplements, next meal, progress summary
- Daily checklist with weighted score out of 100
- 4-day weekly workout plan
- Workout detail screen with exercises, sets, reps, weight input, completion checkbox, notes, cardio minutes, knee pain flag
- Nutrition screen with daily meals and healthy snack options
- Craving helper screen with button "الان هوس کردم", trigger selection, 10-minute wait guidance, healthy alternatives, and result logging
- Supplements screen with default supplements and taken/not taken tracking
- Weekly vitamin D reminder support
- Body progress screen for weight, waist, and steps
- Charts for weight and waist trends
- Weekly report screen summarizing workouts, lower-body sessions, average steps, weight change, waist change, craving control, supplement adherence, and average daily score
- Settings screen for profile and reminder settings

Default user profile:
age: 34
gender: male
height: 185 cm
current weight: 87 kg
target weight: 84 kg
current waist: 100 cm
fitness level: intermediate
weekly workouts: 4
goals: reduce belly fat, improve general health, build lower-body muscle, support fatty liver improvement, protect knees

Default checklist items with score:
- Workout or walking done: 20
- Enough protein: 15
- Healthy afternoon snack: 15
- No sugary drink: 10
- Supplements taken: 10
- Steps goal completed: 10
- Enough water: 10
- Craving controlled: 10

Default workout plan:
Day 1: Lower Body A - quads and knees
Day 2: Upper Body A
Day 3: Rest or walking
Day 4: Lower Body B - glutes and hamstrings
Day 5: Upper Body B + corrective
Day 6: Light walking
Day 7: Rest

Use clean code and feature-based folder structure.
Create models, providers, screens, and reusable widgets.
Seed the default workout, meals, supplements, and profile on first app launch.
Do not implement authentication or backend.
Keep UI simple, modern, card-based, and mobile-friendly.
```

---

## 24. ترتیب پیشنهادی توسعه

### فاز 1

1. ساخت پروژه Flutter
2. تنظیم RTL و تم فارسی
3. ساخت Bottom Navigation
4. ساخت داشبورد خام
5. ساخت مدل‌ها و local storage

### فاز 2

1. پیاده‌سازی چک‌لیست روزانه
2. محاسبه امتیاز روزانه
3. ذخیره‌سازی وضعیت هر روز

### فاز 3

1. پیاده‌سازی برنامه تمرینی
2. صفحه جزئیات تمرین
3. ثبت تمرین و تاریخچه

### فاز 4

1. پیاده‌سازی تغذیه
2. صفحه کنترل ریزه‌خواری
3. ثبت craving log

### فاز 5

1. مکمل‌ها
2. نوتیفیکیشن local
3. یادآور ویتامین D هفتگی

### فاز 6

1. ثبت وزن، دور شکم و قدم
2. نمودارها
3. گزارش هفتگی

---

## 25. نکات مهم برای جلوگیری از پیچیدگی

در نسخه اول این موارد را پیاده‌سازی نکن:

- لاگین
- بک‌اند
- اتصال به سرور
- هوش مصنوعی
- کالری‌شمار کامل
- اسکن غذا
- اتصال به ساعت هوشمند
- خروجی PDF
- برنامه چندکاربره

این‌ها برای نسخه‌های بعدی هستند.

---

## 26. فیچرهای نسخه بعدی

| فیچر | توضیح |
|---|---|
| اتصال به Google Fit | دریافت قدم خودکار |
| عکس پیشرفت | ذخیره عکس‌های ماهانه |
| Export گرفتن | خروجی CSV یا PDF |
| تحلیل آزمایش‌ها | ثبت و نمودار Vitamin D, Ferritin, B12 |
| پیشنهاد هوشمند وعده | بر اساس ریزه‌خواری و تمرین |
| تغییر برنامه تمرین | ساخت برنامه جدید بعد از چند هفته |
| حالت تاریک | Dark Mode |
| پین‌کد یا قفل اپ | برای حریم خصوصی |

---

## 27. جمع‌بندی

این اپلیکیشن باید یک ابزار شخصی، ساده و سریع برای پیگیری سبک زندگی باشد.

مهم‌ترین ارزش اپلیکیشن:

1. نظم دادن به تمرین 4 روزه
2. کنترل ریزه‌خواری عصر
3. ثبت مصرف مکمل‌ها
4. پیگیری وزن و دور شکم
5. ایجاد گزارش هفتگی انگیزشی

در نسخه MVP تمرکز روی سادگی، سرعت ثبت اطلاعات و کاربرد روزانه است.
