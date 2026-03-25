<?php
require_once __DIR__ . '/config.php';

$method = $_SERVER['REQUEST_METHOD'];
$db = getDb();

switch ($method) {
    case 'GET':
        $stmt = $db->query('SELECT * FROM todos ORDER BY created_at DESC');
        jsonResponse($stmt->fetchAll());
        break;

    case 'POST':
        $data = getBody();
        if (empty($data['id']) || empty($data['title'])) {
            jsonError('id and title are required');
        }
        $stmt = $db->prepare('
            INSERT INTO todos (id, title, description, is_done, due_date, created_at)
            VALUES (:id, :title, :description, :is_done, :due_date, :created_at)
            ON DUPLICATE KEY UPDATE
              title = VALUES(title),
              description = VALUES(description),
              is_done = VALUES(is_done),
              due_date = VALUES(due_date)
        ');
        $stmt->execute([
            ':id'          => $data['id'],
            ':title'       => $data['title'],
            ':description' => $data['description'] ?? null,
            ':is_done'     => $data['is_done'] ? 1 : 0,
            ':due_date'    => $data['due_date'] ?? null,
            ':created_at'  => $data['created_at'] ?? date('c'),
        ]);
        jsonResponse(['success' => true]);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? null;
        if (!$id) jsonError('id is required');
        $db->prepare('DELETE FROM todos WHERE id = ?')->execute([$id]);
        jsonResponse(['success' => true]);
        break;

    default:
        jsonError('Method not allowed', 405);
}
