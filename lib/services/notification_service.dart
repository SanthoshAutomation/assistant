import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Friendly & warm reminder messages
  static const List<String> _todoReminders = [
    'Hey! Just a gentle nudge \u2014 your task is waiting for you \ud83d\ude0a',
    'You\u2019ve got this! One small step today makes a big difference \ud83d\udcaa',
    'A friendly reminder that you\u2019re awesome \u2014 and so is completing tasks! \u2728',
    'Hey there! Your to-do is cheering you on \ud83c\udf89',
    'Just checking in \u2014 your task would love your attention today \ud83d\udc96',
    'Small progress is still progress. You\u2019re doing great! \ud83c\udf1f',
    'Hey! It\u2019s the perfect time to tick something off your list \u2705',
  ];

  static const List<String> _eventReminders = [
    'Don\u2019t forget \u2014 you have something coming up! \ud83d\udcc5',
    'Heads up! Your appointment is approaching \ud83d\ude0a',
    'Just a warm reminder about your upcoming event \u2728',
    'Your calendar is calling! Time to get ready \ud83d\udcc6',
  ];

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Request permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  int _randomId() => Random().nextInt(100000);

  String _randomTodoMessage(String taskTitle) {
    final msg =
        _todoReminders[Random().nextInt(_todoReminders.length)];
    return '$msg\n\u201c$taskTitle\u201d';
  }

  String _randomEventMessage(String eventTitle) {
    final msg =
        _eventReminders[Random().nextInt(_eventReminders.length)];
    return '$msg\n\u201c$eventTitle\u201d';
  }

  Future<int> scheduleTodoReminder({
    required String title,
    required DateTime scheduledAt,
  }) async {
    final id = _randomId();
    await _plugin.zonedSchedule(
      id,
      'Task Reminder \ud83d\udcdd',
      _randomTodoMessage(title),
      tz.TZDateTime.from(scheduledAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Task Reminders',
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
  }

  Future<int> scheduleEventReminder({
    required String title,
    required DateTime scheduledAt,
  }) async {
    final id = _randomId();
    final remindAt = scheduledAt.subtract(const Duration(hours: 1));
    if (remindAt.isBefore(DateTime.now())) return id;

    await _plugin.zonedSchedule(
      id,
      'Upcoming Event \ud83d\udcc5',
      _randomEventMessage(title),
      tz.TZDateTime.from(remindAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel',
          'Event Reminders',
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
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
