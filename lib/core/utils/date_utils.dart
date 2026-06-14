abstract final class AppDateUtils {
  static const List<String> _persianWeekdays = [
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
    'شنبه',
    'یکشنبه',
  ];

  static const List<String> _persianMonths = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static String formattedToday() => formatJalaliFull(DateTime.now());

  static String formatJalaliFull(DateTime date) {
    final jalali = _gregorianToJalali(date);
    final weekday = _persianWeekdays[date.weekday - 1];
    final day = toPersianDigits(jalali.day.toString());
    final month = _persianMonths[jalali.month - 1];
    final year = toPersianDigits(jalali.year.toString());
    return '$weekday $day $month $year';
  }

  static String toPersianDigits(String value) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    var result = value;
    for (var index = 0; index < english.length; index++) {
      result = result.replaceAll(english[index], persian[index]);
    }
    return result;
  }

  static String dateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String();
  }

  static _JalaliDate _gregorianToJalali(DateTime date) {
    const gDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    const jDaysInMonth = [31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29];

    final gy = date.year - 1600;
    final gm = date.month - 1;
    final gd = date.day - 1;

    var gDayNo = 365 * gy +
        ((gy + 3) ~/ 4) -
        ((gy + 99) ~/ 100) +
        ((gy + 399) ~/ 400);

    for (var month = 0; month < gm; month++) {
      gDayNo += gDaysInMonth[month];
    }

    final isLeapGregorian = (date.year % 4 == 0 && date.year % 100 != 0) ||
        (date.year % 400 == 0);
    if (gm > 1 && isLeapGregorian) {
      gDayNo++;
    }

    gDayNo += gd;

    var jDayNo = gDayNo - 79;
    final jNp = jDayNo ~/ 12053;
    jDayNo %= 12053;

    var jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
    jDayNo %= 1461;

    if (jDayNo >= 366) {
      jy += (jDayNo - 1) ~/ 365;
      jDayNo = (jDayNo - 1) % 365;
    }

    var jm = 0;
    while (jm < 11 && jDayNo >= jDaysInMonth[jm]) {
      jDayNo -= jDaysInMonth[jm];
      jm++;
    }

    final jd = jDayNo + 1;
    return _JalaliDate(year: jy, month: jm + 1, day: jd);
  }
}

class _JalaliDate {
  const _JalaliDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;
}
