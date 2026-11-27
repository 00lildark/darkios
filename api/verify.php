<?php
ini_set('display_errors', '0');
error_reporting(0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
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

$defaultStore = [
    'records' => [],
    'banned' => [],
    'devices' => [],
    'deletedIds' => [],
    'updateModeOn' => false,
    'updatedAt' => 0
];

function darkiosVerifyClientIp(): string {
    foreach (['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'REMOTE_ADDR'] as $h) {
        if (!empty($_SERVER[$h])) {
            $parts = explode(',', (string)$_SERVER[$h]);
            $ip = trim($parts[0]);
            if (filter_var($ip, FILTER_VALIDATE_IP)) {
                return $ip;
            }
        }
    }
    return '0.0.0.0';
}

function darkiosVerifyGeo(string $ip): array {
    if (!filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
        return ['location' => 'Local / Private Network', 'isp' => 'Local', 'asn' => 'N/A', 'vpnActive' => 'No'];
    }
    $ctx = stream_context_create(['http' => ['timeout' => 2]]);
    $raw = @file_get_contents("http://ip-api.com/json/" . urlencode($ip) . "?fields=status,country,regionName,city,isp,as,proxy", false, $ctx);
    $j = json_decode((string)$raw, true);
    if (is_array($j) && ($j['status'] ?? '') === 'success') {
        $loc = trim(($j['city'] ?? '') . ', ' . ($j['regionName'] ?? '') . ', ' . ($j['country'] ?? ''), ', ');
        return [
            'location' => $loc ?: 'Unknown',
            'isp' => (string)($j['isp'] ?? 'Unknown'),
            'asn' => (string)($j['as'] ?? 'Unknown'),
            'vpnActive' => !empty($j['proxy']) ? 'Yes' : 'No'
        ];
    }
    return ['location' => 'Unknown', 'isp' => 'Unknown', 'asn' => 'Unknown', 'vpnActive' => 'Unknown'];
}

$rawBody = (string)file_get_contents('php://input');
$jsonBody = json_decode($rawBody, true);
if (!is_array($jsonBody)) {
    parse_str($rawBody, $parsedForm);
    $jsonBody = is_array($parsedForm) ? $parsedForm : [];
}
$input = array_merge($_GET, $_POST, $jsonBody);

$inputKey = trim((string)($input['key'] ?? ''));
$hwid = trim((string)($input['hwid'] ?? ''));

if ($inputKey === '') {
    echo json_encode([
        'status' => 'error',
        'valid' => false,
        'message' => 'Key boş ola bilməz.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$lockFp = @fopen($lockFile, 'c+');
if ($lockFp) {
    @flock($lockFp, LOCK_EX);
}

$targetFile = file_exists($dataFile) ? $dataFile : (file_exists(__DIR__ . '/keys.json') ? __DIR__ . '/keys.json' : '');
$store = $defaultStore;
if ($targetFile !== '') {
    $decoded = json_decode((string)@file_get_contents($targetFile), true);
    if (is_array($decoded)) {
        $store = array_merge($defaultStore, $decoded);
    }
}

if (!empty($store['updateModeOn'])) {
    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    echo json_encode([
        'status' => 'updating',
        'valid' => false,
        'updating' => true,
        'message' => 'Hilə hazırda yenilənir. Yeni versiya hazır olanda daxil olun.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

foreach (($store['banned'] ?? []) as $b) {
    if (isset($b['key']) && strcasecmp((string)$b['key'], $inputKey) === 0) {
        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        echo json_encode([
            'status' => 'banned',
            'valid' => false,
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
    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    echo json_encode([
        'status' => 'invalid',
        'valid' => false,
        'message' => 'Key yanlışdır və ya tapılmadı.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$rec = $store['records'][$foundIdx];
$nowMs = (int)round(microtime(true) * 1000);

if (($rec['status'] ?? '') === 'Paused') {
    $pauseType = $rec['pauseType'] ?? 'manual';
    if ($pauseType === 'temp' && !empty($rec['pauseUntil']) && (int)$rec['pauseUntil'] <= $nowMs) {
        $rec['status'] = 'Active';
        $rec['pauseType'] = null;
        $rec['pauseUntil'] = null;
        $rec['modifiedAt'] = $nowMs;
    } elseif ($pauseType === 'update') {
        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        echo json_encode([
            'status' => 'updating',
            'valid' => false,
            'updating' => true,
            'message' => 'Hilə hazırda yenilənir. Yeni versiya hazır olanda daxil olun.'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    } else {
        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        echo json_encode([
            'status' => 'paused',
            'valid' => false,
            'paused' => true,
            'message' => 'Bu key müvəqqəti dayandırılıb. Admin ilə əlaqə saxlayın.'
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

$durationMs = isset($rec['durationMs']) && $rec['durationMs'] !== null ? (int)$rec['durationMs'] : 0;
$startedAt = isset($rec['startedAt']) && $rec['startedAt'] !== null ? (int)$rec['startedAt'] : 0;
$isLifetime = ($durationMs <= 0);

if (!$isLifetime && $startedAt > 0 && ($startedAt + $durationMs) <= $nowMs) {
    $rec['status'] = 'Expired';
    $rec['modifiedAt'] = $nowMs;
    $store['records'][$foundIdx] = $rec;
    if (is_writable(dirname($dataFile))) {
        @file_put_contents($dataFile, json_encode($store, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE), LOCK_EX);
    }
    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    echo json_encode([
        'status' => 'expired',
        'valid' => false,
        'message' => 'Keyin istifadə müddəti bitib.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$deviceLimit = isset($rec['deviceLimit']) ? (int)$rec['deviceLimit'] : 1;
$keyId = (string)($rec['id'] ?? '');
$devices = is_array($store['devices'] ?? null) ? $store['devices'] : [];

$existingDevIdx = -1;
$activeCount = 0;
foreach ($devices as $dIdx => $d) {
    if (($d['keyId'] ?? '') === $keyId && ($d['status'] ?? 'Active') === 'Active') {
        if ($hwid !== '' && ($d['hwid'] ?? '') === $hwid) {
            $existingDevIdx = $dIdx;
        } else {
            $activeCount++;
        }
    }
}

if ($existingDevIdx === -1 && $deviceLimit > 0 && $activeCount >= $deviceLimit) {
    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    echo json_encode([
        'status' => 'error',
        'valid' => false,
        'message' => 'Bu key üçün cihaz limiti dolub.'
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

$realIp = darkiosVerifyClientIp();
$geo = darkiosVerifyGeo($realIp);

$deviceEntry = [
    'id' => $existingDevIdx !== -1 ? (string)$devices[$existingDevIdx]['id'] : bin2hex(random_bytes(6)),
    'keyId' => $keyId,
    'status' => 'Active',
    'at' => date('Y-m-d H:i:s'),
    'modifiedAt' => $nowMs,
    'ip' => $realIp,
    'location' => $geo['location'],
    'isp' => $geo['isp'],
    'asn' => $geo['asn'],
    'vpnActive' => $geo['vpnActive'],
    'hwid' => $hwid !== '' ? $hwid : 'Unknown',
    'deviceModel' => (string)($input['deviceModel'] ?? 'Unknown iPhone'),
    'deviceName' => (string)($input['deviceName'] ?? 'iPhone'),
    'machineId' => (string)($input['machineId'] ?? 'Unknown'),
    'iosVersion' => (string)($input['iosVersion'] ?? 'Unknown'),
    'systemName' => (string)($input['systemName'] ?? 'iOS'),
    'battery' => (string)($input['battery'] ?? 'Unknown'),
    'batteryState' => (string)($input['batteryState'] ?? 'Unknown'),
    'lowPowerMode' => (string)($input['lowPowerMode'] ?? 'Unknown'),
    'network' => (string)($input['network'] ?? 'Unknown'),
    'carrier' => (string)($input['carrier'] ?? 'Unknown'),
    'localIp' => (string)($input['localIp'] ?? 'Unknown'),
    'architecture' => (string)($input['architecture'] ?? 'arm64e'),
    'cpuCores' => (string)($input['cpuCores'] ?? 'Unknown'),
    'ramTotal' => (string)($input['ramTotal'] ?? 'Unknown'),
    'ramUsed' => (string)($input['ramUsed'] ?? 'Unknown'),
    'storageTotal' => (string)($input['storageTotal'] ?? 'Unknown'),
    'storageFree' => (string)($input['storageFree'] ?? 'Unknown'),
    'screenRes' => (string)($input['screenRes'] ?? 'Unknown'),
    'refreshRate' => (string)($input['refreshRate'] ?? 'Unknown'),
    'brightness' => (string)($input['brightness'] ?? 'Unknown'),
    'timezone' => (string)($input['timezone'] ?? 'Unknown'),
    'locale' => (string)($input['locale'] ?? 'Unknown'),
    'uptime' => (string)($input['uptime'] ?? 'Unknown'),
    'bundleId' => (string)($input['bundleId'] ?? 'Unknown'),
    'appVersion' => (string)($input['appVersion'] ?? 'Unknown'),
    'jailbreakStatus' => (string)($input['jailbreakStatus'] ?? 'Non-Jailbroken')
];

if ($existingDevIdx !== -1) {
    $devices[$existingDevIdx] = $deviceEntry;
} else {
    array_unshift($devices, $deviceEntry);
}
$store['devices'] = $devices;

if (!$isLifetime && $startedAt <= 0) {
    $startedAt = $nowMs;
    $rec['startedAt'] = $startedAt;
}
$rec['modifiedAt'] = $nowMs;
$store['records'][$foundIdx] = $rec;
$store['updatedAt'] = $nowMs;

if (is_writable(dirname($dataFile))) {
    $json = json_encode($store, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    if ($json !== false) {
        @file_put_contents($dataFile, $json, LOCK_EX);
        if (is_dir($backupDir) && count($store['records']) > 0) {
            $bak = $backupDir . '/store_' . date('Ymd_His') . '_' . mt_rand(100, 999) . '.json';
            @file_put_contents($bak, $json, LOCK_EX);
        }
    }
}

if ($lockFp) {
    @flock($lockFp, LOCK_UN);
    @fclose($lockFp);
}

$expireEpoch = $isLifetime ? 0 : (int)floor(($startedAt + $durationMs) / 1000);

echo json_encode([
    'status' => 'success',
    'valid' => true,
    'lifetime' => $isLifetime,
    'expire_epoch' => $expireEpoch,
    'message' => 'Key doğrulandı.'
], JSON_UNESCAPED_UNICODE);
