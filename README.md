# My Assistant

A personal Flutter assistant app to manage **Notes**, **Todos**, **Reminders**, **Alarms**, and **Calendar** events — with local SQLite storage and optional manual sync to Hostinger MySQL.

## Features

| Feature | Description |
|---|---|
| **Notes** | Color-coded notes, tap to edit |
| **Todos** | Tasks with optional date/time reminders |
| **Reminders** | Friendly, warm motivating notifications |
| **Calendar** | Month view, appointments, vacation date ranges |
| **Cloud Sync** | Manual one-tap sync to Hostinger MySQL via PHP API |
| **Offline First** | Everything stored locally in SQLite |

## Getting Started

### Flutter App

```bash
flutter pub get
flutter run
```

### PHP API (Hostinger)

1. Upload the `api/` folder to your Hostinger public_html or a subdirectory
2. Edit `api/config.php` with your MySQL credentials (or set env vars)
3. Visit `https://yourdomain.com/api/setup.php` **once** to create the tables
4. **Delete `api/setup.php`** after setup
5. In the app, go to **Settings** → enter your API base URL (e.g. `https://yourdomain.com/api`)
6. Tap **Sync Now** whenever you want to back up to the cloud

## PHP API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/sync.php` | Bulk upsert all data |
| GET/POST/DELETE | `/notes.php` | Notes CRUD |
| GET/POST/DELETE | `/todos.php` | Todos CRUD |
| GET/POST/DELETE | `/events.php` | Events CRUD |

## Project Structure

```
lib/
  main.dart             # App entry point
  models/               # Note, Todo, Event data classes
  db/                   # SQLite DatabaseHelper
  providers/            # ChangeNotifier state (Notes, Todos, Events)
  services/             # NotificationService, SyncService
  screens/              # Notes, Todos, Calendar, Settings UI
api/                    # PHP REST API for Hostinger
```

## Reminder Messages (Friendly & Warm)

The app uses rotating friendly messages like:
- *"Hey! Just a gentle nudge — your task is waiting for you 😊"*
- *"You’ve got this! One small step today makes a big difference 💪"*
- *"A friendly reminder that you’re awesome — and so is completing tasks! ✨"*
