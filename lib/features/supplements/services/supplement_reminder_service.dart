import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SupplementReminderService {
  SupplementReminderService._();

  static final SupplementReminderService instance = SupplementReminderService._();

  static const int vitaminDBaseId = 5000;
  static const String vitaminDTitle = 'یادآوری ویتامین D';
  static const String vitaminDBody =
      'امروز نوبت مصرف ویتامین D پنجاه‌هزار است.';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initializationSettings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleVitaminDReminders() async {
    try {
      await initialize();
      await cancelVitaminDReminders();

      final firstReminder = _nextSundayAtNoon(DateTime.now());

      for (var index = 0; index < 8; index++) {
        final scheduledDate = firstReminder.add(Duration(days: 7 * index));
        final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

        await _plugin.zonedSchedule(
          vitaminDBaseId + index,
          vitaminDTitle,
          vitaminDBody,
          tzDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'vitamin_d_reminders',
              'Vitamin D Reminders',
              channelDescription: 'Weekly reminders for Vitamin D supplements',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (_) {
      // Keep the local enabled state even if scheduling fails on device.
    }
  }

  Future<void> cancelVitaminDReminders() async {
    try {
      await initialize();
      for (var index = 0; index < 8; index++) {
        await _plugin.cancel(vitaminDBaseId + index);
      }
    } catch (_) {
      // Ignore cancel failures to avoid breaking the toggle flow.
    }
  }

  DateTime _nextSundayAtNoon(DateTime from) {
    final daysUntilSunday = (DateTime.sunday - from.weekday + 7) % 7;
    final candidate = DateTime(
      from.year,
      from.month,
      from.day,
      12,
    ).add(Duration(days: daysUntilSunday));

    if (!candidate.isAfter(from)) {
      return candidate.add(const Duration(days: 7));
    }

    return candidate;
  }
}
