<?php
/**
 * Run this ONCE to create the MySQL tables on Hostinger.
 * Visit: https://yourdomain.com/api/setup.php
 * DELETE this file after running.
 */
require_once __DIR__ . '/config.php';

$db = getDb();

$db->exec("CREATE TABLE IF NOT EXISTS notes (
    id VARCHAR(36) PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT,
    color BIGINT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

$db->exec("CREATE TABLE IF NOT EXISTS todos (
    id VARCHAR(36) PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    is_done TINYINT(1) NOT NULL DEFAULT 0,
    due_date DATETIME,
    created_at DATETIME NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

$db->exec("CREATE TABLE IF NOT EXISTS events (
    id VARCHAR(36) PRIMARY KEY,
    title TEXT NOT NULL,
    notes TEXT,
    date DATETIME NOT NULL,
    end_date DATETIME,
    type VARCHAR(20) NOT NULL DEFAULT 'other'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

jsonResponse(['success' => true, 'message' => 'Tables created. DELETE this file now!']);
