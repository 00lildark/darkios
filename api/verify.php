<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$dataFile = __DIR__ . '/../data/store.json';
if (!file_exists($dataFile)) {
    $dataFile = __DIR__ . '/keys.json';
}

$store = [
    'records' => [],
    'banned' => [],
    'devices' => [],
    'updateModeOn' => false
];

if (file_exists($dataFile)) {
    $raw = file_get_contents($dataFile);
    $decoded = json_decode($raw, true);
    if (is_array($decoded)) {
        $store = array_merge($store, $decoded);
    }
}

$inputKey = isset($_POST['key']) ? trim((string)$_POST['key']) : (isset($_GET['key']) ? trim((string)$_GET['key']) : '');
$hwid = isset($_POST['hwid']) ? trim((string)$_POST['hwid']) : (isset($_GET['hwid']) ? trim((string)$_GET['hwid']) : '');

if ($inputKey === '') {
    echo json_encode([
        'status' => 'error',
        'message' => 'Key boş ola bilməz.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!empty($store['updateModeOn'])) {
    echo json_encode([
        'status' => 'updating',
        'updating' => true,
        'message' => 'Hilə hazırda yenilənir. Yeni versiya hazır olanda daxil olun.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

foreach (($store['banned'] ?? []) as $b) {
    if (isset($b['key']) && strcasecmp((string)$b['key'], $inputKey) === 0) {
        echo json_encode([
            'status' => 'banned',
            'banned' => true,
            'message' => !empty($b['reason']) ? (string)$b['reason'] : 'Bu key banlanıb və istifadəsi bloklanıb.'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

$foundIdx = null;
foreach (($store['records'] ?? []) as $idx => $r) {
    if (isset($r['key']) && strcasecmp((string)$r['key'], $inputKey) === 0) {
        $foundIdx = $idx;
        break;
    }
}

if ($foundIdx === null) {
    echo json_encode([
        'status' => 'invalid',
        'message' => 'Key yanlışdır və ya tapılmadı.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$rec = $store['records'][$foundIdx];
$nowMs = (int)round(microtime(true) * 1000);
$nowSec = time();

if (($rec['status'] ?? '') === 'Paused') {
    $pauseType = $rec['pauseType'] ?? 'manual';
    if ($pauseType === 'update') {
        echo json_encode([
            'status' => 'updating',
            'updating' => true,
            'message' => 'Hilə hazırda yenilənir. Yeni versiya hazır olanda daxil olun.'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
    echo json_encode([
        'status' => 'paused',
        'paused' => true,
        'message' => 'Bu key müvəqqəti dayandırılıb. Admin ilə əlaqə saxlayın.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$durationMs = isset($rec['durationMs']) && $rec['durationMs'] !== null ? (int)$rec['durationMs'] : 0;
$startedAt = isset($rec['startedAt']) && $rec['startedAt'] !== null ? (int)$rec['startedAt'] : 0;
$isLifetime = ($durationMs <= 0);

if (!$isLifetime && $startedAt > 0 && ($startedAt + $durationMs) <= $nowMs) {
    echo json_encode([
        'status' => 'expired',
        'message' => 'Keyin istifadə müddəti bitib.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$deviceLimit = isset($rec['deviceLimit']) ? (int)$rec['deviceLimit'] : 1;
$keyId = $rec['id'] ?? '';
$devices = is_array($store['devices'] ?? null) ? $store['devices'] : [];

if ($hwid !== '' && $keyId !== '') {
    $matchedDevice = false;
    $activeCount = 0;

    foreach ($devices as $d) {
        if (($d['keyId'] ?? '') === $keyId && ($d['status'] ?? 'Active') === 'Active') {
            if (($d['hwid'] ?? '') === $hwid) {
                $matchedDevice = true;
            } else {
                $activeCount++;
            }
        }
    }

    if (!$matchedDevice) {
        if ($deviceLimit > 0 && $activeCount >= $deviceLimit) {
            echo json_encode([
                'status' => 'error',
                'message' => 'Bu key üçün cihaz limiti dolub.'
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }
        $devices[] = [
            'id' => bin2hex(random_bytes(6)),
            'keyId' => $keyId,
            'hwid' => $hwid,
            'status' => 'Active',
            'at' => date('Y-m-d H:i:s')
        ];
        $store['devices'] = $devices;
    }
}

if (!$isLifetime && $startedAt <= 0) {
    $startedAt = $nowMs;
    $store['records'][$foundIdx]['startedAt'] = $startedAt;
}

if (is_writable(dirname($dataFile))) {
    file_put_contents($dataFile, json_encode($store, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE), LOCK_EX);
}

$expireEpoch = $isLifetime ? 0 : (int)floor(($startedAt + $durationMs) / 1000);

echo json_encode([
    'status' => 'success',
    'lifetime' => $isLifetime,
    'expire_epoch' => $expireEpoch,
    'message' => 'Key doğrulandı.'
], JSON_UNESCAPED_UNICODE);
