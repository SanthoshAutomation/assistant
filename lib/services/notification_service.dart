// Conditional export:
// - Mobile: full flutter_local_notifications implementation
// - Web:    no-op stub
export 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_web.dart';
