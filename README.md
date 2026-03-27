# My Assistant

A personal Flutter assistant app — **Notes**, **Todos**, and **Calendar** — backed by a PHP + MySQL API on Hostinger.

## Two versions in one repo

| | Web App | Android App |
|---|---|---|
| Storage | Hostinger MySQL (API-direct) | Local SQLite (offline-first) |
| Notifications | ✘ | ✓ Push reminders |
| Sync | Always live | Manual Push / Pull in Settings |
| URL | `app.sanlabs.in/assistant` | APK |

---

## Web App — Build & Deploy

### 1. Set up the PHP API on Hostinger

```
Upload the api/ folder to:  public_html/assistant/api/
```

Edit `api/config.php` and fill in your MySQL credentials:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'your_db_name');
define('DB_USER', 'your_db_user');
define('DB_PASS', 'your_db_password');
```

Then visit **once** to create the tables, then **delete the file**:
```
https://app.sanlabs.in/assistant/api/setup.php
```

### 2. Build the Flutter web app

```bash
flutter pub get
flutter build web --release --base-href /assistant/
```

### 3. Upload to Hostinger

```
Upload everything inside build/web/  to:  public_html/assistant/
```

The app will be live at **https://app.sanlabs.in/assistant**

---

## PHP API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/notes.php` | Fetch all notes |
| `POST` | `/notes.php` | Create or update a note |
| `DELETE` | `/notes.php?id=X` | Delete a note |
| `GET` | `/todos.php` | Fetch all todos |
| `POST` | `/todos.php` | Create or update a todo |
| `DELETE` | `/todos.php?id=X` | Delete a todo |
| `GET` | `/events.php` | Fetch all calendar events |
| `POST` | `/events.php` | Create or update an event |
| `DELETE` | `/events.php?id=X` | Delete an event |
| `GET` | `/pull.php` | Bulk fetch all data (Android restore) |
| `POST` | `/sync.php` | Bulk upsert all data (Android backup) |

---

## Project Structure

```
lib/
  main.dart                  # App entry point
  models/                    # Note, Todo, Event
  services/
    api_service.dart         # All HTTP calls — hardcoded to app.sanlabs.in/assistant/api
  providers/                 # ChangeNotifier state management
  screens/
    notes/                   # Color-coded notes grid
    todos/                   # Task list with due dates
    calendar/                # Month view + all-events list
    info/                    # App info & API status
api/                         # PHP REST API for Hostinger
web/                         # Flutter web entry files
```
