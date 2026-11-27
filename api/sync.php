<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$dataDir = __DIR__ . '/../data';
$dataFile = $dataDir . '/store.json';

if (!is_dir($dataDir)) {
    @mkdir($dataDir, 0775, true);
}

$defaultStore = [
    'records' => [],
    'banned' => [],
    'devices' => [],
    'updateModeOn' => false
];

function readStoreData(string $file, array $fallback): array {
    if (!file_exists($file)) {
        $alt = __DIR__ . '/keys.json';
        if (file_exists($alt)) {
            $rawAlt = file_get_contents($alt);
            $decAlt = json_decode($rawAlt, true);
            if (is_array($decAlt)) {
                return array_merge($fallback, $decAlt);
            }
        }
        return $fallback;
    }
    $raw = file_get_contents($file);
    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        return $fallback;
    }
    return array_merge($fallback, $decoded);
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    echo json_encode([
        'status' => 'ok',
        'data' => readStoreData($dataFile, $defaultStore)
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$rawBody = file_get_contents('php://input');
$payload = json_decode($rawBody, true);
if (!is_array($payload)) {
    http_response_code(400);
    echo json_encode([
        'status' => 'error',
        'message' => 'Yanlış JSON formatı.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$current = readStoreData($dataFile, $defaultStore);

$nextStore = [
    'records' => isset($payload['records']) && is_array($payload['records']) ? $payload['records'] : $current['records'],
    'banned' => isset($payload['banned']) && is_array($payload['banned']) ? $payload['banned'] : $current['banned'],
    'devices' => isset($payload['devices']) && is_array($payload['devices']) ? $payload['devices'] : $current['devices'],
    'updateModeOn' => isset($payload['updateModeOn']) ? (bool)$payload['updateModeOn'] : (bool)$current['updateModeOn']
];

$written = @file_put_contents(
    $dataFile,
    json_encode($nextStore, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE),
    LOCK_EX
);

if ($written === false) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Fayl yazıla bilmədi (icazələri yoxla).'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

echo json_encode([
    'status' => 'ok',
    'data' => $nextStore
], JSON_UNESCAPED_UNICODE);
