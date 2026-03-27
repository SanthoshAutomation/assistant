<?php
require_once __DIR__ . '/config.php';
handleCors();

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

switch ($method) {
    case 'GET':
        $stmt = $db->query('SELECT * FROM notes ORDER BY updated_at DESC');
        jsonResponse($stmt->fetchAll());
        break;

    case 'POST':
        $data = getBody();
        if (empty($data['id']) || empty($data['title'])) {
            jsonError('id and title are required');
        }
        $stmt = $db->prepare('
            INSERT INTO notes (id, title, body, color, created_at, updated_at)
            VALUES (:id, :title, :body, :color, :created_at, :updated_at)
            ON DUPLICATE KEY UPDATE
              title      = VALUES(title),
              body       = VALUES(body),
              color      = VALUES(color),
              updated_at = VALUES(updated_at)
        ');
        $stmt->execute([
            ':id'         => $data['id'],
            ':title'      => $data['title'],
            ':body'       => $data['body'] ?? '',
            ':color'      => $data['color'] ?? 0xFFFFF9C4,
            ':created_at' => $data['created_at'] ?? date('c'),
            ':updated_at' => $data['updated_at'] ?? date('c'),
        ]);
        jsonResponse(['success' => true]);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? null;
        if (!$id) jsonError('id is required');
        $db->prepare('DELETE FROM notes WHERE id = ?')->execute([$id]);
        jsonResponse(['success' => true]);
        break;

    default:
        jsonError('Method not allowed', 405);
}
