<?php
ini_set('display_errors', '0');
error_reporting(0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$dataDir = __DIR__ . '/../data';
$backupDir = $dataDir . '/backups';
$dataFile = $dataDir . '/store.json';
$lockFile = $dataDir . '/store.lock';

if (!is_dir($dataDir)) {
    @mkdir($dataDir, 0775, true);
}
if (!is_dir($backupDir)) {
    @mkdir($backupDir, 0775, true);
}

$htaccess = $dataDir . '/.htaccess';
if (!file_exists($htaccess)) {
    @file_put_contents($htaccess, "Deny from all\n");
}

$defaultStore = [
    'records' => [],
    'banned' => [],
    'devices' => [],
    'deletedIds' => [],
    'updateModeOn' => false,
    'updatedAt' => 0
];

function darkiosSyncRead(string $file, string $altFile, array $fallback): array {
    $target = file_exists($file) ? $file : (file_exists($altFile) ? $altFile : '');
    if ($target === '') {
        return $fallback;
    }
    $raw = @file_get_contents($target);
    $decoded = json_decode((string)$raw, true);
    if (!is_array($decoded)) {
        return $fallback;
    }
    return array_merge($fallback, $decoded);
}

function darkiosSyncMerge(array $current, array $incoming, array $deletedIds, string $uniqueField = 'key', array $bannedKeys = []): array {
    $deletedMap = array_flip(array_map('strval', $deletedIds));
    $bannedMap = array_flip(array_map(fn($k) => strtolower((string)$k), $bannedKeys));
    $map = [];

    foreach ($current as $item) {
        if (!is_array($item)) continue;
        $id = (string)($item['id'] ?? '');
        $uk = (string)($item[$uniqueField] ?? $id);
        if ($id !== '' && isset($deletedMap[$id])) continue;
        if ($uniqueField === 'key' && $uk !== '' && isset($bannedMap[strtolower($uk)])) continue;
        if ($uk !== '') {
            $map[$uk] = $item;
        }
    }

    foreach ($incoming as $item) {
        if (!is_array($item)) continue;
        $id = (string)($item['id'] ?? '');
        $uk = (string)($item[$uniqueField] ?? $id);
        if ($id !== '' && isset($deletedMap[$id])) continue;
        if ($uniqueField === 'key' && $uk !== '' && isset($bannedMap[strtolower($uk)])) continue;
        if ($uk === '') continue;

        if (isset($map[$uk])) {
            $existing = $map[$uk];
            $existingMod = (int)($existing['modifiedAt'] ?? 0);
            $incomingMod = (int)($item['modifiedAt'] ?? 0);
            if ($incomingMod >= $existingMod) {
                if (empty($item['startedAt']) && !empty($existing['startedAt'])) {
                    $item['startedAt'] = $existing['startedAt'];
                }
                $map[$uk] = array_merge($existing, $item);
            }
        } else {
            $map[$uk] = $item;
        }
    }

    $result = array_values($map);
    usort($result, fn($a, $b) => strcmp((string)($b['created'] ?? ''), (string)($a['created'] ?? '')));
    return $result;
}

function darkiosSyncWriteAtomic(string $file, string $backupDir, array $store): bool {
    $json = json_encode($store, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    if ($json === false) {
        return false;
    }
    $tmp = $file . '.tmp.' . getmypid() . '.' . mt_rand(1000, 9999);
    if (@file_put_contents($tmp, $json, LOCK_EX) === false) {
        return false;
    }
    if (!@rename($tmp, $file)) {
        @unlink($tmp);
        return false;
    }
    if (is_dir($backupDir) && count($store['records']) > 0) {
        $bak = $backupDir . '/store_' . date('Ymd_His') . '_' . mt_rand(100, 999) . '.json';
        @file_put_contents($bak, $json, LOCK_EX);
        $baks = glob($backupDir . '/store_*.json');
        if ($baks && count($baks) > 30) {
            sort($baks);
            foreach (array_slice($baks, 0, count($baks) - 30) as $old) {
                @unlink($old);
            }
        }
    }
    return true;
}

$lockFp = @fopen($lockFile, 'c+');
if ($lockFp) {
    @flock($lockFp, LOCK_EX);
}

$current = darkiosSyncRead($dataFile, __DIR__ . '/keys.json', $defaultStore);

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    echo json_encode(['status' => 'ok', 'data' => $current], JSON_UNESCAPED_UNICODE);
    exit;
}

$rawBody = (string)file_get_contents('php://input');
$payload = json_decode($rawBody, true);
if (!is_array($payload)) {
    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Yanlış JSON formatı.'], JSON_UNESCAPED_UNICODE);
    exit;
}

$action = (string)($payload['action'] ?? 'merge');
$deletedIds = is_array($current['deletedIds'] ?? null) ? $current['deletedIds'] : [];

if ($action === 'delete_key' && !empty($payload['id'])) {
    $delId = (string)$payload['id'];
    if (!in_array($delId, $deletedIds, true)) $deletedIds[] = $delId;
    $current['records'] = array_values(array_filter($current['records'], fn($r) => (string)($r['id'] ?? '') !== $delId));
    $current['devices'] = array_values(array_filter($current['devices'], fn($d) => (string)($d['keyId'] ?? '') !== $delId));
} elseif ($action === 'ban_key') {
    $banObj = is_array($payload['banEntry'] ?? null) ? $payload['banEntry'] : null;
    $delId = (string)($payload['id'] ?? '');
    $banKeyVal = (string)($banObj['key'] ?? ($payload['key'] ?? ''));
    if ($delId !== '' && !in_array($delId, $deletedIds, true)) $deletedIds[] = $delId;
    foreach ($current['records'] as $r) {
        if (!empty($r['id']) && (($banKeyVal !== '' && strcasecmp((string)($r['key'] ?? ''), $banKeyVal) === 0) || (string)$r['id'] === $delId)) {
            $rid = (string)$r['id'];
            if (!in_array($rid, $deletedIds, true)) $deletedIds[] = $rid;
        }
    }
    if ($banKeyVal !== '') {
        $current['records'] = array_values(array_filter($current['records'], fn($r) => strcasecmp((string)($r['key'] ?? ''), $banKeyVal) !== 0 && (string)($r['id'] ?? '') !== $delId));
        if ($banObj) array_unshift($current['banned'], $banObj);
    }
} elseif ($action === 'unban_key' && !empty($payload['id'])) {
    $unbanId = (string)$payload['id'];
    if (!in_array($unbanId, $deletedIds, true)) $deletedIds[] = $unbanId;
    $current['banned'] = array_values(array_filter($current['banned'], fn($b) => (string)($b['id'] ?? '') !== $unbanId));
} elseif ($action === 'clear_all_manual' && !empty($payload['confirmClearAll'])) {
    foreach ($current['records'] as $r) {
        if (!empty($r['id'])) $deletedIds[] = (string)$r['id'];
    }
    $current['records'] = [];
    $current['devices'] = [];
    $current['updateModeOn'] = false;
}

$deletedIds = array_values(array_unique(array_slice($deletedIds, -5000)));
$incomingRecords = isset($payload['records']) && is_array($payload['records']) ? $payload['records'] : [];
$incomingBanned = isset($payload['banned']) && is_array($payload['banned']) ? $payload['banned'] : [];
$incomingDevices = isset($payload['devices']) && is_array($payload['devices']) ? $payload['devices'] : [];

$mergedBanned = darkiosSyncMerge($current['banned'], $incomingBanned, $deletedIds, 'key');
$bannedKeys = array_values(array_filter(array_map(fn($b) => (string)($b['key'] ?? ''), $mergedBanned)));

$mergedRecords = ($action === 'clear_all_manual')
    ? []
    : darkiosSyncMerge($current['records'], $incomingRecords, $deletedIds, 'key', $bannedKeys);
$mergedDevices = ($action === 'clear_all_manual')
    ? []
    : darkiosSyncMerge($current['devices'], $incomingDevices, $deletedIds, 'id');

$nextStore = [
    'records' => $mergedRecords,
    'banned' => $mergedBanned,
    'devices' => $mergedDevices,
    'deletedIds' => $deletedIds,
    'updateModeOn' => isset($payload['updateModeOn']) ? (bool)$payload['updateModeOn'] : (bool)$current['updateModeOn'],
    'updatedAt' => (int)round(microtime(true) * 1000)
];

if (!darkiosSyncWriteAtomic($dataFile, $backupDir, $nextStore)) {
    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Fayl yazıla bilmədi (icazələri yoxla).'], JSON_UNESCAPED_UNICODE);
    exit;
}

if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
echo json_encode(['status' => 'ok', 'data' => $nextStore], JSON_UNESCAPED_UNICODE);
