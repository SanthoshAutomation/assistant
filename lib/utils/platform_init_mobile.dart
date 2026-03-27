import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../services/notification_service.dart';

Future<void> initPlatform() async {
  tzdata.initializeTimeZones();
  final String localTz = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localTz));
  await NotificationService.instance.init();
}
