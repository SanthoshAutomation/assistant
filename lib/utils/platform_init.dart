// Conditional export:
// - Mobile: initialises timezone + local notifications
// - Web:    no-op
export 'platform_init_mobile.dart'
    if (dart.library.html) 'platform_init_web.dart';
