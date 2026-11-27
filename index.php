<?php
$dataDir = __DIR__ . '/data';
$backupDir = $dataDir . '/backups';
$dataFile = $dataDir . '/store.json';
$lockFile = $dataDir . '/store.lock';

if (!is_dir($dataDir)) {
    @mkdir($dataDir, 0775, true);
}
if (!is_dir($backupDir)) {
    @mkdir($backupDir, 0775, true);
}

// Birbaşa JSON faylına kənardan girişi bağla
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

    // Hər dəyişiklikdə təhlükəsiz ehtiyat nüsxə saxla (son 30 nüsxə)
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

function darkiosMergeByKeyOrId(array $current, array $incoming, array $deletedIds, string $uniqueField = 'key'): array {
    $deletedMap = array_flip($deletedIds);
    $map = [];

    foreach ($current as $item) {
        if (!is_array($item)) continue;
        $id = $item['id'] ?? '';
        $uk = $item[$uniqueField] ?? $id;
        if ($id !== '' && isset($deletedMap[$id])) continue;
        if ($uk !== '') {
            $map[$uk] = $item;
        }
    }

    foreach ($incoming as $item) {
        if (!is_array($item)) continue;
        $id = $item['id'] ?? '';
        $uk = $item[$uniqueField] ?? $id;
        if ($id !== '' && isset($deletedMap[$id])) continue;
        if ($uk === '') continue;

        if (isset($map[$uk])) {
            $existing = $map[$uk];
            $existingMod = (int)($existing['modifiedAt'] ?? 0);
            $incomingMod = (int)($item['modifiedAt'] ?? 0);
            if ($incomingMod >= $existingMod) {
                // startedAt heç vaxt itməsin
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
    usort($result, function ($a, $b) {
        return strcmp((string)($b['created'] ?? ''), (string)($a['created'] ?? ''));
    });
    return $result;
}

if (isset($_GET['sync'])) {
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('Pragma: no-cache');

    $lockFp = @fopen($lockFile, 'c+');
    if ($lockFp) {
        @flock($lockFp, LOCK_EX);
    }

    $current = darkiosReadStore($dataFile, $backupDir, $defaultStore);

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $payload = json_decode((string)file_get_contents('php://input'), true);
        if (!is_array($payload)) {
            if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
            http_response_code(400);
            echo json_encode(['status' => 'error', 'message' => 'Invalid JSON'], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $action = $payload['action'] ?? 'merge';
        $deletedIds = is_array($current['deletedIds'] ?? null) ? $current['deletedIds'] : [];

        if ($action === 'delete_key' && !empty($payload['id'])) {
            $delId = (string)$payload['id'];
            if (!in_array($delId, $deletedIds, true)) {
                $deletedIds[] = $delId;
            }
            $current['records'] = array_values(array_filter($current['records'], fn($r) => ($r['id'] ?? '') !== $delId));
            $current['devices'] = array_values(array_filter($current['devices'], fn($d) => ($d['keyId'] ?? '') !== $delId));
        } elseif ($action === 'ban_key') {
            $banObj = is_array($payload['banEntry'] ?? null) ? $payload['banEntry'] : null;
            $delId = (string)($payload['id'] ?? '');
            $banKeyVal = (string)($banObj['key'] ?? ($payload['key'] ?? ''));
            if ($delId !== '' && !in_array($delId, $deletedIds, true)) {
                $deletedIds[] = $delId;
            }
            if ($banKeyVal !== '') {
                $current['records'] = array_values(array_filter($current['records'], fn($r) => ($r['key'] ?? '') !== $banKeyVal && ($r['id'] ?? '') !== $delId));
                if ($banObj) {
                    array_unshift($current['banned'], $banObj);
                }
            }
        } elseif ($action === 'unban_key' && !empty($payload['id'])) {
            $unbanId = (string)$payload['id'];
            if (!in_array($unbanId, $deletedIds, true)) {
                $deletedIds[] = $unbanId;
            }
            $current['banned'] = array_values(array_filter($current['banned'], fn($b) => ($b['id'] ?? '') !== $unbanId));
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

        $mergedRecords = ($action === 'clear_all_manual')
            ? []
            : darkiosMergeByKeyOrId($current['records'], $incomingRecords, $deletedIds, 'key');

        $mergedBanned = darkiosMergeByKeyOrId($current['banned'], $incomingBanned, $deletedIds, 'key');
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
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Write failed'], JSON_UNESCAPED_UNICODE);
            exit;
        }

        if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
        echo json_encode(['status' => 'ok', 'data' => $nextStore], JSON_UNESCAPED_UNICODE);
        exit;
    }

    if ($lockFp) { @flock($lockFp, LOCK_UN); @fclose($lockFp); }
    echo json_encode(['status' => 'ok', 'data' => $current], JSON_UNESCAPED_UNICODE);
    exit;
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
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@600;700;800&family=Plus+Jakarta+Sans:wght@600;700;800&display=swap" rel="stylesheet">
<style>
:root{
  --bg:#070709;
  --rail:#0b0b0e;
  --panel:#101015;
  --panel2:#17171e;
  --line:#24242f;
  --text:#ffffff;
  --muted:#8e8e9c;
  --red:#e63946;
  --red-hover:#ff4757;
  --red-soft:rgba(230,57,70,.14);
  --red-border:rgba(230,57,70,.42);
}
*{box-sizing:border-box}
body{
  margin:0;
  background:var(--bg);
  color:var(--text);
  font-family:'Plus Jakarta Sans',system-ui,-apple-system,sans-serif;
  font-weight:700;
  font-size:13px;
  min-height:100vh;
  -webkit-font-smoothing:antialiased;
}
.shell{display:flex;min-height:100vh}
.rail{
  width:54px;
  flex:0 0 54px;
  background:var(--rail);
  border-right:1px solid var(--line);
  display:flex;
  flex-direction:column;
  align-items:center;
  padding:14px 6px;
  gap:10px;
  position:fixed;
  inset:0 auto 0 0;
  z-index:8;
}
.rail .logo{
  height:38px;
  width:38px;
  border-radius:10px;
  background:var(--panel2);
  border:1px solid var(--line);
  display:grid;
  place-items:center;
  color:var(--red);
  margin-bottom:10px;
}
.rail svg{
  width:19px;
  height:19px;
  fill:none;
  stroke:currentColor;
  stroke-width:2.1;
  stroke-linecap:round;
  stroke-linejoin:round;
}
.rail button{
  width:38px;
  height:38px;
  border:1px solid transparent;
  border-radius:10px;
  background:transparent;
  color:var(--muted);
  display:grid;
  place-items:center;
  cursor:pointer;
  transition:all .18s ease;
}
.rail button:hover{background:var(--panel2);color:var(--text)}
.rail button.active{
  background:var(--red-soft);
  color:var(--red);
  border-color:var(--red-border);
}
.main{margin-left:54px;min-width:0;width:calc(100% - 54px)}
.topbar{
  height:52px;
  background:rgba(11,11,14,.92);
  backdrop-filter:blur(10px);
  border-bottom:1px solid var(--line);
  display:flex;
  align-items:center;
  justify-content:space-between;
  padding:0 18px;
  position:sticky;
  top:0;
  z-index:5;
}
.top-left{display:flex;align-items:center;gap:10px;font-size:15px;font-weight:800;letter-spacing:.3px}
.top-left .dot{width:8px;height:8px;border-radius:50%;background:var(--red);box-shadow:0 0 10px var(--red)}
.top-right{display:flex;align-items:center;gap:8px}
.top-btn,.top-select{
  border:1px solid var(--line);
  background:var(--panel);
  color:var(--text);
  padding:6px 11px;
  border-radius:7px;
  font-family:inherit;
  font-size:11px;
  font-weight:700;
  cursor:pointer;
  transition:.18s;
}
.top-btn:hover,.top-select:hover{border-color:#3a3a48;background:var(--panel2)}
.content{padding:22px 18px 36px;max-width:1520px;margin:auto}
.heading{display:flex;align-items:center;justify-content:space-between;gap:12px;margin:0 0 18px;flex-wrap:wrap}
.heading h1{font-size:21px;margin:0 0 4px;font-weight:800;letter-spacing:-.2px}
.heading p{margin:0;color:var(--muted);font-size:12px;font-weight:600}
.create{
  background:var(--red);
  color:#fff;
  border:0;
  border-radius:8px;
  padding:9px 15px;
  font-family:inherit;
  font-size:12px;
  font-weight:800;
  cursor:pointer;
  transition:.18s;
}
.create:hover{background:var(--red-hover)}
.cards{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;margin-bottom:18px}
.metric{
  border:1px solid var(--line);
  border-radius:10px;
  background:var(--panel);
  padding:14px 16px;
}
.metric.accent{border-color:var(--red-border)}
.metric .label{font-size:10px;letter-spacing:.6px;color:var(--muted);text-transform:uppercase;font-weight:800}
.metric strong{display:block;font-size:22px;margin-top:6px;font-weight:800;color:var(--text)}
.metric.accent strong{color:var(--red)}
.table-panel{border:1px solid var(--line);background:var(--panel);border-radius:10px;overflow:hidden}
.table-head{
  padding:12px 14px;
  display:flex;
  align-items:center;
  justify-content:space-between;
  gap:10px;
  border-bottom:1px solid var(--line);
  flex-wrap:wrap;
}
.table-title{font-size:13px;font-weight:800;display:flex;align-items:center;gap:8px}
.count{
  font-size:10px;
  color:var(--red);
  background:var(--red-soft);
  border:1px solid var(--red-border);
  padding:3px 7px;
  border-radius:5px;
  font-weight:800;
}
.filters{display:flex;align-items:center;gap:7px;flex-wrap:wrap}
.filters input,.filters select{
  height:30px;
  border:1px solid var(--line);
  border-radius:7px;
  background:var(--bg);
  color:var(--text);
  font-family:inherit;
  font-size:11px;
  font-weight:700;
  padding:0 10px;
}
.filters input{width:170px}
.reset{
  height:30px;
  border:1px solid var(--line);
  border-radius:7px;
  background:var(--panel2);
  color:var(--text);
  font-family:inherit;
  font-size:11px;
  font-weight:700;
  padding:0 11px;
  cursor:pointer;
}
.table-wrap{overflow-x:auto}
.table{width:100%;border-collapse:collapse;min-width:860px}
.table th{
  height:36px;
  background:var(--panel2);
  color:var(--muted);
  text-align:left;
  font-size:10px;
  font-weight:800;
  letter-spacing:.5px;
  padding:0 12px;
  border-bottom:1px solid var(--line);
}
.table td{
  height:48px;
  border-bottom:1px solid var(--line);
  padding:8px 12px;
  font-size:12px;
  font-weight:700;
  color:var(--text);
  white-space:nowrap;
}
.table tr:last-child td{border-bottom:0}
.table tbody tr:hover{background:#14141a}
.name{font-weight:800;color:#fff;font-size:12px}
.desc{font-size:10px;color:var(--muted);margin-top:2px;font-weight:600}
.key-cell{display:inline-flex;align-items:center;gap:6px}
.copy-icon-btn{
  width:26px;
  height:26px;
  border:1px solid var(--line);
  background:var(--panel2);
  color:var(--muted);
  border-radius:6px;
  display:inline-grid;
  place-items:center;
  cursor:pointer;
  transition:.15s;
  padding:0;
}
.copy-icon-btn:hover{border-color:var(--red-border);color:#fff;background:#1f1f29}
.copy-icon-btn svg{width:13px;height:13px;fill:none;stroke:currentColor;stroke-width:2.1;stroke-linecap:round;stroke-linejoin:round}
.keycode{
  font-family:'JetBrains Mono',monospace;
  font-size:11px;
  font-weight:700;
  background:var(--bg);
  border:1px solid var(--line);
  color:#fff;
  border-radius:6px;
  padding:4px 8px;
}
.type{
  font-size:10px;
  font-weight:800;
  border:1px solid var(--line);
  background:var(--panel2);
  color:#fff;
  border-radius:5px;
  padding:3px 7px;
}
.status{
  font-size:10px;
  font-weight:800;
  border:1px solid var(--line);
  color:var(--muted);
  border-radius:5px;
  padding:3px 7px;
}
.status.active{border-color:#343440;color:#fff;background:#1c1c24}
.status.paused,.status.expired{border-color:var(--red-border);color:var(--red);background:var(--red-soft)}
.dots{
  border:1px solid var(--line);
  background:var(--panel2);
  color:#fff;
  border-radius:6px;
  width:28px;
  height:28px;
  font-size:15px;
  cursor:pointer;
}
.blank{padding:42px 16px;text-align:center;color:var(--muted);font-size:12px;font-weight:700}
.view{display:none}.view.active{display:block}
.modal-bg{position:fixed;inset:0;background:rgba(0,0,0,.84);z-index:20;display:none;align-items:center;justify-content:center;padding:16px}
.modal-bg.open{display:flex}
.modal{width:min(460px,100%);background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:18px;max-height:90vh;overflow-y:auto}
.modal-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px}
.modal-top h2{font-size:15px;margin:0;font-weight:800}
.x{border:0;background:none;color:var(--muted);font-size:22px;cursor:pointer;line-height:1}
.formgrid{display:grid;grid-template-columns:1fr 1fr;gap:11px}
.field{display:flex;flex-direction:column;gap:5px}
.field.full{grid-column:1/-1}
.field label{font-size:11px;color:var(--muted);font-weight:700}
.field input,.field select,.field textarea{
  background:var(--bg);
  border:1px solid var(--line);
  color:#fff;
  border-radius:8px;
  padding:9px 10px;
  font-family:inherit;
  font-size:12px;
  font-weight:700;
}
.clean-meta{
  background:var(--bg);
  border:1px solid var(--line);
  border-radius:10px;
  padding:10px 12px;
  margin-bottom:12px;
  font-size:11px;
  color:var(--muted);
  display:flex;
  flex-direction:column;
  gap:4px;
}
.clean-meta strong{color:#fff;font-family:'JetBrains Mono',monospace;font-size:11px}
.clean-list{display:flex;flex-direction:column;gap:8px}
.clean-btn{
  width:100%;
  display:flex;
  align-items:center;
  justify-content:space-between;
  background:var(--panel2);
  border:1px solid var(--line);
  color:#fff;
  border-radius:9px;
  padding:10px 12px;
  font-family:inherit;
  font-size:12px;
  font-weight:700;
  cursor:pointer;
  transition:.15s;
}
.clean-btn:hover{border-color:#3d3d4d;background:#1f1f29}
.clean-btn.danger{border-color:var(--red-border);color:var(--red);background:var(--red-soft)}
.clean-btn.danger:hover{background:rgba(230,57,70,.24)}
.clean-row{display:grid;grid-template-columns:1fr auto;gap:7px;align-items:center}
.info-btn{
  width:36px;
  height:36px;
  border-radius:9px;
  border:1px solid var(--line);
  background:var(--bg);
  color:#fff;
  font-family:'JetBrains Mono',monospace;
  font-size:13px;
  font-weight:800;
  cursor:pointer;
  transition:.15s;
}
.info-btn:hover{border-color:var(--red-border);color:var(--red)}
.modal-actions{display:flex;justify-content:flex-end;gap:8px;margin-top:14px;flex-wrap:wrap}
.secondary{
  background:var(--panel2);
  color:#fff;
  border:1px solid var(--line);
  border-radius:8px;
  padding:8px 12px;
  font-family:inherit;
  font-size:11px;
  font-weight:700;
  cursor:pointer;
  transition:.15s;
}
.secondary:hover{border-color:#3b3b49;background:#20202a}
.secondary.danger{border-color:var(--red-border);color:var(--red);background:var(--red-soft)}
.footnote{color:var(--muted);font-size:11px;margin-top:8px;font-weight:600;line-height:1.45}
.toast{
  position:fixed;right:18px;bottom:18px;
  background:#fff;color:#070709;
  padding:10px 15px;border-radius:8px;
  font-weight:800;font-size:12px;
  z-index:40;display:none;
}
.toast.show{display:block}
.settings-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:12px}
.setting-card{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:16px}
.setting-card h3{margin:0 0 6px;font-size:14px;font-weight:800}
.setting-card p{color:var(--muted);font-size:11px;margin:0 0 12px;font-weight:600;line-height:1.5}
.switch-row{display:flex;align-items:center;justify-content:space-between;gap:12px;margin-top:8px}
.switch{position:relative;display:inline-block;width:48px;height:26px}
.switch input{opacity:0;width:0;height:0}
.slider{position:absolute;cursor:pointer;inset:0;background:var(--panel2);border:1px solid var(--line);transition:.2s;border-radius:26px}
.slider:before{position:absolute;content:"";height:18px;width:18px;left:3px;bottom:3px;background:#fff;transition:.2s;border-radius:50%}
input:checked + .slider{background:var(--red);border-color:var(--red)}
input:checked + .slider:before{transform:translateX(22px)}
.update-badge{
  display:inline-block;
  margin-top:8px;
  font-family:'JetBrains Mono',monospace;
  font-size:10px;
  font-weight:800;
  padding:4px 8px;
  border-radius:5px;
  background:var(--red-soft);
  border:1px solid var(--red-border);
  color:var(--red);
}
.login-screen{min-height:100vh;display:grid;place-items:center;padding:20px;background:var(--bg)}
.login-card{width:min(380px,100%);padding:30px;background:var(--panel);border:1px solid var(--line);border-radius:14px}
.login-logo{
  width:46px;height:46px;border-radius:11px;
  background:var(--red-soft);border:1px solid var(--red-border);
  color:var(--red);display:grid;place-items:center;margin-bottom:16px;
}
.login-logo svg{width:24px;height:24px;fill:none;stroke:currentColor;stroke-width:2.2}
.login-card h1{font-size:22px;letter-spacing:1px;margin:0 0 4px;font-weight:800}
.login-card h1 span{color:var(--red)}
.login-card p{color:var(--muted);font-size:12px;margin:0 0 20px;font-weight:600}
.login-card .field{margin:12px 0}
.login-card .field input{height:42px}
.login-submit{width:100%;height:42px;margin-top:10px}
.login-error{color:var(--red);font-size:11px;min-height:15px;margin-top:6px;font-weight:700}
@media(max-width:720px){
  .cards{grid-template-columns:repeat(2,minmax(0,1fr))}
  .settings-grid{grid-template-columns:1fr}
  .formgrid{grid-template-columns:1fr}
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
        <div class="table-panel" style="padding:18px">
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
          <button class="create" style="margin-top:16px" onclick="generateKeys()">Generate API Key(s)</button>
          <div id="generated" style="margin-top:14px"></div>
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
              <span id="updateStatusText" style="font-size:12px;font-weight:800">OFF</span>
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

// Əgər server boş gələrsə amma bu cihazın localStorage-ında əvvəlki keylər qalıbsa, onları da serverə bərpa et
(function hydrateFromLocalIfNeeded(){
  try{
    const localRecs=JSON.parse(localStorage.getItem('darkios_keys_v4')||'[]');
    if(Array.isArray(localRecs)&&localRecs.length>0){
      const existingKeys=new Set(records.map(r=>r.key));
      let added=0;
      localRecs.forEach(lr=>{
        if(lr&&lr.key&&!existingKeys.has(lr.key)){
          records.push(lr);
          added++;
        }
      });
      if(added>0){
        setTimeout(()=>pushToServer('merge'),300);
      }
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
    if(res.ok){
      const json=await res.json();
      if(json&&json.status==='ok'&&json.data){
        isSyncingFromServer=true;
        if(Array.isArray(json.data.records))records=json.data.records;
        if(Array.isArray(json.data.banned))banned=json.data.banned;
        if(Array.isArray(json.data.devices))deviceSessions=json.data.devices;
        if(typeof json.data.updateModeOn==='boolean')updateModeOn=json.data.updateModeOn;
        saveLocalCache();
        renderAll();
        isSyncingFromServer=false;
      }
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
    if(!res.ok)return;
    const json=await res.json();
    if(json&&json.status==='ok'&&json.data){
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
  ta.value=text;
  ta.style.position='fixed';
  ta.style.opacity='0';
  document.body.appendChild(ta);
  ta.focus();
  ta.select();
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
      r.pauseType=null;
      r.pauseUntil=null;
      r.status='Active';
      r.modifiedAt=now;
      changed=true;
    }
    if(r.startedAt && r.durationMs && r.status==='Active'){
      if((r.startedAt+r.durationMs)<=now){
        r.status='Expired';
        r.modifiedAt=now;
        changed=true;
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
        r.status='Paused';
        r.pauseType='update';
        r.pauseUntil=null;
        r.modifiedAt=now;
        pausedCount++;
      }
    });
    persist('merge');renderAll();
    notify(`UPDATE!!! ON (${pausedCount})`);
  }else{
    updateModeOn=false;
    let restoredCount=0;
    records.forEach(r=>{
      if(r.status==='Paused'&&r.pauseType==='update'){
        r.pauseType=null;
        r.pauseUntil=null;
        r.status=(r.startedAt&&r.durationMs&&(r.startedAt+r.durationMs<=now))?'Expired':'Active';
        r.modifiedAt=now;
        restoredCount++;
      }
    });
    persist('merge');renderAll();
    notify(`UPDATE!!! OFF (${restoredCount})`);
  }
}

function resetFilters(){$('#search').value='';$('#statusFilter').value='';$('#typeFilter').value='';renderRows()}
function modal(title,body){$('#modalTitle').textContent=title;$('#modalBody').innerHTML=body;$('#modalBg').classList.add('open')}
function closeModal(){$('#modalBg').classList.remove('open')}

function showTurkishInfo(topic){
  const infos={
    addTime:{
      title:'Zaman Ekleme (+)',
      text:'Seçili anahtarın süresine istediğin miktarda dakika, saat veya gün ekler. Süresi dolmuş bir anahtara zaman eklersen yeniden aktif hale gelir.'
    },
    subTime:{
      title:'Zaman Çıkarma (-)',
      text:'Seçili anahtarın kalan süresinden girdiğin miktarda dakika, saat veya gün düşürür. Süre sıfırlanırsa anahtar süresi dolmuş (Expired) duruma geçer.'
    },
    addDevice:{
      title:'Cihaz Sınırı Ekleme (+)',
      text:'Anahtara bağlanabilecek maksimum cihaz/IP sayısını girdiğin sayı kadar artırır.'
    },
    subDevice:{
      title:'Cihaz Sınırı Çıkarma (-)',
      text:'Anahtarın maksimum cihaz/IP limitini girdiğin sayı kadar azaltır (en az 1 olarak kalır).'
    }
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
  const type=$('#newType').value;
  const unit=$('#newDurationUnit').value;
  const val=$('#newDurationValue').value;
  const prefix=$('#newPrefix').value;
  const customKey=$('#newCustomKey').value;
  const name=($('#newName').value||'').trim()||'Key';
  const desc=($('#newDesc').value||'').trim()||'—';
  const durationMs=durationToMs(unit,val);
  const now=Date.now();

  const r={
    id:uid(),
    name,
    description:desc,
    type,
    status:updateModeOn?'Paused':'Active',
    pauseType:updateModeOn?'update':null,
    pauseUntil:null,
    deviceLimit:+($('#newDeviceLimit').value||1),
    created:new Date().toISOString().slice(0,16).replace('T',' '),
    modifiedAt:now,
    key:buildKeyValue({type,prefix,unit,val,customKey}),
    durationMs,
    startedAt:null
  };
  records.unshift(r);persist('merge');closeModal();renderAll();notify('OK');
  modal('Key Created',`<div class="key-cell" style="width:100%"><button type="button" class="copy-icon-btn" style="width:36px;height:36px;flex:0 0 36px" title="Copy" onclick="copyTextValue($('#createdKey').value)">${COPY_ICON_SVG}</button><input style="width:100%;background:#070709;color:#fff;border:1px solid #24242f;padding:10px;border-radius:7px;font-family:'JetBrains Mono',monospace" id="createdKey" value="${esc(r.key)}" readonly></div>
    <div class="modal-actions">
      <button class="secondary" onclick="copyTextValue($('#createdKey').value)">Copy</button>
      <button class="create" onclick="closeModal()">Done</button>
    </div>`);
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
      <button class="clean-btn" onclick="simulateConnect('${id}')"><span>Simulate Device Connect</span><span>Start Timer</span></button>

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

function simulateConnect(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  const now=Date.now();
  if(!r.startedAt){
    r.startedAt=now;
    notify('Timer started');
  }
  r.modifiedAt=now;
  const ip='192.168.1.'+(Math.floor(Math.random()*200)+10);
  deviceSessions.unshift({id:uid(),keyId:id,ip,status:'Active',at:new Date().toLocaleString(),modifiedAt:now});
  persist('merge');renderAll();rowMenu(id);
}

function customDeviceModal(id,mode){
  const r=records.find(x=>x.id===id);if(!r)return;
  modal(mode==='add'?'+ Add Custom Device Limit':'- Remove Custom Device Limit',`
    <div class="field">
      <label>Custom device count</label>
      <input id="customDevAmt" type="number" min="1" value="1">
    </div>
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
    if(mode==='add'){
      r.startedAt=r.startedAt||now;
      r.durationMs=delta;
    }
  }else{
    if(mode==='add'){
      r.durationMs+=delta;
      if(r.status==='Expired'&&(r.startedAt||now)+r.durationMs>now){
        r.status='Active';
      }
    }else{
      r.durationMs=Math.max(0,r.durationMs-delta);
      if(r.startedAt&&(r.startedAt+r.durationMs)<=now){
        r.status='Expired';
      }
    }
  }
  r.modifiedAt=now;
  persist('merge');renderAll();rowMenu(id);notify('Updated');
}

function pauseIndefinite(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  r.status='Paused';
  r.pauseType='manual';
  r.pauseUntil=null;
  r.modifiedAt=Date.now();
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
  r.status='Paused';
  r.pauseType='temp';
  r.pauseUntil=now+ms;
  r.modifiedAt=now;
  persist('merge');renderAll();closeModal();notify('Temp paused');
}

function resumeKey(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  const now=Date.now();
  r.pauseType=null;
  r.pauseUntil=null;
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
  const name=($('#genName').value||'').trim()||'Key';
  const desc=($('#genDesc').value||'').trim()||'—';
  const type=$('#genType').value;
  const unit=$('#genDurationUnit').value;
  const val=$('#genDurationValue').value;
  const prefix=$('#genPrefix').value;
  const customKey=$('#genCustomKey').value;
  const durationMs=durationToMs(unit,val);
  const now=Date.now();
  const out=[];

  for(let i=0;i<n;i++){
    const keyVal=buildKeyValue({
      type,
      prefix,
      unit,
      val,
      customKey:(n===1&&customKey.trim())?customKey:''
    });
    const r={
      id:uid(),
      name,
      description:desc,
      type,
      status:updateModeOn?'Paused':'Active',
      pauseType:updateModeOn?'update':null,
      pauseUntil:null,
      deviceLimit:+$('#genDevices').value,
      created:new Date().toISOString().slice(0,16).replace('T',' '),
      modifiedAt:now,
      key:keyVal,
      durationMs,
      startedAt:null
    };
    records.unshift(r);out.push(r.key);
  }
  persist('merge');
  $('#generated').innerHTML=`<div style="display:flex;flex-direction:column;gap:6px;background:#070709;border:1px solid #24242f;padding:10px;border-radius:7px">${out.map((k,idx)=>`<div class="key-cell"><button type="button" class="copy-icon-btn" title="Copy" data-gen-copy="${idx}">${COPY_ICON_SVG}</button><span class="keycode">${esc(k)}</span></div>`).join('')}</div>
    <button class="secondary" style="margin-top:8px" onclick="copyTextValue(${JSON.stringify(out.join('\n'))})">Copy all</button>`;
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
  const keyVal=$('#banValue').value.trim();
  const existing=records.find(r=>r.key===keyVal);
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
  if(!confirm('Bütün keyləri silmək istədiyinə əminsən?'))return;
  records=[];deviceSessions=[];updateModeOn=false;
  persist('clear_all_manual',{confirmClearAll:true});renderAll();notify('Cleared');
}

function exportTxt(){const lines=records.map(r=>r.key);download('api-keys.txt',lines.join('\n')+(lines.length?'\n':''),'text/plain')}
function importTxt(file){
  if(!file)return;const reader=new FileReader();
  reader.onload=()=>{
    const lines=String(reader.result).split(/\r?\n/).map(x=>x.trim()).filter(Boolean);
    let added=0;
    const now=Date.now();
    for(const key of lines){
      if(records.some(r=>r.key===key))continue;
      records.unshift({id:uid(),name:'Key',description:'—',type:'NORMAL',status:updateModeOn?'Paused':'Active',pauseType:updateModeOn?'update':null,pauseUntil:null,deviceLimit:1,created:new Date().toISOString().slice(0,16).replace('T',' '),modifiedAt:now,key,durationMs:null,startedAt:null});
      added++;
    }
    persist('merge');renderAll();notify(`+${added}`);
  };reader.readAsText(file);
}
function backupJson(){download('darkios-backup.json',JSON.stringify({records,banned,updateModeOn},null,2),'application/json')}
function restoreJson(file){
  if(!file)return;const r=new FileReader();
  r.onload=()=>{try{const d=JSON.parse(r.result);records=d.records||[];banned=d.banned||[];updateModeOn=!!d.updateModeOn;persist('merge');renderAll();notify('Restored')}catch{notify('Invalid JSON')}};
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
