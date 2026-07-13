<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
require_once __DIR__ . '/db.php';

$stmt = $pdo->query("SELECT * FROM tb_wishlist_lagu ORDER BY id DESC LIMIT 100");
echo json_encode(['success' => true, 'data' => $stmt->fetchAll()]);
?>
