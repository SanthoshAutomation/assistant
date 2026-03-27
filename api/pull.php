<?php
/**
 * Pull endpoint — returns all data so the Flutter app can restore
 * to a new phone or after reinstalling.
 *
 * GET /api/pull.php
 * Response: { notes: [...], todos: [...], events: [...] }
 */
require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Only GET is allowed', 405);
}

$db = getDb();

$notes  = $db->query('SELECT * FROM notes  ORDER BY updated_at DESC')->fetchAll();
$todos  = $db->query('SELECT * FROM todos  ORDER BY created_at DESC')->fetchAll();
$events = $db->query('SELECT * FROM events ORDER BY date ASC')->fetchAll();

jsonResponse([
    'notes'  => $notes,
    'todos'  => $todos,
    'events' => $events,
]);
