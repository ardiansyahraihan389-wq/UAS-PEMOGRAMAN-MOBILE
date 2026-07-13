<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
require_once __DIR__ . '/db.php';

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['track_id'], $input['judul_lagu'], $input['nama_artis'])) {
    echo json_encode(['success' => false, 'message' => 'Data tidak lengkap']);
    exit;
}

$stmt = $pdo->prepare("INSERT INTO tb_wishlist_lagu (track_id, judul_lagu, nama_artis, cover_url, preview_url, catatan_pribadi) VALUES (?, ?, ?, ?, ?, ?)");
$stmt->execute([
    $input['track_id'], 
    $input['judul_lagu'], 
    $input['nama_artis'], 
    $input['cover_url'] ?? '', 
    $input['preview_url'] ?? '', 
    $input['catatan_pribadi'] ?? ''
]);

echo json_encode(['success' => true, 'message' => 'Lagu berhasil disimpan']);
?>
