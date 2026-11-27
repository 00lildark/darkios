<?php
ini_set('display_errors', '0');
error_reporting(0);
if (function_exists('ob_get_level')) {
    while (ob_get_level() > 0) {
        @ob_end_clean();
    }
}

$dataDir = __DIR__ . '/data';
$backupDir = $dataDir . '/backups';
$dataFile = $dataDir . '/store.json';
$lockFile = $dataDir . '/store.lock';

if (!is_dir($dataDir)) @mkdir($dataDir, 0775, true);
if (!is_dir($backupDir)) @mkdir($backupDir, 0775, true);

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

function darkiosJsonOut(array $payload, int $code = 200): void {
    http_response_code($code);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Pragma: no-cache');
    echo json_encode($payload, JSON_UNESCAPED_UNICODE);
    exit;
}

function darkiosReadStore(string $file, string $backupDir, array $fallback): array {
    $tryFiles = [$file];
    if (is_dir($backupDir)) {
        $baks = glob($backupDir . '/store_*.json');
        if ($baks) {
            rsort($baks);
            $tryFiles = array_merge($tryFiles, array_slice($baks, 0, 5));
        }
    }
    $alt = __DIR__ . '/api/keys.json';
    if (file_exists($alt)) {
        $tryFiles[] = $alt;
    }

    foreach ($tryFiles as $candidate) {
        if (!file_exists($candidate)) continue;
        $raw = @file_get_contents($candidate);
        if ($raw === false || trim($raw) === '') continue;
        $decoded = json_decode($raw, true);
        if (is_array($decoded) && (isset($decoded['records']) || isset($decoded['banned']))) {
            return array_merge($fallback, $decoded);
        }
    }
    return $fallback;
}

function darkiosWriteStore(string $file, string $backupDir, array $store): bool {
    $json = json_encode($store, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    if ($json === false) return false;

    $tmp = $file . '.tmp.' . getmypid() . '.' . mt_rand(1000, 9999);
    if (@file_put_contents($tmp, $json, LOCK_EX) === false) return false;
    if (!@rename($tmp, $file)) {
        @unlink($tmp);
        return false;
    }

    if (is_dir($backupDir) && count($store['records']) > 0) {
        $bakFile = $backupDir . '/store_' . date('Ymd_His') . '_' . mt_rand(100, 999) . '.json';
        @file_put_contents($bakFile, $json, LOCK_EX);
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

function darkiosClientIp(): string {
    foreach (['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'REMOTE_ADDR'] as $h) {
        if (!empty($_SERVER[$h])) {
            $parts = explode(',', (string)$_SERVER[$h]);
            $ip = trim($parts[0]);
            if (filter_var($ip, FILTER_VALIDATE_IP)) return $ip;
        }
    }
    return '0.0.0.0';
}

function darkiosGeoLookup(string $ip): array {
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

function darkiosMergeByKeyOrId(array $current, array $incoming, array $deletedIds, string $uniqueField = 'key', array $bannedKeys = []): array {
    $deletedMap = array_flip($deletedIds);
    $bannedMap = array_flip(array_map(fn($k) => strtolower((string)$k), $bannedKeys));
    $map = [];

    foreach ($current as $item) {
        if (!is_array($item)) continue;
        $id = (string)($item['id'] ?? '');
        $uk = (string)($item[$uniqueField] ?? $id);
        if ($id !== '' && isset($deletedMap[$id])) continue;
        if ($uniqueField === 'key' && $uk !== '' && isset($bannedMap[strtolower($uk)])) continue;
        if ($uk !== '') $map[$uk] = $item;
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

if (isset($_GET['verify'])) {
    $rawBody = (string)file_get_contents('php://input');
    $input = json_decode($rawBody, true);
    if (!is_array($input)) {
        parse_str($rawBody, $parsedForm);
        $input = is_array($parsedForm) && !empty($parsedForm) ? $parsedForm : $_POST;
    }
    if (!is_array($input)) $input = [];

    $keyInput = trim((string)($input['key'] ?? ($_GET['key'] ?? '')));
    $hwid = trim((string)($input['hwid'] ?? ($_GET['hwid'] ?? '')));

    if ($keyInput === '') {
        darkiosJsonOut(['status' => 'error', 'valid' => false, 'message' => 'Key boşdur']);
    }

    $lockFp = @fopen($lockFile, 'c+');
    if ($lockFp) @flock($lockFp, LOCK_EX);

    $store = darkiosReadStore($dataFile, $backupDir, $defaultStore);

    foreach ($store['banned'] as $b) {
        if (strcasecmp((string)($b['key'] ?? ''), $keyInput) === 0) {
            if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
            darkiosJsonOut(['status' => 'error', 'valid' => false, 'banned' => true, 'message' => 'Bu key banlanıb']);
        }
    }

    if (!empty($store['updateModeOn'])) {
        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        darkiosJsonOut(['status' => 'error', 'valid' => false, 'updating' => true, 'message' => 'UPDATE aktivdir']);
    }

    $foundIdx = -1;
    foreach ($store['records'] as $idx => $rec) {
        if (strcasecmp((string)($rec['key'] ?? ''), $keyInput) === 0) {
            $foundIdx = $idx;
            break;
        }
    }

    if ($foundIdx === -1) {
        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        darkiosJsonOut(['status' => 'error', 'valid' => false, 'message' => 'Key tapılmadı']);
    }

    $rec = $store['records'][$foundIdx];
    $nowMs = (int)round(microtime(true) * 1000);

    if (($rec['status'] ?? '') === 'Paused') {
        if (($rec['pauseType'] ?? '') === 'temp' && !empty($rec['pauseUntil']) && (int)$rec['pauseUntil'] <= $nowMs) {
            $rec['status'] = 'Active';
            $rec['pauseType'] = null;
            $rec['pauseUntil'] = null;
            $rec['modifiedAt'] = $nowMs;
        } else {
            if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
            darkiosJsonOut(['status' => 'error', 'valid' => false, 'paused' => true, 'message' => 'Key dayandırılıb']);
        }
    }

    if (empty($rec['startedAt'])) {
        $rec['startedAt'] = $nowMs;
    }

    $durationMs = isset($rec['durationMs']) && $rec['durationMs'] !== null && $rec['durationMs'] !== '' ? (int)$rec['durationMs'] : 0;
    if ($durationMs > 0 && ((int)$rec['startedAt'] + $durationMs) <= $nowMs) {
        $rec['status'] = 'Expired';
        $rec['modifiedAt'] = $nowMs;
        $store['records'][$foundIdx] = $rec;
        darkiosWriteStore($dataFile, $backupDir, $store);
        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        darkiosJsonOut(['status' => 'error', 'valid' => false, 'message' => 'Key vaxtı bitib']);
    }

    $keyId = (string)$rec['id'];
    $limit = (int)($rec['deviceLimit'] ?? 1);
    $keyDevices = array_values(array_filter($store['devices'], fn($d) => ($d['keyId'] ?? '') === $keyId));
    $existingDevIdx = -1;
    foreach ($store['devices'] as $dIdx => $dev) {
        if (($dev['keyId'] ?? '') === $keyId && $hwid !== '' && ($dev['hwid'] ?? '') === $hwid) {
            $existingDevIdx = $dIdx;
            break;
        }
    }

    if ($existingDevIdx === -1 && $limit > 0 && count($keyDevices) >= $limit) {
        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        darkiosJsonOut(['status' => 'error', 'valid' => false, 'message' => 'Cihaz limiti dolub (' . $limit . ')']);
    }

    $realIp = darkiosClientIp();
    $geo = darkiosGeoLookup($realIp);

    $devicePayload = [
        'id' => $existingDevIdx !== -1 ? $store['devices'][$existingDevIdx]['id'] : bin2hex(random_bytes(6)),
        'keyId' => $keyId,
        'status' => 'Active',
        'at' => date('Y-m-d H:i:s'),
        'modifiedAt' => $nowMs,
        'ip' => $realIp,
        'location' => $geo['location'],
        'isp' => $geo['isp'],
        'asn' => $geo['asn'],
        'vpnActive' => $geo['vpnActive'],
        'hwid' => $hwid ?: 'Unknown',
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
        $store['devices'][$existingDevIdx] = $devicePayload;
    } else {
        array_unshift($store['devices'], $devicePayload);
    }

    $rec['modifiedAt'] = $nowMs;
    $store['records'][$foundIdx] = $rec;
    $store['updatedAt'] = $nowMs;

    darkiosWriteStore($dataFile, $backupDir, $store);
    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }

    $isLifetime = ($durationMs <= 0);
    $expireEpoch = $isLifetime ? 0 : (int)floor(((int)$rec['startedAt'] + $durationMs) / 1000);

    darkiosJsonOut([
        'status' => 'ok',
        'valid' => true,
        'message' => 'Verified',
        'key' => $rec['key'],
        'type' => $rec['type'] ?? 'NORMAL',
        'lifetime' => $isLifetime,
        'expire_epoch' => $expireEpoch,
        'startedAt' => $rec['startedAt'],
        'durationMs' => $durationMs
    ]);
}

if (isset($_GET['sync'])) {
    $lockFp = @fopen($lockFile, 'c+');
    if ($lockFp) @flock($lockFp, LOCK_EX);

    $current = darkiosReadStore($dataFile, $backupDir, $defaultStore);

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $payload = json_decode((string)file_get_contents('php://input'), true);
        if (!is_array($payload)) {
            if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
            darkiosJsonOut(['status' => 'error', 'message' => 'Invalid JSON'], 400);
        }

        $action = $payload['action'] ?? 'merge';
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
        $incomingRecords = is_array($payload['records'] ?? null) ? $payload['records'] : [];
        $incomingBanned = is_array($payload['banned'] ?? null) ? $payload['banned'] : [];
        $incomingDevices = is_array($payload['devices'] ?? null) ? $payload['devices'] : [];

        $mergedBanned = darkiosMergeByKeyOrId($current['banned'], $incomingBanned, $deletedIds, 'key');
        $bannedKeys = array_values(array_filter(array_map(fn($b) => (string)($b['key'] ?? ''), $mergedBanned)));

        $mergedRecords = ($action === 'clear_all_manual')
            ? []
            : darkiosMergeByKeyOrId($current['records'], $incomingRecords, $deletedIds, 'key', $bannedKeys);
        $mergedDevices = ($action === 'clear_all_manual')
            ? []
            : darkiosMergeByKeyOrId($current['devices'], $incomingDevices, $deletedIds, 'id');

        $nextStore = [
            'records' => $mergedRecords,
            'banned' => $mergedBanned,
            'devices' => $mergedDevices,
            'deletedIds' => $deletedIds,
            'updateModeOn' => isset($payload['updateModeOn']) ? (bool)$payload['updateModeOn'] : (bool)$current['updateModeOn'],
            'updatedAt' => (int)round(microtime(true) * 1000)
        ];

        if (!darkiosWriteStore($dataFile, $backupDir, $nextStore)) {
            if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
            darkiosJsonOut(['status' => 'error', 'message' => 'Write failed'], 500);
        }

        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        darkiosJsonOut(['status' => 'ok', 'data' => $nextStore]);
    }

    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    darkiosJsonOut(['status' => 'ok', 'data' => $current]);
}

$initialStore = darkiosReadStore($dataFile, $backupDir, $defaultStore);
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>DARKIOS • Admin Console</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@500;600;700&family=Sora:wght@500;600;700;800&display=swap" rel="stylesheet">
<style>
/* DARKIOS Admin Console theme */
:root{
  --bg:#06060a;
  --rail:rgba(12,12,18,.78);
  --panel:rgba(18,18,27,.72);
  --panel-solid:#12121b;
  --panel2:#1a1a26;
  --panel3:#222232;
  --line:rgba(255,255,255,.075);
  --line-strong:rgba(255,255,255,.14);
  --text:#f4f4f8;
  --muted:#8b8ba0;
  --red:#ff3d57;
  --red2:#ff7a45;
  --red-hover:#ff5a70;
  --red-soft:rgba(255,61,87,.12);
  --red-border:rgba(255,61,87,.38);
  --green:#3ddc97;
  --green-soft:rgba(61,220,151,.12);
  --amber:#ffb454;
  --grad:linear-gradient(135deg,#ff3d57 0%,#ff6a3d 100%);
  --radius:14px;
  --ease:cubic-bezier(.2,.8,.2,1);
}
*{box-sizing:border-box}
html{scroll-behavior:smooth}
body{
  margin:0;color:var(--text);min-height:100vh;
  font-family:'Sora',system-ui,-apple-system,'Segoe UI',sans-serif;
  font-weight:500;font-size:13px;line-height:1.45;
  background:
    radial-gradient(900px 500px at 85% -10%,rgba(255,61,87,.13),transparent 60%),
    radial-gradient(700px 480px at -5% 105%,rgba(255,106,61,.08),transparent 60%),
    var(--bg);
  background-attachment:fixed;
  -webkit-font-smoothing:antialiased;
}
body::before{
  content:"";position:fixed;inset:0;z-index:0;pointer-events:none;opacity:.5;
  background-image:
    linear-gradient(var(--line) 1px,transparent 1px),
    linear-gradient(90deg,var(--line) 1px,transparent 1px);
  background-size:44px 44px;
  -webkit-mask-image:radial-gradient(ellipse at 50% 0%,#000 0%,transparent 70%);
  mask-image:radial-gradient(ellipse at 50% 0%,#000 0%,transparent 70%);
}
::selection{background:var(--red);color:#fff}
::-webkit-scrollbar{width:9px;height:9px}
::-webkit-scrollbar-thumb{background:var(--panel3);border-radius:9px;border:2px solid var(--bg)}
::-webkit-scrollbar-thumb:hover{background:#34344a}
::-webkit-scrollbar-track{background:transparent}
button,input,select,textarea{font-family:inherit}
button:focus-visible,input:focus-visible,select:focus-visible,textarea:focus-visible,label:focus-within{
  outline:2px solid var(--red);outline-offset:2px
}

.shell{display:flex;min-height:100vh;position:relative;z-index:1}
.rail{
  width:64px;flex:0 0 64px;position:fixed;inset:0 auto 0 0;z-index:8;
  background:var(--rail);backdrop-filter:blur(22px) saturate(140%);-webkit-backdrop-filter:blur(22px) saturate(140%);
  border-right:1px solid var(--line);
  display:flex;flex-direction:column;align-items:center;padding:16px 0;gap:8px;
}
.rail .logo{
  width:40px;height:40px;border-radius:12px;display:grid;place-items:center;margin-bottom:18px;color:#fff;
  background:var(--grad);box-shadow:0 8px 24px -6px rgba(255,61,87,.6),inset 0 1px 0 rgba(255,255,255,.35);
}
.rail svg{width:19px;height:19px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.rail button{
  position:relative;width:42px;height:42px;border-radius:12px;border:1px solid transparent;background:transparent;
  color:var(--muted);display:grid;place-items:center;cursor:pointer;transition:all .22s var(--ease);
}
.rail button:hover{color:var(--text);background:var(--panel2);transform:translateY(-1px)}
.rail button.active{color:#fff;background:var(--red-soft);border-color:var(--red-border);box-shadow:0 0 0 4px rgba(255,61,87,.06)}
.rail button.active::before{
  content:"";position:absolute;left:-11px;top:11px;bottom:11px;width:3px;border-radius:3px;background:var(--grad);
  box-shadow:0 0 12px var(--red);
}

.main{margin-left:64px;min-width:0;width:calc(100% - 64px)}
.topbar{
  height:60px;position:sticky;top:0;z-index:5;padding:0 24px;
  display:flex;align-items:center;justify-content:space-between;
  background:rgba(6,6,10,.62);backdrop-filter:blur(18px) saturate(140%);-webkit-backdrop-filter:blur(18px) saturate(140%);
  border-bottom:1px solid var(--line);
}
.top-left{display:flex;align-items:center;gap:11px;font-size:15px;font-weight:700;letter-spacing:.2px}
.top-left .dot{width:8px;height:8px;border-radius:50%;background:var(--green);box-shadow:0 0 0 4px var(--green-soft),0 0 14px var(--green);animation:pulse 2.4s ease-in-out infinite}
@keyframes pulse{50%{box-shadow:0 0 0 7px rgba(61,220,151,0),0 0 14px var(--green)}}
.top-right{display:flex;align-items:center;gap:8px}
.top-btn,.top-select{
  height:34px;padding:0 13px;border-radius:10px;cursor:pointer;
  border:1px solid var(--line);background:var(--panel);color:var(--text);
  font-size:11.5px;font-weight:600;transition:all .2s var(--ease);
}
.top-btn:hover,.top-select:hover{border-color:var(--line-strong);background:var(--panel2)}
.top-btn:active{transform:scale(.97)}
.top-select option,.filters select option,.field select option{background:var(--panel-solid);color:var(--text)}
.content{padding:30px 24px 48px;max-width:1560px;margin:auto}

.heading{display:flex;align-items:flex-end;justify-content:space-between;gap:14px;margin:0 0 24px;flex-wrap:wrap}
.heading h1{font-size:26px;margin:0 0 6px;font-weight:800;letter-spacing:-.6px}
.heading p{margin:0;color:var(--muted);font-size:12px;font-weight:500;max-width:70ch}
.create{
  position:relative;overflow:hidden;border:0;border-radius:11px;padding:11px 18px;cursor:pointer;
  background:var(--grad);color:#fff;font-size:12px;font-weight:700;letter-spacing:.2px;
  box-shadow:0 10px 26px -10px rgba(255,61,87,.8),inset 0 1px 0 rgba(255,255,255,.28);
  transition:transform .2s var(--ease),box-shadow .2s var(--ease),filter .2s;
}
.create::after{
  content:"";position:absolute;inset:0;background:linear-gradient(110deg,transparent 30%,rgba(255,255,255,.28) 50%,transparent 70%);
  transform:translateX(-120%);transition:transform .6s var(--ease);
}
.create:hover{transform:translateY(-2px);box-shadow:0 16px 30px -10px rgba(255,61,87,.9),inset 0 1px 0 rgba(255,255,255,.3)}
.create:hover::after{transform:translateX(120%)}
.create:active{transform:translateY(0) scale(.98)}
.secondary{
  background:var(--panel2);color:var(--text);border:1px solid var(--line);border-radius:10px;padding:9px 14px;
  font-size:11.5px;font-weight:600;cursor:pointer;transition:all .2s var(--ease);margin:2px 6px 2px 0;
}
.secondary:hover{border-color:var(--line-strong);background:var(--panel3);transform:translateY(-1px)}
.secondary.danger{border-color:var(--red-border);color:var(--red);background:var(--red-soft)}
.secondary.danger:hover{background:rgba(255,61,87,.22)}

.cards{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px;margin-bottom:22px}
.metric{
  position:relative;overflow:hidden;padding:18px 20px;border-radius:var(--radius);
  background:var(--panel);border:1px solid var(--line);backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);
  transition:transform .25s var(--ease),border-color .25s;
}
.metric::before{
  content:"";position:absolute;left:0;top:0;right:0;height:2px;
  background:linear-gradient(90deg,var(--line-strong),transparent);
}
.metric:hover{transform:translateY(-3px);border-color:var(--line-strong)}
.metric .label{font-size:11px;color:var(--muted);font-weight:600;letter-spacing:.4px}
.metric strong{display:block;margin-top:10px;font-size:32px;line-height:1;font-weight:800;letter-spacing:-1px;font-variant-numeric:tabular-nums}
.metric.accent{border-color:var(--red-border);background:linear-gradient(160deg,rgba(255,61,87,.14),var(--panel) 65%)}
.metric.accent::before{background:var(--grad)}
.metric.accent strong{background:var(--grad);-webkit-background-clip:text;background-clip:text;color:transparent}
.metric:nth-child(2) strong{color:var(--green)}

.table-panel{
  border-radius:var(--radius);overflow:hidden;background:var(--panel);border:1px solid var(--line);
  backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);box-shadow:0 24px 60px -30px rgba(0,0,0,.8);
}
.table-head{padding:16px 18px;display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;border-bottom:1px solid var(--line)}
.table-title{display:flex;align-items:center;gap:10px;font-size:14px;font-weight:700}
.count{font-size:10.5px;font-weight:700;color:var(--red);background:var(--red-soft);border:1px solid var(--red-border);padding:3px 9px;border-radius:99px}
.filters{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.filters input,.filters select{
  height:36px;border-radius:10px;border:1px solid var(--line);background:rgba(0,0,0,.35);color:var(--text);
  font-size:11.5px;font-weight:500;padding:0 12px;transition:border-color .2s,background .2s;
}
.filters input{width:210px}
.filters input::placeholder{color:var(--muted)}
.filters input:focus,.filters select:focus{border-color:var(--red-border);background:rgba(0,0,0,.5);outline:none}
.reset{height:36px;border-radius:10px;border:1px solid var(--line);background:var(--panel2);color:var(--text);font-size:11.5px;font-weight:600;padding:0 14px;cursor:pointer;transition:all .2s}
.reset:hover{border-color:var(--line-strong);background:var(--panel3)}
.table-wrap{overflow-x:auto}
.table{width:100%;border-collapse:separate;border-spacing:0;min-width:940px}
.table th{
  height:40px;padding:0 16px;text-align:left;font-size:10.5px;font-weight:700;letter-spacing:.8px;color:var(--muted);
  background:rgba(255,255,255,.025);border-bottom:1px solid var(--line);position:sticky;top:0;
}
.table td{height:60px;padding:10px 16px;font-size:12px;font-weight:600;white-space:nowrap;border-bottom:1px solid var(--line);transition:background .18s}
.table tbody tr{transition:background .18s}
.table tbody tr:hover td{background:rgba(255,255,255,.035)}
.table tbody tr:hover td:first-child{box-shadow:inset 3px 0 0 var(--red)}
.table tr:last-child td{border-bottom:0}
.name{font-weight:700;font-size:12.5px}
.desc{font-size:10.5px;color:var(--muted);margin-top:3px;font-weight:500;max-width:220px;overflow:hidden;text-overflow:ellipsis}
.key-cell{display:inline-flex;align-items:center;gap:8px}
.keycode{
  font-family:'JetBrains Mono',ui-monospace,monospace;font-size:11px;font-weight:600;letter-spacing:.2px;
  padding:6px 10px;border-radius:8px;background:rgba(0,0,0,.45);border:1px solid var(--line);color:#ffd9de;
}
.copy-icon-btn{
  width:30px;height:30px;padding:0;display:inline-grid;place-items:center;cursor:pointer;border-radius:9px;
  border:1px solid var(--line);background:var(--panel2);color:var(--muted);transition:all .18s var(--ease);flex:0 0 auto;
}
.copy-icon-btn:hover{color:#fff;border-color:var(--red-border);background:var(--red-soft);transform:scale(1.06)}
.copy-icon-btn:active{transform:scale(.94)}
.copy-icon-btn svg{width:14px;height:14px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.type{font-size:10px;font-weight:700;letter-spacing:.6px;padding:4px 9px;border-radius:7px;background:var(--panel3);border:1px solid var(--line);color:#fff}
.status{
  display:inline-flex;align-items:center;gap:7px;font-size:10.5px;font-weight:700;padding:4px 10px 4px 9px;border-radius:99px;
  border:1px solid var(--line);color:var(--muted);background:var(--panel2);
}
.status::before{content:"";width:6px;height:6px;border-radius:50%;background:currentColor;box-shadow:0 0 8px currentColor}
.status.active{color:var(--green);background:var(--green-soft);border-color:rgba(61,220,151,.3)}
.status.paused,.status.expired{color:var(--red);background:var(--red-soft);border-color:var(--red-border)}
.dots{width:32px;height:32px;border-radius:9px;border:1px solid var(--line);background:var(--panel2);color:#fff;font-size:16px;cursor:pointer;transition:all .18s var(--ease)}
.dots:hover{border-color:var(--red-border);background:var(--red-soft);transform:rotate(90deg)}
.blank{padding:60px 16px!important;text-align:center;color:var(--muted);font-size:12.5px;font-weight:500;white-space:normal!important}

.view{display:none}
.view.active{display:block;animation:viewIn .35s var(--ease)}
@keyframes viewIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:none}}

.modal-bg{
  position:fixed;inset:0;z-index:20;display:none;align-items:center;justify-content:center;padding:16px;
  background:rgba(3,3,6,.72);backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);
}
.modal-bg.open{display:flex;animation:fade .2s ease}
.modal{
  width:min(500px,100%);max-height:90vh;overflow-y:auto;padding:22px;border-radius:18px;
  background:linear-gradient(180deg,#171722,#111119);border:1px solid var(--line-strong);
  box-shadow:0 40px 90px -20px rgba(0,0,0,.9),0 0 0 1px rgba(255,61,87,.06);animation:pop .28s var(--ease);
}
@keyframes fade{from{opacity:0}}
@keyframes pop{from{opacity:0;transform:translateY(14px) scale(.97)}}
.modal-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
.modal-top h2{margin:0;font-size:16px;font-weight:800;letter-spacing:-.2px}
.x{width:32px;height:32px;border-radius:9px;border:1px solid var(--line);background:var(--panel2);color:var(--muted);font-size:18px;line-height:1;cursor:pointer;transition:all .18s}
.x:hover{color:#fff;border-color:var(--red-border);background:var(--red-soft)}
.formgrid{display:grid;grid-template-columns:1fr 1fr;gap:13px}
.field{display:flex;flex-direction:column;gap:6px}
.field.full{grid-column:1/-1}
.field label{font-size:11px;color:var(--muted);font-weight:600}
.field input,.field select,.field textarea{
  height:40px;padding:0 12px;border-radius:10px;border:1px solid var(--line);background:rgba(0,0,0,.4);color:#fff;
  font-size:12.5px;font-weight:500;transition:border-color .2s,box-shadow .2s;
}
.field textarea{height:auto;padding:10px 12px}
.field input:focus,.field select:focus,.field textarea:focus{outline:none;border-color:var(--red);box-shadow:0 0 0 4px rgba(255,61,87,.14)}
.field input:disabled{cursor:not-allowed}
.clean-meta{display:flex;flex-direction:column;gap:7px;margin-bottom:14px;padding:12px 14px;border-radius:12px;background:rgba(0,0,0,.35);border:1px solid var(--line);font-size:11.5px;color:var(--muted)}
.clean-meta strong{color:#ffd9de;font-family:'JetBrains Mono',monospace;font-size:11px;font-weight:600;word-break:break-all}
.clean-list{display:flex;flex-direction:column;gap:8px}
.clean-btn{
  width:100%;display:flex;align-items:center;justify-content:space-between;gap:10px;text-align:left;cursor:pointer;
  padding:12px 14px;border-radius:12px;border:1px solid var(--line);background:var(--panel2);color:#fff;
  font-size:12px;font-weight:600;transition:all .18s var(--ease);
}
.clean-btn span:last-child{font-size:10.5px;color:var(--muted);font-weight:600}
.clean-btn:hover{border-color:var(--line-strong);background:var(--panel3);transform:translateX(3px)}
.clean-btn.danger{border-color:var(--red-border);color:var(--red);background:var(--red-soft)}
.clean-btn.danger span:last-child{color:var(--red)}
.clean-btn.danger:hover{background:rgba(255,61,87,.22)}
.clean-row{display:grid;grid-template-columns:1fr 42px;gap:8px;align-items:stretch}
.info-btn{border-radius:12px;border:1px solid var(--line);background:rgba(0,0,0,.4);color:var(--muted);font-family:'JetBrains Mono',monospace;font-size:13px;font-weight:700;cursor:pointer;transition:all .18s}
.info-btn:hover{color:#fff;border-color:var(--red-border);background:var(--red-soft)}
.modal-actions{display:flex;justify-content:flex-end;gap:8px;margin-top:18px;flex-wrap:wrap}
.footnote{margin:12px 0 0;color:var(--muted);font-size:11px;font-weight:500;line-height:1.55}

.toast{
  position:fixed;right:22px;bottom:22px;z-index:40;display:none;padding:12px 18px;border-radius:12px;
  background:rgba(244,244,248,.96);color:#09090d;font-size:12px;font-weight:700;
  box-shadow:0 18px 40px -12px rgba(0,0,0,.7);border-left:4px solid var(--red);
}
.toast.show{display:block;animation:toastIn .3s var(--ease)}
@keyframes toastIn{from{opacity:0;transform:translateY(14px) scale(.96)}}

.settings-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:14px}
.setting-card{padding:20px;border-radius:var(--radius);background:var(--panel);border:1px solid var(--line);backdrop-filter:blur(14px);-webkit-backdrop-filter:blur(14px);transition:border-color .25s,transform .25s var(--ease)}
.setting-card:hover{border-color:var(--line-strong)}
.setting-card h3{margin:0 0 8px;font-size:14.5px;font-weight:800}
.setting-card p{margin:0 0 16px;color:var(--muted);font-size:11.5px;font-weight:500;line-height:1.6}
.switch-row{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-top:10px}
.switch{position:relative;display:inline-block;width:52px;height:28px;flex:0 0 auto}
.switch input{opacity:0;width:0;height:0}
.slider{position:absolute;inset:0;cursor:pointer;border-radius:28px;background:var(--panel3);border:1px solid var(--line-strong);transition:all .25s var(--ease)}
.slider:before{content:"";position:absolute;width:20px;height:20px;left:3px;bottom:3px;border-radius:50%;background:#fff;box-shadow:0 2px 6px rgba(0,0,0,.5);transition:transform .25s var(--ease)}
input:checked + .slider{background:var(--grad);border-color:transparent;box-shadow:0 0 20px -2px rgba(255,61,87,.65)}
input:checked + .slider:before{transform:translateX(24px)}
.update-badge{display:inline-block;margin-top:14px;padding:6px 11px;border-radius:9px;font-family:'JetBrains Mono',monospace;font-size:10.5px;font-weight:700;color:var(--red);background:var(--red-soft);border:1px solid var(--red-border);animation:pulseBadge 2s ease-in-out infinite}
@keyframes pulseBadge{50%{box-shadow:0 0 0 5px rgba(255,61,87,.1)}}

.login-screen{position:relative;z-index:1;min-height:100vh;display:grid;place-items:center;padding:20px}
.login-card{
  width:min(400px,100%);padding:36px 32px;border-radius:22px;position:relative;overflow:hidden;
  background:linear-gradient(180deg,rgba(26,26,38,.85),rgba(14,14,21,.9));border:1px solid var(--line-strong);
  backdrop-filter:blur(24px);-webkit-backdrop-filter:blur(24px);
  box-shadow:0 50px 100px -30px rgba(0,0,0,.9),0 0 80px -30px rgba(255,61,87,.5);animation:pop .5s var(--ease);
}
.login-card::before{content:"";position:absolute;left:-40%;right:-40%;top:-60%;height:80%;background:radial-gradient(closest-side,rgba(255,61,87,.28),transparent);pointer-events:none}
.login-logo{position:relative;width:54px;height:54px;margin-bottom:20px;border-radius:16px;display:grid;place-items:center;color:#fff;background:var(--grad);box-shadow:0 14px 34px -8px rgba(255,61,87,.7),inset 0 1px 0 rgba(255,255,255,.35)}
.login-logo svg{width:26px;height:26px;fill:none;stroke:currentColor;stroke-width:2.2;stroke-linecap:round;stroke-linejoin:round}
.login-card h1{position:relative;margin:0 0 6px;font-size:25px;font-weight:800;letter-spacing:-.5px}
.login-card h1 span{background:var(--grad);-webkit-background-clip:text;background-clip:text;color:transparent}
.login-card p{position:relative;margin:0 0 24px;color:var(--muted);font-size:12px;font-weight:500}
.login-card form{position:relative}
.login-card .field{margin:14px 0}
.login-card .field input{height:46px;font-size:13px}
.login-submit{width:100%;height:46px;margin-top:12px;font-size:13px}
.login-error{min-height:16px;margin-top:8px;color:var(--red);font-size:11.5px;font-weight:600}

@media(max-width:980px){
  .cards{grid-template-columns:repeat(2,minmax(0,1fr))}
}
@media(max-width:720px){
  .rail{
    inset:auto 0 0 0;width:100%;height:62px;flex:none;flex-direction:row;justify-content:space-around;
    padding:0 10px;border-right:0;border-top:1px solid var(--line);
  }
  .rail .logo{display:none}
  .rail button.active::before{left:11px;right:11px;top:-11px;bottom:auto;width:auto;height:3px}
  .main{margin-left:0;width:100%;padding-bottom:76px}
  .topbar{padding:0 14px}
  .content{padding:20px 14px 30px}
  .heading h1{font-size:22px}
  .settings-grid,.formgrid{grid-template-columns:1fr}
  .filters{width:100%}
  .filters input{flex:1 1 100%;width:100%}
  .toast{right:14px;left:14px;bottom:78px;text-align:center}
  .metric strong{font-size:26px}
}
@media(prefers-reduced-motion:reduce){
  *,*::before,*::after{animation:none!important;transition:none!important}
}
</style>
</head>
<body>

<div id="loginScreen" class="login-screen">
  <div class="login-card">
    <div class="login-logo">
      <svg viewBox="0 0 24 24"><path d="M12 2.8 20.5 7.4v9.2L12 21.2l-8.5-4.6V7.4L12 2.8Z"/><path d="m8 12 2.5 2.5L16.5 8.5"/></svg>
    </div>
    <h1>DARKIOS <span>ADMIN</span></h1>
    <p id="loginSub">Administrator Sign In</p>
    <form onsubmit="loginAdmin(event)">
      <div class="field"><label id="lblUser">Username</label><input id="loginUser" autocomplete="username" required placeholder="Username"></div>
      <div class="field"><label id="lblPass">Password</label><input id="loginPass" type="password" autocomplete="current-password" required placeholder="Password"></div>
      <div id="loginError" class="login-error"></div>
      <button class="create login-submit" id="btnSignIn">Sign in</button>
    </form>
  </div>
</div>

<div class="shell" id="adminApp" style="display:none">
  <aside class="rail" id="rail">
    <div class="logo">
      <svg viewBox="0 0 24 24"><path d="M12 2.8 20.5 7.4v9.2L12 21.2l-8.5-4.6V7.4L12 2.8Z"/><path d="m8 12 2.5 2.5L16.5 8.5"/></svg>
    </div>
    <button class="active" title="API Keys" data-view="api">
      <svg viewBox="0 0 24 24"><circle cx="8" cy="15.5" r="3.5"/><path d="m10.5 13 8-8 2 2-2 2 1.5 1.5-2 2-1.5-1.5-3 3"/></svg>
    </button>
    <button title="Key Generator" data-view="generator">
      <svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
    </button>
    <button title="Banned Keys" data-view="banned">
      <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="m5.6 5.6 12.8 12.8"/></svg>
    </button>
    <button title="Settings" data-view="settings">
      <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09a1.65 1.65 0 0 0-1-1.51 1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09a1.65 1.65 0 0 0 1.51-1 1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9c.26.6.77 1.02 1.4 1.14H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1Z"/></svg>
    </button>
  </aside>

  <div class="main">
    <header class="topbar">
      <div class="top-left"><span class="dot"></span><span id="topTitle">API Keys</span></div>
      <div class="top-right">
        <select class="top-select" id="langSelect" onchange="setLang(this.value)">
          <option value="en">English</option>
          <option value="tr">Türkçe</option>
        </select>
        <button class="top-btn" onclick="pullFromServer(true)" id="btnRefresh">Refresh</button>
        <button class="top-btn" onclick="logoutAdmin()" id="btnLogout">Sign out</button>
      </div>
    </header>

    <main class="content">
      <section class="view active" id="view-api">
        <div class="heading">
          <div>
            <h1 id="h1Api">API Keys</h1>
            <p id="subApi">Manage and monitor generated keys</p>
          </div>
          <button class="create" onclick="openCreate()" id="btnCreateTop">＋ Create API Key</button>
        </div>

        <div class="cards">
          <div class="metric"><div class="label">Total Keys</div><strong id="mTotal">0</strong></div>
          <div class="metric"><div class="label">Active</div><strong id="mActive">0</strong></div>
          <div class="metric"><div class="label">Tester Keys</div><strong id="mService">0</strong></div>
          <div class="metric accent"><div class="label">Banned Keys</div><strong id="mBanned">0</strong></div>
        </div>

        <div class="table-panel">
          <div class="table-head">
            <div class="table-title"><span id="tblTitle">API Key List</span> <span class="count" id="rowCount">0 keys</span></div>
            <div class="filters">
              <input id="search" placeholder="Search name or key..." oninput="renderRows()">
              <select id="statusFilter" onchange="renderRows()">
                <option value="">Status</option>
                <option value="Active">Active</option>
                <option value="Paused">Paused</option>
                <option value="Expired">Expired</option>
              </select>
              <select id="typeFilter" onchange="renderRows()">
                <option value="">Type</option>
                <option value="NORMAL">NORMAL</option>
                <option value="TESTER">TESTER</option>
              </select>
              <button class="reset" onclick="resetFilters()" id="btnReset">Reset</button>
            </div>
          </div>
          <div class="table-wrap">
            <table class="table">
              <thead>
                <tr>
                  <th>NAME</th>
                  <th>KEY</th>
                  <th>TYPE</th>
                  <th>STATUS</th>
                  <th>DEVICES</th>
                  <th>TIME LEFT</th>
                  <th>CREATED</th>
                  <th>ACTIONS</th>
                </tr>
              </thead>
              <tbody id="rows"></tbody>
            </table>
          </div>
        </div>
      </section>

      <section class="view" id="view-generator">
        <div class="heading">
          <div>
            <h1 id="h1Gen">Key Generator</h1>
            <p id="subGen">Format: DARKIOS-1MONTH-XXXXXXXXXXXXXXXX / DARKIOS-TESTER-1MONTH-XXXXXXXXXXXXXXXX</p>
          </div>
        </div>
        <div class="table-panel" style="padding:20px">
          <div class="formgrid">
            <div class="field"><label>Name (optional)</label><input id="genName" placeholder="Optional"></div>
            <div class="field"><label>Key type</label><select id="genType"><option value="NORMAL">NORMAL</option><option value="TESTER">TESTER</option></select></div>
            <div class="field"><label>Max IP / Devices</label><select id="genDevices"><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="5">5</option><option value="0">Unlimited</option></select></div>
            <div class="field"><label>Validity unit</label><select id="genDurationUnit" onchange="toggleGenDuration()"><option value="HOUR">Hours (1HOUR)</option><option value="DAY" selected>Days (1DAY)</option><option value="WEEK">Weeks (1WEEK)</option><option value="MONTH">Months (1MONTH)</option><option value="YEAR">Years (1YEAR)</option><option value="LIFETIME">Lifetime</option></select></div>
            <div class="field"><label>Duration amount</label><input id="genDurationValue" type="number" min="1" value="1"></div>
            <div class="field"><label>Key prefix</label><input id="genPrefix" value="DARKIOS"></div>
            <div class="field"><label>Custom key (exact value)</label><input id="genCustomKey" placeholder="Optional exact key"></div>
            <div class="field"><label>How many keys</label><input id="genCount" type="number" min="1" max="100" value="1"></div>
            <div class="field full"><label>Description (optional)</label><input id="genDesc" placeholder="Optional"></div>
          </div>
          <button class="create" style="margin-top:18px" onclick="generateKeys()">Generate API Key(s)</button>
          <div id="generated" style="margin-top:16px"></div>
        </div>
      </section>

      <section class="view" id="view-banned">
        <div class="heading">
          <div>
            <h1 id="h1Ban">Banned Keys</h1>
            <p id="subBan">Blocked keys list</p>
          </div>
          <button class="create" onclick="openBan()">＋ Ban key</button>
        </div>
        <div class="table-panel">
          <div class="table-wrap">
            <table class="table">
              <thead><tr><th>KEY</th><th>REASON</th><th>DATE</th><th>ACTION</th></tr></thead>
              <tbody id="bannedRows"></tbody>
            </table>
          </div>
        </div>
      </section>

      <section class="view" id="view-settings">
        <div class="heading">
          <div>
            <h1 id="h1Set">Settings</h1>
            <p id="subSet">System controls, UPDATE switch and backup</p>
          </div>
        </div>
        <div class="settings-grid">
          <div class="setting-card" style="border-color:var(--red-border)">
            <h3>UPDATE!!!</h3>
            <p id="updateDesc">When ON, pauses all active keys. When OFF, restores only keys paused by UPDATE!!! (manually paused keys stay paused).</p>
            <div class="switch-row">
              <span id="updateStatusText" style="font-size:13px;font-weight:800">OFF</span>
              <label class="switch">
                <input type="checkbox" id="updateToggle" onchange="toggleUpdateMode(this.checked)">
                <span class="slider"></span>
              </label>
            </div>
            <div id="updateBadgeWrap"></div>
          </div>

          <div class="setting-card">
            <h3>Backup & Export</h3>
            <p>Export keys to TXT or JSON backup.</p>
            <button class="secondary" onclick="exportTxt()">Download keys.txt</button>
            <button class="secondary" onclick="backupJson()">Download JSON</button>
          </div>

          <div class="setting-card">
            <h3>Import Keys</h3>
            <p>Import keys from TXT or restore JSON.</p>
            <label class="secondary" style="display:inline-block">Import TXT<input type="file" accept=".txt,text/plain" hidden onchange="importTxt(this.files[0]);this.value=''"></label>
            <label class="secondary" style="display:inline-block">Restore JSON<input type="file" accept=".json" hidden onchange="restoreJson(this.files[0])"></label>
          </div>

          <div class="setting-card">
            <h3>Reset All Keys</h3>
            <p>Delete all keys and active device sessions.</p>
            <button class="secondary danger" onclick="clearAllKeys()">Clear all keys</button>
          </div>
        </div>
      </section>
    </main>
  </div>
</div>

<div class="modal-bg" id="modalBg">
  <div class="modal">
    <div class="modal-top"><h2 id="modalTitle">Action</h2><button class="x" onclick="closeModal()">×</button></div>
    <div id="modalBody"></div>
  </div>
</div>
<div class="toast" id="toast"></div>

<script>
const $=s=>document.querySelector(s),uid=()=>Math.random().toString(36).slice(2,10)+Date.now().toString(36).slice(-4);
const RANDOM_TOKEN_LEN = 16;
const SERVER_INITIAL = <?php echo json_encode($initialStore, JSON_UNESCAPED_UNICODE); ?>;

let records=Array.isArray(SERVER_INITIAL.records)?SERVER_INITIAL.records:[];
let banned=Array.isArray(SERVER_INITIAL.banned)?SERVER_INITIAL.banned:[];
let deviceSessions=Array.isArray(SERVER_INITIAL.devices)?SERVER_INITIAL.devices:[];
let updateModeOn=typeof SERVER_INITIAL.updateModeOn==='boolean'?SERVER_INITIAL.updateModeOn:false;
let currentLang=localStorage.getItem('darkios_lang_v4')||'en';
let isSyncingFromServer=false;

(function hydrateFromLocalIfNeeded(){
  try{
    const localRecs=JSON.parse(localStorage.getItem('darkios_keys_v4')||'[]');
    const deletedSet=new Set((Array.isArray(SERVER_INITIAL.deletedIds)?SERVER_INITIAL.deletedIds:[]).map(String));
    const bannedSet=new Set(banned.map(b=>String(b.key||'').toLowerCase()));
    if(Array.isArray(localRecs)&&localRecs.length>0){
      const existingKeys=new Set(records.map(r=>String(r.key||'').toLowerCase()));
      let added=0;
      localRecs.forEach(lr=>{
        const kLower=String(lr?.key||'').toLowerCase();
        if(lr&&lr.key&&!deletedSet.has(String(lr.id||''))&&!bannedSet.has(kLower)&&!existingKeys.has(kLower)){
          records.push(lr);
          existingKeys.add(kLower);
          added++;
        }
      });
      if(added>0)setTimeout(()=>pushToServer('merge'),300);
    }
  }catch{}
})();

const i18n={
  en:{
    api:'API Keys',generator:'Key Generator',banned:'Banned Keys',settings:'Settings',
    subApi:'Manage and monitor generated keys',
    subGen:'Format: DARKIOS-1MONTH-XXXXXXXXXXXXXXXX / DARKIOS-TESTER-1MONTH-XXXXXXXXXXXXXXXX',
    subBan:'Blocked keys list',subSet:'System controls, UPDATE switch and backup',
    create:'＋ Create API Key',refresh:'Refresh',logout:'Sign out',reset:'Reset',
    noKeys:'No keys yet. Click "+ Create API Key" to create one.',
    waitingDevice:'Waiting Device',expired:'Expired',
    pausedManual:'Paused (Manual)',pausedTemp:'Paused (Temp)',pausedUpdate:'Paused (UPDATE!!!)',
    loginSub:'Administrator Sign In',user:'Username',pass:'Password',signIn:'Sign in',
    badLogin:'Invalid username or password',
    updateOnDesc:'UPDATE!!! is ON: active keys are paused with reason UPDATE!!!',
    updateOffDesc:'When ON, pauses all active keys. When OFF, restores only keys paused by UPDATE!!! (manually paused keys stay paused).'
  },
  tr:{
    api:'API Anahtarları',generator:'Anahtar Oluşturucu',banned:'Yasaklı Anahtarlar',settings:'Ayarlar',
    subApi:'Oluşturulan anahtarları yönetin ve izleyin',
    subGen:'Format: DARKIOS-1MONTH-XXXXXXXXXXXXXXXX / DARKIOS-TESTER-1MONTH-XXXXXXXXXXXXXXXX',
    subBan:'Engellenen anahtarlar listesi',subSet:'Sistem kontrolleri, UPDATE anahtarı ve yedekleme',
    create:'＋ API Anahtarı Oluştur',refresh:'Yenile',logout:'Çıkış yap',reset:'Sıfırla',
    noKeys:'Henüz anahtar yok. Oluşturmak için "+ API Anahtarı Oluştur" butonuna basın.',
    waitingDevice:'Cihaz Bekleniyor',expired:'Süresi Doldu',
    pausedManual:'Durduruldu (Manuel)',pausedTemp:'Durduruldu (Geçici)',pausedUpdate:'Durduruldu (UPDATE!!!)',
    loginSub:'Yönetici Girişi',user:'Kullanıcı Adı',pass:'Şifre',signIn:'Giriş Yap',
    badLogin:'Kullanıcı adı veya şifre hatalı',
    updateOnDesc:'UPDATE!!! AÇIK: aktif anahtarlar UPDATE!!! sebebiyle durduruldu',
    updateOffDesc:'Açıldığında tüm aktif anahtarları durdurur. Kapatıldığında yalnızca UPDATE!!! ile durdurulanları geri açar (manuel durdurulanlar durur).'
  }
};
const t=k=>(i18n[currentLang]||i18n.en)[k]||i18n.en[k]||k;

function setLang(lang){
  currentLang=i18n[lang]?lang:'en';
  localStorage.setItem('darkios_lang_v4',currentLang);
  applyLang();
  renderAll();
}
function applyLang(){
  document.documentElement.lang=currentLang;
  $('#langSelect').value=currentLang;
  $('#loginSub').textContent=t('loginSub');
  $('#lblUser').textContent=t('user');
  $('#lblPass').textContent=t('pass');
  $('#btnSignIn').textContent=t('signIn');
  $('#btnRefresh').textContent=t('refresh');
  $('#btnLogout').textContent=t('logout');
  $('#h1Api').textContent=t('api');
  $('#subApi').textContent=t('subApi');
  $('#btnCreateTop').textContent=t('create');
  $('#tblTitle').textContent=t('api');
  $('#btnReset').textContent=t('reset');
  $('#h1Gen').textContent=t('generator');
  $('#subGen').textContent=t('subGen');
  $('#h1Ban').textContent=t('banned');
  $('#subBan').textContent=t('subBan');
  $('#h1Set').textContent=t('settings');
  $('#subSet').textContent=t('subSet');
  const activeView=document.querySelector('.view.active')?.id.replace('view-','')||'api';
  $('#topTitle').textContent=t(activeView);
}

function saveLocalCache(){
  try{
    localStorage.setItem('darkios_keys_v4',JSON.stringify(records));
    localStorage.setItem('darkios_banned_v4',JSON.stringify(banned));
    localStorage.setItem('darkios_devices_v4',JSON.stringify(deviceSessions));
    localStorage.setItem('darkios_update_mode_v4',JSON.stringify(updateModeOn));
  }catch{}
}

function safeParseJsonText(raw){
  if(typeof raw!=='string')return null;
  const trimmed=raw.trim();
  if(!trimmed)return null;
  const start=trimmed.search(/[\{\[]/);
  if(start===-1)return null;
  try{return JSON.parse(trimmed.slice(start))}catch{return null}
}

async function pushToServer(action='merge',extra={}){
  if(isSyncingFromServer)return;
  try{
    const res=await fetch('?sync=1',{
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({
        action,
        records,
        banned,
        devices:deviceSessions,
        updateModeOn:!!updateModeOn,
        ...extra
      })
    });
    const txt=await res.text();
    const json=safeParseJsonText(txt);
    if(res.ok&&json&&json.status==='ok'&&json.data){
      isSyncingFromServer=true;
      if(Array.isArray(json.data.records))records=json.data.records;
      if(Array.isArray(json.data.banned))banned=json.data.banned;
      if(Array.isArray(json.data.devices))deviceSessions=json.data.devices;
      if(typeof json.data.updateModeOn==='boolean')updateModeOn=json.data.updateModeOn;
      saveLocalCache();
      renderAll();
      isSyncingFromServer=false;
    }
  }catch{
    isSyncingFromServer=false;
  }
}

function persist(action='merge',extra={}){
  saveLocalCache();
  pushToServer(action,extra);
}

async function pullFromServer(showToast=false){
  try{
    const res=await fetch('?sync=1&_='+Date.now(),{cache:'no-store'});
    const txt=await res.text();
    const json=safeParseJsonText(txt);
    if(res.ok&&json&&json.status==='ok'&&json.data){
      isSyncingFromServer=true;
      if(Array.isArray(json.data.records))records=json.data.records;
      if(Array.isArray(json.data.banned))banned=json.data.banned;
      if(Array.isArray(json.data.devices))deviceSessions=json.data.devices;
      if(typeof json.data.updateModeOn==='boolean')updateModeOn=json.data.updateModeOn;
      saveLocalCache();
      renderAll();
      isSyncingFromServer=false;
      if(showToast)notify('Synced');
    }
  }catch{
    isSyncingFromServer=false;
  }
}

function notify(msg){
  let el=$('#toast');el.textContent=msg;el.classList.add('show');
  setTimeout(()=>el.classList.remove('show'),2200);
}
function esc(s){return String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}
const COPY_ICON_SVG='<svg viewBox="0 0 24 24"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>';
function copyTextValue(val){
  const text=String(val??'');
  if(!text)return;
  if(navigator.clipboard&&window.isSecureContext){
    navigator.clipboard.writeText(text).then(()=>notify('Copied')).catch(()=>fallbackCopyText(text));
  }else{
    fallbackCopyText(text);
  }
}
function fallbackCopyText(text){
  const ta=document.createElement('textarea');
  ta.value=text;ta.style.position='fixed';ta.style.opacity='0';
  document.body.appendChild(ta);ta.focus();ta.select();
  try{document.execCommand('copy');notify('Copied')}catch{}
  document.body.removeChild(ta);
}

function go(v){
  document.querySelectorAll('.view').forEach(x=>x.classList.remove('active'));
  $('#view-'+v).classList.add('active');
  document.querySelectorAll('.rail button').forEach(x=>x.classList.toggle('active',x.dataset.view===v));
  $('#topTitle').textContent=t(v);
  renderAll();
}
$('#rail').addEventListener('click',e=>{let b=e.target.closest('button[data-view]');if(b)go(b.dataset.view)});

function loginAdmin(e){
  e.preventDefault();
  if($('#loginUser').value==='dark'&&$('#loginPass').value==='wear5555'){
    sessionStorage.setItem('darkios_auth','1');
    $('#loginScreen').style.display='none';
    $('#adminApp').style.display='flex';
    $('#loginError').textContent='';
    pullFromServer(false);
    notify('OK');
  }else{
    $('#loginError').textContent=t('badLogin');
  }
}
function logoutAdmin(){
  sessionStorage.removeItem('darkios_auth');
  $('#adminApp').style.display='none';
  $('#loginScreen').style.display='grid';
  $('#loginPass').value='';
}

function durationToMs(unit,val){
  if(unit==='LIFETIME')return null;
  let n=Math.max(1,+val||1);
  if(unit==='HOUR')return n*3600000;
  if(unit==='DAY')return n*86400000;
  if(unit==='WEEK')return n*604800000;
  if(unit==='MONTH')return n*2592000000;
  if(unit==='YEAR')return n*31536000000;
  return n*86400000;
}

function buildDurationSegment(unit,val){
  if(unit==='LIFETIME')return 'LIFETIME';
  const n=Math.max(1,+val||1);
  const singular={HOUR:'HOUR',DAY:'DAY',WEEK:'WEEK',MONTH:'MONTH',YEAR:'YEAR'}[unit]||'DAY';
  const plural={HOUR:'HOURS',DAY:'DAYS',WEEK:'WEEKS',MONTH:'MONTHS',YEAR:'YEARS'}[unit]||'DAYS';
  return `${n}${n===1?singular:plural}`;
}

function randomAlphaNum(len=RANDOM_TOKEN_LEN){
  const chars='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let out='';
  const bytes=new Uint8Array(len);
  crypto.getRandomValues(bytes);
  for(let i=0;i<len;i++)out+=chars[bytes[i]%chars.length];
  return out;
}

function buildKeyValue({type,prefix,unit,val,customKey}){
  const ck=(customKey||'').trim();
  if(ck)return ck;
  const p=((prefix||'DARKIOS').trim()||'DARKIOS').toUpperCase();
  const dur=buildDurationSegment(unit,val);
  const token=randomAlphaNum(RANDOM_TOKEN_LEN);
  return type==='TESTER'
    ? `${p}-TESTER-${dur}-${token}`
    : `${p}-${dur}-${token}`;
}

function checkStates(){
  let changed=false;
  const now=Date.now();
  records.forEach(r=>{
    if(r.pauseType==='temp' && r.pauseUntil && r.pauseUntil<=now){
      r.pauseType=null;r.pauseUntil=null;r.status='Active';r.modifiedAt=now;changed=true;
    }
    if(r.startedAt && r.durationMs && r.status==='Active'){
      if((r.startedAt+r.durationMs)<=now){
        r.status='Expired';r.modifiedAt=now;changed=true;
      }
    }
  });
  if(changed)persist('merge');
}

function timeLeftText(r){
  if(!r.durationMs)return 'LIFETIME';
  if(!r.startedAt)return t('waitingDevice');
  const rem=(r.startedAt+r.durationMs)-Date.now();
  if(rem<=0)return t('expired');
  let s=Math.floor(rem/1000);
  let d=Math.floor(s/86400);s%=86400;
  let h=Math.floor(s/3600);s%=3600;
  let m=Math.floor(s/60);s%=60;
  return `${d}d ${h}h ${m}m ${s}s`;
}

function statusBadgeText(r){
  if(r.status==='Paused'){
    if(r.pauseType==='update')return t('pausedUpdate');
    if(r.pauseType==='temp')return t('pausedTemp');
    return t('pausedManual');
  }
  if(r.status==='Expired')return t('expired');
  return 'Active';
}

function renderRows(){
  checkStates();
  let q=$('#search').value.toLowerCase(),st=$('#statusFilter').value,ty=$('#typeFilter').value;
  let arr=records.filter(r=>(!q||(r.name||'').toLowerCase().includes(q)||r.key.toLowerCase().includes(q))&&(!st||r.status===st)&&(!ty||r.type===ty));
  $('#rowCount').textContent=arr.length+' keys';
  $('#rows').innerHTML=arr.map(r=>{
    let active=deviceSessions.filter(d=>d.keyId===r.id&&d.status==='Active').length;
    let limit=r.deviceLimit===0?'∞':(r.deviceLimit||1);
    let cls=r.status==='Active'?'active':(r.status==='Paused'||r.status==='Expired'?'paused':'');
    return `<tr>
      <td><div class="name">${esc(r.name||'Key')}</div><div class="desc">${esc(r.description||'—')}</div></td>
      <td><div class="key-cell"><button type="button" class="copy-icon-btn" title="Copy" onclick="copyKey('${r.id}')">${COPY_ICON_SVG}</button><span class="keycode">${esc(r.key)}</span></div></td>
      <td><span class="type">${esc(r.type||'NORMAL')}</span></td>
      <td><span class="status ${cls}">${esc(statusBadgeText(r))}</span></td>
      <td>${active} / ${limit}</td>
      <td>${esc(timeLeftText(r))}</td>
      <td>${esc(r.created||'')}</td>
      <td><button class="dots" onclick="rowMenu('${r.id}')">⋮</button></td>
    </tr>`;
  }).join('')||`<tr><td colspan="8" class="blank">${esc(t('noKeys'))}</td></tr>`;

  $('#mTotal').textContent=records.length;
  $('#mActive').textContent=records.filter(r=>r.status==='Active').length;
  $('#mService').textContent=records.filter(r=>r.type==='TESTER').length;
  $('#mBanned').textContent=banned.length;
}

function renderUpdateUI(){
  $('#updateToggle').checked=!!updateModeOn;
  $('#updateStatusText').textContent=updateModeOn?'ON':'OFF';
  $('#updateStatusText').style.color=updateModeOn?'var(--red)':'#fff';
  $('#updateDesc').textContent=updateModeOn?t('updateOnDesc'):t('updateOffDesc');
  const countUpdatePaused=records.filter(r=>r.status==='Paused'&&r.pauseType==='update').length;
  $('#updateBadgeWrap').innerHTML=updateModeOn
    ?`<div class="update-badge">UPDATE!!! ACTIVE · ${countUpdatePaused} key(s) paused</div>`
    :'';
}

function toggleUpdateMode(checked){
  const now=Date.now();
  if(checked){
    updateModeOn=true;
    let pausedCount=0;
    records.forEach(r=>{
      if(r.status==='Active'){
        r.status='Paused';r.pauseType='update';r.pauseUntil=null;r.modifiedAt=now;pausedCount++;
      }
    });
    persist('merge');renderAll();notify(`UPDATE!!! ON (${pausedCount})`);
  }else{
    updateModeOn=false;
    let restoredCount=0;
    records.forEach(r=>{
      if(r.status==='Paused'&&r.pauseType==='update'){
        r.pauseType=null;r.pauseUntil=null;
        r.status=(r.startedAt&&r.durationMs&&(r.startedAt+r.durationMs<=now))?'Expired':'Active';
        r.modifiedAt=now;restoredCount++;
      }
    });
    persist('merge');renderAll();notify(`UPDATE!!! OFF (${restoredCount})`);
  }
}

function resetFilters(){$('#search').value='';$('#statusFilter').value='';$('#typeFilter').value='';renderRows()}
function modal(title,body){$('#modalTitle').textContent=title;$('#modalBody').innerHTML=body;$('#modalBg').classList.add('open')}
function closeModal(){$('#modalBg').classList.remove('open')}

function showTurkishInfo(topic){
  const infos={
    addTime:{title:'Zaman Ekleme (+)',text:'Seçili anahtarın süresine istediğin miktarda dakika, saat veya gün ekler.'},
    subTime:{title:'Zaman Çıkarma (-)',text:'Seçili anahtarın kalan süresinden girdiğin miktarda dakika, saat veya gün düşürür.'},
    addDevice:{title:'Cihaz Sınırı Ekleme (+)',text:'Anahtara bağlanabilecek maksimum cihaz/IP sayısını girdiğin sayı kadar artırır.'},
    subDevice:{title:'Cihaz Sınırı Çıkarma (-)',text:'Anahtarın maksimum cihaz/IP limitini girdiğin sayı kadar azaltır (en az 1 kalır).'}
  };
  const info=infos[topic]||{title:'Bilgi',text:'İşlem açıklaması.'};
  modal(info.title,`<p class="footnote" style="font-size:12px;color:#fff;margin-top:0">${esc(info.text)}</p>
    <div class="modal-actions"><button class="create" onclick="closeModal()">Tamam</button></div>`);
}

function openCreate(){
  modal('Create API Key',`<form onsubmit="createRecord(event)">
    <div class="formgrid">
      <div class="field"><label>Name (optional)</label><input id="newName" placeholder="Optional"></div>
      <div class="field"><label>Key type</label><select id="newType"><option value="NORMAL">NORMAL</option><option value="TESTER">TESTER</option></select></div>
      <div class="field"><label>Max IP / Devices</label><select id="newDeviceLimit"><option value="1">1</option><option value="2">2</option><option value="3">3</option><option value="5">5</option><option value="0">Unlimited</option></select></div>
      <div class="field"><label>Validity unit</label><select id="newDurationUnit" onchange="toggleModalDuration()"><option value="HOUR">Hours (1HOUR)</option><option value="DAY" selected>Days (1DAY)</option><option value="WEEK">Weeks (1WEEK)</option><option value="MONTH">Months (1MONTH)</option><option value="YEAR">Years (1YEAR)</option><option value="LIFETIME">Lifetime</option></select></div>
      <div class="field"><label>Duration amount</label><input id="newDurationValue" type="number" min="1" value="1"></div>
      <div class="field"><label>Key prefix</label><input id="newPrefix" value="DARKIOS"></div>
      <div class="field full"><label>Custom key (exact value)</label><input id="newCustomKey" placeholder="Optional exact key"></div>
      <div class="field full"><label>Description (optional)</label><input id="newDesc" placeholder="Optional"></div>
    </div>
    <p class="footnote">Countdown starts only when the first device connects.</p>
    <div class="modal-actions">
      <button type="button" class="secondary" onclick="closeModal()">Cancel</button>
      <button class="create">Create API Key</button>
    </div>
  </form>`);
}
function toggleModalDuration(){
  const life=$('#newDurationUnit').value==='LIFETIME';
  $('#newDurationValue').disabled=life;$('#newDurationValue').style.opacity=life?'.4':'1';
}
function toggleGenDuration(){
  const life=$('#genDurationUnit').value==='LIFETIME';
  $('#genDurationValue').disabled=life;$('#genDurationValue').style.opacity=life?'.4':'1';
}

function createRecord(e){
  e.preventDefault();
  const type=$('#newType').value,unit=$('#newDurationUnit').value,val=$('#newDurationValue').value;
  const prefix=$('#newPrefix').value,customKey=$('#newCustomKey').value;
  const name=($('#newName').value||'').trim()||'Key',desc=($('#newDesc').value||'').trim()||'—';
  const durationMs=durationToMs(unit,val),now=Date.now();

  const r={
    id:uid(),name,description:desc,type,
    status:updateModeOn?'Paused':'Active',
    pauseType:updateModeOn?'update':null,pauseUntil:null,
    deviceLimit:+($('#newDeviceLimit').value||1),
    created:new Date().toISOString().slice(0,16).replace('T',' '),
    modifiedAt:now,key:buildKeyValue({type,prefix,unit,val,customKey}),
    durationMs,startedAt:null
  };
  records.unshift(r);persist('merge');closeModal();renderAll();notify('OK');
  modal('Key Created',`<div class="key-cell" style="width:100%"><button type="button" class="copy-icon-btn" style="width:40px;height:40px;flex:0 0 40px" title="Copy" onclick="copyTextValue($('#createdKey').value)">${COPY_ICON_SVG}</button><input style="width:100%;height:40px;background:rgba(0,0,0,.45);color:#ffd9de;border:1px solid rgba(255,255,255,.1);padding:0 12px;border-radius:10px;font-family:'JetBrains Mono',monospace;font-size:12px" id="createdKey" value="${esc(r.key)}" readonly></div>
    <div class="modal-actions">
      <button class="secondary" onclick="copyTextValue($('#createdKey').value)">Copy</button>
      <button class="create" onclick="closeModal()">Done</button>
    </div>`);
}

function openDeviceInfoModal(keyId){
  const r=records.find(x=>x.id===keyId);
  if(!r)return;
  const list=deviceSessions.filter(d=>d.keyId===keyId);
  modal(`Real Devices (${list.length})`,`
    <div class="clean-meta">
      <div><strong>${esc(r.key)}</strong></div>
      <div>Connected real devices: <span>${list.length}</span></div>
    </div>
    <div class="field" style="margin-bottom:10px">
      <label>Cihaz axtarışı (model, IP, iOS, şəhər, HWID, batareya)</label>
      <input id="devSearchInput" placeholder="Məs: iPhone 16 Pro, 185., iOS 26..." oninput="filterDeviceList()">
    </div>
    <div id="devInfoList" class="clean-list"></div>
    <div class="modal-actions">
      <button class="secondary" onclick="rowMenu('${keyId}')">Back</button>
    </div>
  `);
  window.__currentKeyDevices=list;
  renderFilteredDevices(list);
}

function filterDeviceList(){
  const q=($('#devSearchInput')?.value||'').trim().toLowerCase();
  const all=window.__currentKeyDevices||[];
  const filtered=!q?all:all.filter(d=>Object.values(d).some(v=>String(v??'').toLowerCase().includes(q)));
  renderFilteredDevices(filtered);
}

function renderFilteredDevices(list){
  const wrap=$('#devInfoList');
  if(!wrap)return;
  if(!list.length){
    wrap.innerHTML=`<div class="blank">Bu key ilə daxil olan cihaz tapılmadı.</div>`;
    return;
  }
  wrap.innerHTML=list.map((d,i)=>`
    <button type="button" class="clean-btn" onclick="showSingleDeviceDetails(${i})">
      <span><strong>${esc(d.deviceModel||'Device')}</strong> · ${esc(d.battery||'—')} · ${esc(d.iosVersion||'—')}</span>
      <span>${esc(d.ip||'—')}</span>
    </button>
  `).join('');
  window.__filteredDevices=list;
}

function showSingleDeviceDetails(index){
  const d=(window.__filteredDevices||[])[index];
  if(!d)return;
  const rows=[
    ['Public IP Address',d.ip],
    ['Location',d.location],
    ['ISP / Provider',d.isp],
    ['ASN',d.asn],
    ['VPN / Proxy',d.vpnActive],
    ['Network Type',d.network],
    ['Carrier',d.carrier],
    ['Local IP',d.localIp],
    ['Device Model',d.deviceModel],
    ['Machine ID',d.machineId],
    ['Device Name',d.deviceName],
    ['iOS Version',d.iosVersion],
    ['System Name',d.systemName],
    ['Battery Level',d.battery],
    ['Battery State',d.batteryState],
    ['Low Power Mode',d.lowPowerMode],
    ['HWID',d.hwid],
    ['Architecture',d.architecture],
    ['CPU Cores',d.cpuCores],
    ['Total RAM',d.ramTotal],
    ['Used RAM',d.ramUsed],
    ['Total Storage',d.storageTotal],
    ['Free Storage',d.storageFree],
    ['Screen Resolution',d.screenRes],
    ['Refresh Rate',d.refreshRate],
    ['Brightness',d.brightness],
    ['Timezone',d.timezone],
    ['Locale',d.locale],
    ['Uptime',d.uptime],
    ['Bundle ID',d.bundleId],
    ['App Version',d.appVersion],
    ['Jailbreak Status',d.jailbreakStatus],
    ['Last Seen',d.at]
  ];
  modal(`${d.deviceModel||'Device'} — Info`,`
    <div class="clean-meta">
      ${rows.map(([k,v])=>`<div><span>${esc(k)}:</span> <strong>${esc(v??'—')}</strong></div>`).join('')}
    </div>
    <div class="modal-actions">
      <button class="create" onclick="closeModal()">Close</button>
    </div>
  `);
}

function rowMenu(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  const limitText=r.deviceLimit===0?'Unlimited':(r.deviceLimit||1);
  modal('Key Actions',`
    <div class="clean-meta">
      <div><strong>${esc(r.key)}</strong></div>
      <div>Status: <span>${esc(statusBadgeText(r))}</span> · Limit: <span>${esc(limitText)}</span> · Time: <span>${esc(timeLeftText(r))}</span></div>
    </div>

    <div class="clean-list">
      <button class="clean-btn" onclick="copyKey('${id}')"><span>Copy Key</span><span>Copy</span></button>
      <button class="clean-btn" onclick="openDeviceInfoModal('${id}')"><span>Device Info & Search</span><span>Info</span></button>

      <div class="clean-row">
        <button class="clean-btn" onclick="customTimeModal('${id}','add')"><span>+ Add Custom Time</span><span>Custom</span></button>
        <button class="info-btn" title="Info" onclick="showTurkishInfo('addTime')">i</button>
      </div>

      <div class="clean-row">
        <button class="clean-btn" onclick="customTimeModal('${id}','sub')"><span>- Remove Custom Time</span><span>Custom</span></button>
        <button class="info-btn" title="Info" onclick="showTurkishInfo('subTime')">i</button>
      </div>

      <div class="clean-row">
        <button class="clean-btn" onclick="customDeviceModal('${id}','add')"><span>+ Add Custom Device Limit</span><span>Custom</span></button>
        <button class="info-btn" title="Info" onclick="showTurkishInfo('addDevice')">i</button>
      </div>

      <div class="clean-row">
        <button class="clean-btn" onclick="customDeviceModal('${id}','sub')"><span>- Remove Custom Device Limit</span><span>Custom</span></button>
        <button class="info-btn" title="Info" onclick="showTurkishInfo('subDevice')">i</button>
      </div>

      ${r.status==='Paused'
        ? `<button class="clean-btn" onclick="resumeKey('${id}')"><span>Resume Key</span><span>Active</span></button>`
        : `<button class="clean-btn" onclick="pauseIndefinite('${id}')"><span>Pause Key (Manual)</span><span>Stop</span></button>
           <button class="clean-btn" onclick="pauseTimedModal('${id}')"><span>Pause Key (Timed)</span><span>Timer</span></button>`
      }

      <button class="clean-btn danger" onclick="banRecord('${id}')"><span>Ban Key</span><span>Ban</span></button>
      <button class="clean-btn danger" onclick="deleteRecord('${id}')"><span>Delete Key</span><span>Delete</span></button>
    </div>
  `);
}

function copyKey(id){const r=records.find(x=>x.id===id);if(r)copyTextValue(r.key)}
function copyBannedKey(id){const b=banned.find(x=>x.id===id);if(b)copyTextValue(b.key)}

function customDeviceModal(id,mode){
  const r=records.find(x=>x.id===id);if(!r)return;
  modal(mode==='add'?'+ Add Custom Device Limit':'- Remove Custom Device Limit',`
    <div class="field"><label>Custom device count</label><input id="customDevAmt" type="number" min="1" value="1"></div>
    <div class="modal-actions">
      <button class="secondary" onclick="rowMenu('${id}')">Back</button>
      <button class="create" onclick="applyCustomDevice('${id}','${mode}')">Apply</button>
    </div>
  `);
}

function applyCustomDevice(id,mode){
  const r=records.find(x=>x.id===id);if(!r)return;
  const amt=Math.max(1,+$('#customDevAmt').value||1);
  const cur=r.deviceLimit===0?1:(r.deviceLimit||1);
  r.deviceLimit=mode==='add'?(cur+amt):Math.max(1,cur-amt);
  r.modifiedAt=Date.now();
  persist('merge');renderAll();rowMenu(id);notify(`Devices: ${r.deviceLimit}`);
}

function customTimeModal(id,mode){
  const r=records.find(x=>x.id===id);if(!r)return;
  modal(mode==='add'?'+ Add Custom Time':'- Remove Custom Time',`
    <div class="formgrid">
      <div class="field"><label>Custom amount</label><input id="adjAmt" type="number" min="1" value="1"></div>
      <div class="field"><label>Unit</label><select id="adjUnit"><option value="m">Minutes</option><option value="h" selected>Hours</option><option value="D">Days</option></select></div>
    </div>
    <div class="modal-actions">
      <button class="secondary" onclick="rowMenu('${id}')">Back</button>
      <button class="create" onclick="applyTimeAdjust('${id}','${mode}')">Apply</button>
    </div>
  `);
}

function applyTimeAdjust(id,mode){
  const r=records.find(x=>x.id===id);if(!r)return;
  const amt=Math.max(1,+$('#adjAmt').value||1);
  const unit=$('#adjUnit').value;
  const delta=amt*(unit==='m'?60000:unit==='h'?3600000:86400000);
  const now=Date.now();
  if(!r.durationMs){
    if(mode==='add'){r.startedAt=r.startedAt||now;r.durationMs=delta;}
  }else{
    if(mode==='add'){
      r.durationMs+=delta;
      if(r.status==='Expired'&&(r.startedAt||now)+r.durationMs>now)r.status='Active';
    }else{
      r.durationMs=Math.max(0,r.durationMs-delta);
      if(r.startedAt&&(r.startedAt+r.durationMs)<=now)r.status='Expired';
    }
  }
  r.modifiedAt=now;
  persist('merge');renderAll();rowMenu(id);notify('Updated');
}

function pauseIndefinite(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  r.status='Paused';r.pauseType='manual';r.pauseUntil=null;r.modifiedAt=Date.now();
  persist('merge');renderAll();closeModal();notify('Paused');
}

function pauseTimedModal(id){
  modal('Pause Key (Timed)',`
    <div class="formgrid">
      <div class="field"><label>Amount</label><input id="pAmt" type="number" min="1" value="1"></div>
      <div class="field"><label>Unit</label><select id="pUnit"><option value="m">Minutes</option><option value="h" selected>Hours</option><option value="D">Days</option></select></div>
    </div>
    <div class="modal-actions">
      <button class="secondary" onclick="rowMenu('${id}')">Back</button>
      <button class="create" onclick="applyTimedPause('${id}')">Pause</button>
    </div>
  `);
}

function applyTimedPause(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  const amt=Math.max(1,+$('#pAmt').value||1);
  const unit=$('#pUnit').value;
  const ms=amt*(unit==='m'?60000:unit==='h'?3600000:86400000);
  const now=Date.now();
  r.status='Paused';r.pauseType='temp';r.pauseUntil=now+ms;r.modifiedAt=now;
  persist('merge');renderAll();closeModal();notify('Temp paused');
}

function resumeKey(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  const now=Date.now();
  r.pauseType=null;r.pauseUntil=null;
  r.status=(r.startedAt&&r.durationMs&&(r.startedAt+r.durationMs<=now))?'Expired':'Active';
  r.modifiedAt=now;
  persist('merge');renderAll();closeModal();notify('Resumed');
}

function banRecord(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  const banEntry={id:uid(),key:r.key,reason:'Banned by admin',date:new Date().toLocaleString(),modifiedAt:Date.now()};
  banned.unshift(banEntry);
  records=records.filter(x=>x.id!==id);
  persist('ban_key',{id,key:r.key,banEntry});renderAll();closeModal();notify('Banned');
}

function deleteRecord(id){
  records=records.filter(x=>x.id!==id);
  persist('delete_key',{id});renderAll();closeModal();notify('Deleted');
}

function generateKeys(){
  const n=Math.max(1,Math.min(100,+$('#genCount').value||1));
  const name=($('#genName').value||'').trim()||'Key',desc=($('#genDesc').value||'').trim()||'—';
  const type=$('#genType').value,unit=$('#genDurationUnit').value,val=$('#genDurationValue').value;
  const prefix=$('#genPrefix').value,customKey=$('#genCustomKey').value;
  const durationMs=durationToMs(unit,val),now=Date.now(),out=[];

  for(let i=0;i<n;i++){
    const keyVal=buildKeyValue({type,prefix,unit,val,customKey:(n===1&&customKey.trim())?customKey:''});
    const r={
      id:uid(),name,description:desc,type,
      status:updateModeOn?'Paused':'Active',
      pauseType:updateModeOn?'update':null,pauseUntil:null,
      deviceLimit:+$('#genDevices').value,
      created:new Date().toISOString().slice(0,16).replace('T',' '),
      modifiedAt:now,key:keyVal,durationMs,startedAt:null
    };
    records.unshift(r);out.push(r.key);
  }
  persist('merge');
  $('#generated').innerHTML=`<div style="display:flex;flex-direction:column;gap:8px;background:rgba(0,0,0,.35);border:1px solid rgba(255,255,255,.08);padding:12px;border-radius:12px">${out.map((k,idx)=>`<div class="key-cell"><button type="button" class="copy-icon-btn" title="Copy" data-gen-copy="${idx}">${COPY_ICON_SVG}</button><span class="keycode">${esc(k)}</span></div>`).join('')}</div>
    <button class="secondary" style="margin-top:10px" onclick="copyTextValue(${JSON.stringify(out.join('\n'))})">Copy all</button>`;
  $('#generated').querySelectorAll('[data-gen-copy]').forEach(btn=>{
    btn.addEventListener('click',()=>copyTextValue(out[+btn.dataset.genCopy]));
  });
  renderAll();
}

function openBan(){
  modal('Ban API Key',`<form onsubmit="banManual(event)">
    <div class="field"><label>API Key</label><input id="banValue" required></div>
    <div class="field" style="margin-top:10px"><label>Reason</label><input id="banReason" placeholder="Reason"></div>
    <div class="modal-actions"><button class="create">Ban key</button></div>
  </form>`);
}
function banManual(e){
  e.preventDefault();
  const keyVal=$('#banValue').value.trim(),existing=records.find(r=>r.key===keyVal);
  const banEntry={id:uid(),key:keyVal,reason:($('#banReason').value||'').trim()||'Banned',date:new Date().toLocaleString(),modifiedAt:Date.now()};
  banned.unshift(banEntry);
  records=records.filter(r=>r.key!==keyVal);
  persist('ban_key',{id:existing?existing.id:'',key:keyVal,banEntry});renderAll();closeModal();notify('Banned');
}
function renderBanned(){
  $('#bannedRows').innerHTML=banned.map(b=>`<tr>
    <td><div class="key-cell"><button type="button" class="copy-icon-btn" title="Copy" onclick="copyBannedKey('${b.id}')">${COPY_ICON_SVG}</button><span class="keycode">${esc(b.key)}</span></div></td>
    <td>${esc(b.reason)}</td>
    <td>${esc(b.date)}</td>
    <td><button class="secondary" onclick="unban('${b.id}')">Unban</button></td>
  </tr>`).join('')||`<tr><td colspan="4" class="blank">—</td></tr>`;
}
function unban(id){banned=banned.filter(x=>x.id!==id);persist('unban_key',{id});renderAll()}
function clearAllKeys(){
  if(!confirm('Silmek istediğine emin misin?'))return;
  records=[];deviceSessions=[];updateModeOn=false;
  persist('clear_all_manual',{confirmClearAll:true});renderAll();notify('Cleared');
}

function exportTxt(){const lines=records.map(r=>r.key);download('api-keys.txt',lines.join('\n')+(lines.length?'\n':''),'text/plain')}
function importTxt(file){
  if(!file)return;const reader=new FileReader();
  reader.onload=()=>{
    const lines=String(reader.result).split(/\r?\n/).map(x=>x.trim()).filter(Boolean);
    let added=0;const now=Date.now();
    for(const key of lines){
      if(records.some(r=>r.key===key))continue;
      records.unshift({id:uid(),name:'Key',description:'—',type:'NORMAL',status:updateModeOn?'Paused':'Active',pauseType:updateModeOn?'update':null,pauseUntil:null,deviceLimit:1,created:new Date().toISOString().slice(0,16).replace('T',' '),modifiedAt:now,key,durationMs:null,startedAt:null});
      added++;
    }
    persist('merge');renderAll();notify(`+${added}`);
  };reader.readAsText(file);
}
function backupJson(){download('darkios-backup.json',JSON.stringify({records,banned,devices:deviceSessions,updateModeOn},null,2),'application/json')}
function restoreJson(file){
  if(!file)return;const r=new FileReader();
  r.onload=()=>{try{const d=JSON.parse(r.result);records=d.records||[];banned=d.banned||[];deviceSessions=d.devices||[];updateModeOn=!!d.updateModeOn;persist('merge');renderAll();notify('Restored')}catch{notify('Invalid JSON')}};
  r.readAsText(file);
}
function download(name,data,type){const a=document.createElement('a'),u=URL.createObjectURL(new Blob([data],{type}));a.href=u;a.download=name;a.click();URL.revokeObjectURL(u)}

function renderAll(){renderRows();renderBanned();renderUpdateUI()}
applyLang();
saveLocalCache();
renderAll();
setInterval(()=>{if($('#adminApp').style.display!=='none'){renderRows();renderUpdateUI()}},1000);
setInterval(()=>{if($('#adminApp').style.display!=='none'&&!$('#modalBg').classList.contains('open')){pullFromServer(false)}},3000);
document.addEventListener('visibilitychange',()=>{if(!document.hidden&&$('#adminApp').style.display!=='none'){pullFromServer(false)}});
if(sessionStorage.getItem('darkios_auth')==='1'){$('#loginScreen').style.display='none';$('#adminApp').style.display='flex';pullFromServer(false)}
</script>
</body>
</html>
