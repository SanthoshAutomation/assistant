<?php
require_once __DIR__ . '/config.php';
handleCors();

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    jsonError('Only GET is allowed', 405);
}

$db = getDb();

jsonResponse([
    'notes'  => $db->query('SELECT * FROM notes  ORDER BY updated_at DESC')->fetchAll(),
    'todos'  => $db->query('SELECT * FROM todos  ORDER BY created_at DESC')->fetchAll(),
    'events' => $db->query('SELECT * FROM events ORDER BY date ASC')->fetchAll(),
]);
