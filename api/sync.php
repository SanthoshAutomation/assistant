<?php
/**
 * Bulk sync endpoint — receives all local data from the Flutter app
 * and upserts everything into MySQL.
 *
 * POST /api/sync.php
 * Body: { notes: [...], todos: [...], events: [...] }
 */
require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonError('Only POST is allowed', 405);
}

$data = getBody();
$db = getDb();
$counts = ['notes' => 0, 'todos' => 0, 'events' => 0];

$db->beginTransaction();
try {
    // Upsert notes
    $noteStmt = $db->prepare('
        INSERT INTO notes (id, title, body, color, created_at, updated_at)
        VALUES (:id, :title, :body, :color, :created_at, :updated_at)
        ON DUPLICATE KEY UPDATE
          title = VALUES(title), body = VALUES(body),
          color = VALUES(color), updated_at = VALUES(updated_at)
    ');
    foreach ($data['notes'] ?? [] as $note) {
        $noteStmt->execute([
            ':id'         => $note['id'],
            ':title'      => $note['title'],
            ':body'       => $note['body'] ?? '',
            ':color'      => $note['color'] ?? 0xFFFFF9C4,
            ':created_at' => $note['created_at'] ?? date('c'),
            ':updated_at' => $note['updated_at'] ?? date('c'),
        ]);
        $counts['notes']++;
    }

    // Upsert todos
    $todoStmt = $db->prepare('
        INSERT INTO todos (id, title, description, is_done, due_date, created_at)
        VALUES (:id, :title, :description, :is_done, :due_date, :created_at)
        ON DUPLICATE KEY UPDATE
          title = VALUES(title), description = VALUES(description),
          is_done = VALUES(is_done), due_date = VALUES(due_date)
    ');
    foreach ($data['todos'] ?? [] as $todo) {
        $todoStmt->execute([
            ':id'          => $todo['id'],
            ':title'       => $todo['title'],
            ':description' => $todo['description'] ?? null,
            ':is_done'     => ($todo['is_done'] ?? 0) ? 1 : 0,
            ':due_date'    => $todo['due_date'] ?? null,
            ':created_at'  => $todo['created_at'] ?? date('c'),
        ]);
        $counts['todos']++;
    }

    // Upsert events
    $eventStmt = $db->prepare('
        INSERT INTO events (id, title, notes, date, end_date, type)
        VALUES (:id, :title, :notes, :date, :end_date, :type)
        ON DUPLICATE KEY UPDATE
          title = VALUES(title), notes = VALUES(notes),
          date = VALUES(date), end_date = VALUES(end_date), type = VALUES(type)
    ');
    foreach ($data['events'] ?? [] as $event) {
        $eventStmt->execute([
            ':id'       => $event['id'],
            ':title'    => $event['title'],
            ':notes'    => $event['notes'] ?? null,
            ':date'     => $event['date'],
            ':end_date' => $event['end_date'] ?? null,
            ':type'     => $event['type'] ?? 'other',
        ]);
        $counts['events']++;
    }

    $db->commit();
    jsonResponse([
        'success' => true,
        'synced'  => $counts,
        'message' => 'Sync complete',
    ]);
} catch (Exception $e) {
    $db->rollBack();
    jsonError('Sync failed: ' . $e->getMessage(), 500);
}
