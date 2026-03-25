<?php
require_once __DIR__ . '/config.php';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$path = trim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/');
$parts = explode('/', $path);

// Strip leading path segments until we hit a known endpoint
$endpoint = '';
foreach ($parts as $part) {
    if (in_array($part, ['notes', 'todos', 'events', 'sync', 'setup'])) {
        $endpoint = $part;
        break;
    }
}

switch ($endpoint) {
    case 'notes':
        require __DIR__ . '/notes.php';
        break;
    case 'todos':
        require __DIR__ . '/todos.php';
        break;
    case 'events':
        require __DIR__ . '/events.php';
        break;
    case 'sync':
        require __DIR__ . '/sync.php';
        break;
    case 'setup':
        require __DIR__ . '/setup.php';
        break;
    default:
        jsonResponse(['status' => 'ok', 'message' => 'Assistant API v1.0']);
}
