// Conditional export:
// - Mobile: full SQLite implementation
// - Web:    no-op stub (providers use ApiService instead)
export 'database_helper_mobile.dart'
    if (dart.library.html) 'database_helper_web.dart';
