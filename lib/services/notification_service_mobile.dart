import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const List<String> _todoReminders = [
    'Hey! Just a gentle nudge — your task is waiting for you 😊',
    "You've got this! One small step today makes a big difference 💪",
    "A friendly reminder that you're awesome — and so is completing tasks! ✨",
    'Hey there! Your to-do is cheering you on 🎉',
    'Just checking in — your task would love your attention today 💖',
    "Small progress is still progress. You're doing great! 🌟",
    "Hey! It's the perfect time to tick something off your list ✅",
  ];

  static const List<String> _eventReminders = [
    "Don't forget — you have something coming up! 📅",
    'Heads up! Your appointment is approaching 😊',
    'Just a warm reminder about your upcoming event ✨',
    'Your calendar is calling! Time to get ready 📆',
  ];

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  int _randomId() => Random().nextInt(100000);

  String _randomTodoMsg(String title) {
    final msg = _todoReminders[Random().nextInt(_todoReminders.length)];
    return '$msg\n"$title"';
  }

  String _randomEventMsg(String title) {
    final msg = _eventReminders[Random().nextInt(_eventReminders.length)];
    return '$msg\n"$title"';
  }

  Future<int?> scheduleTodoReminder({
    required String title,
    required DateTime scheduledAt,
  }) async {
    final id = _randomId();
    try {
      await _plugin.zonedSchedule(
        id,
        'Task Reminder 📝',
        _randomTodoMsg(title),
        tz.TZDateTime.from(scheduledAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'todo_channel', 'Task Reminders',
            channelDescription: 'Friendly reminders for your tasks',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return id;
    } catch (e) {
      debugPrint('NotificationService: $e');
      return null;
    }
  }

  Future<int?> scheduleEventReminder({
    required String title,
    required DateTime scheduledAt,
  }) async {
    final id = _randomId();
    final remindAt = scheduledAt.subtract(const Duration(hours: 1));
    if (remindAt.isBefore(DateTime.now())) return null;
    try {
      await _plugin.zonedSchedule(
        id,
        'Upcoming Event 📅',
        _randomEventMsg(title),
        tz.TZDateTime.from(remindAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_channel', 'Event Reminders',
            channelDescription: 'Reminders for calendar events',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return id;
    } catch (e) {
      debugPrint('NotificationService: $e');
      return null;
    }
  }

  Future<void> cancelNotification(int id) => _plugin.cancel(id);
}
