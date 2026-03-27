// Web stub — notifications are not supported on web.
// All methods are no-ops so providers can call them unconditionally.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  Future<void> init() async {}
  Future<int?> scheduleTodoReminder(
      {required String title, required DateTime scheduledAt}) async => null;
  Future<int?> scheduleEventReminder(
      {required String title, required DateTime scheduledAt}) async => null;
  Future<void> cancelNotification(int id) async {}
}
