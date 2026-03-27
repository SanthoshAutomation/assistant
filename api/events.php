<?php
require_once __DIR__ . '/config.php';
handleCors();

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

switch ($method) {
    case 'GET':
        $stmt = $db->query('SELECT * FROM events ORDER BY date ASC');
        jsonResponse($stmt->fetchAll());
        break;

    case 'POST':
        $data = getBody();
        if (empty($data['id']) || empty($data['title']) || empty($data['date'])) {
            jsonError('id, title and date are required');
        }
        $stmt = $db->prepare('
            INSERT INTO events (id, title, notes, date, end_date, type)
            VALUES (:id, :title, :notes, :date, :end_date, :type)
            ON DUPLICATE KEY UPDATE
              title    = VALUES(title),
              notes    = VALUES(notes),
              date     = VALUES(date),
              end_date = VALUES(end_date),
              type     = VALUES(type)
        ');
        $stmt->execute([
            ':id'       => $data['id'],
            ':title'    => $data['title'],
            ':notes'    => $data['notes'] ?? null,
            ':date'     => $data['date'],
            ':end_date' => $data['end_date'] ?? null,
            ':type'     => $data['type'] ?? 'other',
        ]);
        jsonResponse(['success' => true]);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? null;
        if (!$id) jsonError('id is required');
        $db->prepare('DELETE FROM events WHERE id = ?')->execute([$id]);
        jsonResponse(['success' => true]);
        break;

    default:
        jsonError('Method not allowed', 405);
}
