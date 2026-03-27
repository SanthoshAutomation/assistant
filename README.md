# My Assistant

A personal Flutter assistant app — **Notes, Todos, and Calendar** — that runs on both **Android** (offline-first, SQLite) and **Web** (direct API, hosted on Hostinger).

## Architecture

| Platform | Storage | 4th Tab |
|----------|---------|----------|
| Android  | Local SQLite (sqflite) | Settings (Push/Pull cloud sync) |
| Web      | Hostinger MySQL via PHP API | Info (API status) |

A single Dart codebase switches implementations at compile time using `kIsWeb` and conditional exports (`if (dart.library.html) ...`).

---

## Prerequisites

- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0 <4.0.0`
- PHP 8.x + MySQL on Hostinger (for web/sync)
- Android Studio or VS Code with Flutter extension

---

## 1. Clone and install dependencies

```bash
git clone https://github.com/SanthoshAutomation/assistant.git
cd assistant
flutter pub get
```

---

## 2. Set up the PHP API (Hostinger)

### 2a. Configure database credentials

Edit `api/config.php` and replace the placeholder values:

```php
define('DB_HOST', 'localhost');          // usually localhost on Hostinger
define('DB_NAME', 'your_database_name');
define('DB_USER', 'your_db_user');
define('DB_PASS', 'your_db_password');
```

Or set them as environment variables on your server.

### 2b. Upload API files

Upload the entire `api/` folder to your Hostinger `public_html/assistant/api/` directory.

### 2c. Create the database tables

Visit `https://yourdomain.com/assistant/api/setup.php` once in your browser.
You should see `{"success":true,"message":"Tables created. DELETE this file now!"}`.  
**Delete `api/setup.php` from the server after running it.**

### 2d. Verify the API

Visit `https://yourdomain.com/assistant/api/index.php` — should return:
```json
{"status":"ok","message":"Assistant API v1.0"}
```

---

## 3. Run on Android

```bash
flutter run
```

Data is stored locally in SQLite — **no internet required** for basic use.

### Cloud sync (optional)

1. Open the app and go to **Settings** (4th tab)
2. Enter your API base URL, e.g. `https://app.sanlabs.in/assistant/api`
3. Tap **Save URL**
4. **Push to Cloud** — backs up all local data to the server
5. **Pull from Cloud (Restore)** — restores data from the server (useful after reinstall or on a new phone)

---

## 4. Build and deploy the Web app

### 4a. Build

```bash
flutter build web --base-href /assistant/
```

### 4b. Upload

Upload the contents of `build/web/` to `public_html/assistant/` on Hostinger.

### 4c. Access

Visit `https://yourdomain.com/assistant/` — the web app reads and writes directly to the PHP API (no local storage on web).

---

## Project structure

```
lib/
  main.dart                          # Entry point — calls initPlatform()
  models/
    note.dart                        # Note model (SQLite + API serialization)
    todo.dart                        # Todo model
    event.dart                       # Event model
  db/
    database_helper.dart             # Conditional export
    database_helper_mobile.dart      # Full sqflite implementation
    database_helper_web.dart         # No-op stub
  services/
    api_service.dart                 # HTTP CRUD for web
    sync_service.dart                # Android push/pull via SharedPreferences URL
    notification_service.dart        # Conditional export
    notification_service_mobile.dart # flutter_local_notifications
    notification_service_web.dart    # No-op stub
  utils/
    platform_init.dart               # Conditional export
    platform_init_mobile.dart        # Timezone + notification init
    platform_init_web.dart           # No-op stub
  providers/
    notes_provider.dart
    todos_provider.dart
    events_provider.dart
  screens/
    home_screen.dart                 # Bottom nav — Info tab on web, Settings on Android
    notes/
    todos/
    calendar/
    settings/                        # Android only
    info/                            # Web only
api/
  config.php                         # DB connection + helper functions
  notes.php                          # GET / POST / DELETE
  todos.php
  events.php
  pull.php                           # Bulk GET for Android restore
  sync.php                           # Bulk POST for Android backup (transactional)
  setup.php                          # One-time table creation (delete after use)
  index.php                          # Router
web/
  index.html                         # Flutter web entry point
  manifest.json                      # PWA manifest
android/                             # Android project (Kotlin DSL Gradle)
```

---

## Key dependencies

| Package | Purpose |
|---------|----------|
| `sqflite` | Local SQLite on Android |
| `flutter_local_notifications` | Scheduled reminders on Android |
| `timezone` + `flutter_timezone` | Timezone-aware notifications |
| `table_calendar` | Calendar UI |
| `http` | HTTP calls to PHP API |
| `shared_preferences` | Persisting the API URL on Android |
| `provider` | State management |
| `uuid` | Generating unique IDs |
| `intl` | Date formatting |

---

## Features

- **Notes** — colour-coded sticky notes with edit support
- **Todos** — pending/done lists, optional due date, friendly notification reminders (Android)
- **Calendar** — month/week view with multi-day event support, event types (appointment, vacation, reminder, other)
- **Settings** (Android) — configure API URL, push to cloud, pull/restore from cloud
- **Info** (Web) — shows API endpoint and app info
