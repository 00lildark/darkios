!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>DARKIOS • Admin Console</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@500;600&family=Sora:wght@400;600;700&display=swap" rel="stylesheet">
<style>
:root{
  --bg:#12102a;--side:#0d0b20;--panel:#1b1840;--panel2:#241f52;--line:#2f2a66;
  --text:#f1efff;--muted:#9b96c9;
  --acc:#8b9cff;--acc2:#6f7dff;--acc-soft:rgba(139,156,255,.14);
  --ok:#5eead4;--warn:#fbbf24;--bad:#ff6b81;
  --bad-soft:rgba(255,107,129,.13);--ok-soft:rgba(94,234,212,.12);--warn-soft:rgba(251,191,36,.12);
  --side-w:216px;
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--text);font:400 13px/1.45 'Sora',system-ui,sans-serif;min-height:100vh;-webkit-font-smoothing:antialiased}
button,input,select,textarea{font-family:inherit;color:inherit}
:focus-visible{outline:2px solid var(--acc);outline-offset:2px}
.shell{display:flex;min-height:100vh}

/* Sidebar */
.side{position:fixed;inset:0 auto 0 0;width:var(--side-w);background:var(--side);border-right:1px solid var(--line);display:flex;flex-direction:column;padding:20px 14px;z-index:8}
.brand{display:flex;align-items:center;gap:10px;margin:0 6px 26px}
.brand i{width:34px;height:34px;border-radius:50% 50% 50% 8px;background:linear-gradient(135deg,var(--acc),#c4a7ff);display:grid;place-items:center;color:#12102a}
.brand svg{width:18px;height:18px;fill:none;stroke:currentColor;stroke-width:2.4;stroke-linecap:round;stroke-linejoin:round}
.brand b{font-size:15px;font-weight:700;letter-spacing:.2px}
.brand small{display:block;color:var(--muted);font-size:11px;font-weight:400}
.nav{display:flex;flex-direction:column;gap:4px}
.nav button{display:flex;align-items:center;gap:11px;width:100%;padding:10px 12px;border:0;border-radius:10px;background:none;color:var(--muted);font-size:13px;font-weight:600;cursor:pointer;text-align:left;transition:background .15s,color .15s}
.nav svg{width:18px;height:18px;flex:none;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.nav button:hover{background:var(--panel);color:var(--text)}
.nav button.active{background:var(--acc-soft);color:var(--acc);box-shadow:inset 3px 0 0 var(--acc)}
.side-foot{margin-top:auto;display:flex;flex-direction:column;gap:8px}
.upd-pill{display:none;padding:9px 11px;border-radius:10px;background:var(--warn-soft);color:var(--warn);font-size:11px;font-weight:600}
.upd-pill.on{display:block}

.main{margin-left:var(--side-w);width:calc(100% - var(--side-w));min-width:0}
.topbar{height:58px;display:flex;align-items:center;justify-content:space-between;padding:0 24px;background:rgba(18,16,42,.88);backdrop-filter:blur(10px);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:5}
.topbar h2{margin:0;font-size:15px;font-weight:700}
.top-right{display:flex;gap:8px;align-items:center}
.btn{border:1px solid var(--line);background:var(--panel);padding:7px 13px;border-radius:9px;font-size:12px;font-weight:600;cursor:pointer;transition:background .15s,border-color .15s}
.btn:hover{background:var(--panel2);border-color:#433d8a}
.btn.primary{background:var(--acc);border-color:var(--acc);color:#12102a}
.btn.primary:hover{background:#a3b1ff}
.btn.danger{color:var(--bad);border-color:rgba(255,107,129,.4);background:var(--bad-soft)}
select.btn{padding-right:8px}

.content{padding:26px 24px 48px;max-width:1500px;margin:auto}
.heading{display:flex;align-items:flex-end;justify-content:space-between;gap:12px;flex-wrap:wrap;margin-bottom:20px}
.heading h1{margin:0 0 4px;font-size:24px;font-weight:700;letter-spacing:-.3px}
.heading p{margin:0;color:var(--muted);font-size:12px}

/* Stats strip */
.stats{display:grid;grid-template-columns:repeat(4,1fr);background:var(--panel);border:1px solid var(--line);border-radius:16px;margin-bottom:20px;overflow:hidden}
.stat{padding:16px 20px;border-right:1px solid var(--line)}
.stat:last-child{border:0}
.stat span{color:var(--muted);font-size:11px;display:flex;align-items:center;gap:7px}
.stat span:before{content:"";width:8px;height:8px;border-radius:50%;background:var(--c,var(--acc))}
.stat strong{display:block;margin-top:6px;font-size:28px;font-weight:700;letter-spacing:-.5px}

/* Table */
.panel{background:var(--panel);border:1px solid var(--line);border-radius:16px;overflow:hidden}
.panel-head{display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap;padding:14px 16px;border-bottom:1px solid var(--line)}
.ptitle{font-size:14px;font-weight:700;display:flex;align-items:center;gap:9px}
.count{font-size:11px;font-weight:600;color:var(--acc);background:var(--acc-soft);padding:3px 9px;border-radius:99px}
.filters{display:flex;gap:7px;flex-wrap:wrap}
.filters input,.filters select,.field input,.field select,.field textarea{background:var(--bg);border:1px solid var(--line);border-radius:9px;padding:0 11px;height:34px;font-size:12px}
.filters input{width:200px}
.tw{overflow-x:auto}
table{width:100%;border-collapse:collapse;min-width:900px}
th{text-align:left;color:var(--muted);font-size:11px;font-weight:600;padding:11px 16px;background:rgba(0,0,0,.14)}
td{padding:12px 16px;border-top:1px solid var(--line);white-space:nowrap;font-size:12px}
tbody tr{transition:background .12s}
tbody tr:hover{background:rgba(139,156,255,.06)}
.nm{font-weight:600}.ds{font-size:11px;color:var(--muted);margin-top:2px}
.key{font:500 11.5px 'IBM Plex Mono',monospace;background:var(--bg);border:1px solid var(--line);border-radius:8px;padding:5px 9px;cursor:pointer;display:inline-block}
.key:hover{border-color:var(--acc)}
.chip{font-size:11px;font-weight:600;padding:3px 10px;border-radius:99px;background:var(--panel2);color:var(--text)}
.chip.t{background:var(--acc-soft);color:var(--acc)}
.chip.active{background:var(--ok-soft);color:var(--ok)}
.chip.paused{background:var(--warn-soft);color:var(--warn)}
.chip.expired{background:var(--bad-soft);color:var(--bad)}
.dots{width:30px;height:30px;border-radius:8px;border:1px solid var(--line);background:var(--panel2);cursor:pointer;font-size:16px;line-height:1}
.dots:hover{border-color:var(--acc)}
.blank{padding:56px 16px;text-align:center;color:var(--muted)}
.view{display:none}.view.active{display:block}

/* Modal */
.modal-bg{position:fixed;inset:0;background:rgba(6,5,18,.8);z-index:20;display:none;align-items:center;justify-content:center;padding:16px}
.modal-bg.open{display:flex}
.modal{width:min(480px,100%);max-height:90vh;overflow-y:auto;background:var(--panel);border:1px solid var(--line);border-radius:20px;padding:20px;animation:pop .18s ease-out}
@keyframes pop{from{transform:translateY(12px) scale(.98);opacity:0}to{transform:none;opacity:1}}
.modal-top{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}
.modal-top h2{margin:0;font-size:16px;font-weight:700}
.x{border:0;background:none;color:var(--muted);font-size:24px;cursor:pointer;line-height:1}
.formgrid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.field{display:flex;flex-direction:column;gap:5px}.field.full{grid-column:1/-1}
.field label{font-size:11px;color:var(--muted);font-weight:600}
.field input,.field select{height:38px}
.modal-actions{display:flex;justify-content:flex-end;gap:8px;margin-top:16px;flex-wrap:wrap}
.footnote{color:var(--muted);font-size:11px;margin:12px 0 0}
.meta{background:var(--bg);border:1px solid var(--line);border-radius:12px;padding:12px;margin-bottom:14px;font-size:11px;color:var(--muted);display:grid;gap:5px}
.meta strong{color:var(--text);font:500 11.5px 'IBM Plex Mono',monospace;word-break:break-all}
.act-list{display:flex;flex-direction:column;gap:7px}
.act-group{font-size:11px;color:var(--muted);font-weight:600;margin:8px 2px 0}
.act{width:100%;display:flex;justify-content:space-between;align-items:center;gap:10px;background:var(--panel2);border:1px solid var(--line);border-radius:11px;padding:10px 13px;font-size:12px;font-weight:600;cursor:pointer;transition:border-color .15s}
.act:hover{border-color:var(--acc)}
.act small{color:var(--muted);font-weight:400}
.act.danger{color:var(--bad);background:var(--bad-soft);border-color:rgba(255,107,129,.35)}
.row2{display:grid;grid-template-columns:1fr auto;gap:7px}
.info{width:40px;border-radius:11px;border:1px solid var(--line);background:var(--bg);cursor:pointer;font-weight:700;color:var(--acc)}
.info:hover{border-color:var(--acc)}

.toast{position:fixed;left:50%;bottom:24px;transform:translateX(-50%);background:var(--text);color:#12102a;padding:10px 16px;border-radius:10px;font-weight:600;font-size:12px;z-index:40;display:none}
.toast.show{display:block}

/* Settings */
.sgrid{display:grid;grid-template-columns:repeat(2,1fr);gap:14px}
.card{background:var(--panel);border:1px solid var(--line);border-radius:16px;padding:18px}
.card h3{margin:0 0 6px;font-size:14px;font-weight:700}
.card p{margin:0 0 14px;color:var(--muted);font-size:12px;line-height:1.55}
.card.hot{border-color:rgba(251,191,36,.45)}
.card .btn{margin-right:6px;display:inline-block}
.switch-row{display:flex;align-items:center;justify-content:space-between}
.switch{position:relative;width:50px;height:28px;display:inline-block}
.switch input{opacity:0;width:0;height:0}
.slider{position:absolute;inset:0;background:var(--bg);border:1px solid var(--line);border-radius:28px;cursor:pointer;transition:.2s}
.slider:before{content:"";position:absolute;width:20px;height:20px;left:3px;top:3px;background:var(--muted);border-radius:50%;transition:.2s}
input:checked+.slider{background:var(--warn-soft);border-color:var(--warn)}
input:checked+.slider:before{transform:translateX(22px);background:var(--warn)}
.badge{display:inline-block;margin-top:12px;font-size:11px;font-weight:600;padding:5px 10px;border-radius:99px;background:var(--warn-soft);color:var(--warn)}

/* Login */
.login{min-height:100vh;display:grid;place-items:center;padding:20px;background:radial-gradient(900px 500px at 15% 0,#2a2470 0,transparent 60%),var(--bg)}
.lcard{width:min(390px,100%);padding:32px;background:var(--panel);border:1px solid var(--line);border-radius:22px}
.lcard .brand{margin:0 0 22px}
.lcard h1{margin:0 0 4px;font-size:22px;font-weight:700}
.lcard p{color:var(--muted);margin:0 0 18px;font-size:12px}
.lcard .field{margin:12px 0}.lcard .field input{height:44px}
.lerr{color:var(--bad);font-size:11px;min-height:16px;margin-top:6px}
.lcard .btn{width:100%;height:44px;font-size:13px;margin-top:8px}

@media(max-width:900px){
  :root{--side-w:62px}
  .brand div,.nav span,.side-foot{display:none}
  .side{padding:14px 9px}.brand{justify-content:center;margin:0 0 20px}
  .nav button{justify-content:center;padding:11px 0}
}
@media(max-width:720px){
  .stats{grid-template-columns:repeat(2,1fr)}.stat:nth-child(2){border-right:0}.stat:nth-child(-n+2){border-bottom:1px solid var(--line)}
  .sgrid,.formgrid{grid-template-columns:1fr}
  .content{padding:18px 14px 90px}
  .side{inset:auto 0 0 0;width:auto;height:60px;flex-direction:row;padding:6px 10px;border-right:0;border-top:1px solid var(--line)}
  .brand{display:none}.nav{flex-direction:row;width:100%;justify-content:space-around}
  .nav button{width:auto;padding:10px 20px;box-shadow:none!important}
  .main{margin-left:0;width:100%}.topbar{padding:0 14px}
  .filters input{width:100%}
}
@media(prefers-reduced-motion:reduce){*{animation:none!important;transition:none!important}}
</style>
</head>
<body>

<div id="loginScreen" class="login">
  <div class="lcard">
    <div class="brand"><i><svg viewBox="0 0 24 24"><path d="M12 2.8 20.5 7.4v9.2L12 21.2l-8.5-4.6V7.4L12 2.8Z"/><path d="m8 12 2.5 2.5L16.5 8.5"/></svg></i><div><b>DARKIOS</b><small>Admin Console</small></div></div>
    <h1 id="loginTitle">Welcome back</h1>
    <p id="loginSub">Administrator Sign In</p>
    <form onsubmit="loginAdmin(event)">
      <div class="field"><label id="lblUser">Username</label><input id="loginUser" autocomplete="username" required placeholder="Username"></div>
      <div class="field"><label id="lblPass">Password</label><input id="loginPass" type="password" autocomplete="current-password" required placeholder="Password"></div>
      <div id="loginError" class="lerr"></div>
      <button class="btn primary" id="btnSignIn">Sign in</button>
    </form>
  </div>
</div>

<div class="shell" id="adminApp" style="display:none">
  <aside class="side" id="rail">
    <div class="brand"><i><svg viewBox="0 0 24 24"><path d="M12 2.8 20.5 7.4v9.2L12 21.2l-8.5-4.6V7.4L12 2.8Z"/><path d="m8 12 2.5 2.5L16.5 8.5"/></svg></i><div><b>DARKIOS</b><small>Admin Console</small></div></div>
    <nav class="nav">
      <button class="active" data-view="api"><svg viewBox="0 0 24 24"><circle cx="8" cy="15.5" r="3.5"/><path d="m10.5 13 8-8 2 2-2 2 1.5 1.5-2 2-1.5-1.5-3 3"/></svg><span id="nApi">API Keys</span></button>
      <button data-view="generator"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg><span id="nGen">Key Generator</span></button>
      <button data-view="banned"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="m5.6 5.6 12.8 12.8"/></svg><span id="nBan">Banned Keys</span></button>
      <button data-view="settings"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 1 1-4 0v-.09a1.65 1.65 0 0 0-1-1.51 1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 1 1 0-4h.09a1.65 1.65 0 0 0 1.51-1 1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 1 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9c.26.6.77 1.02 1.4 1.14H21a2 2 0 1 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1Z"/></svg><span id="nSet">Settings</span></button>
    </nav>
    <div class="side-foot"><div class="upd-pill" id="updPill">UPDATE!!! ON</div></div>
  </aside>

  <div class="main">
    <header class="topbar">
      <h2 id="topTitle">API Keys</h2>
      <div class="top-right">
        <select class="btn" id="langSelect" onchange="setLang(this.value)"><option value="en">English</option><option value="tr">Türkçe</option></select>
        <button class="btn" onclick="renderAll()" id="btnRefresh">Refresh</button>
        <button class="btn" onclick="logoutAdmin()" id="btnLogout">Sign out</button>
      </div>
    </header>

    <main class="content">
      <!-- API KEYS -->
      <section class="view active" id="view-api">
        <div class="heading">
          <div><h1 id="h1Api">API Keys</h1><p id="subApi">Manage and monitor generated keys</p></div>
          <button class="btn primary" onclick="openCreate()" id="btnCreateTop">＋ Create API Key</button>
        </div>
        <div class="stats">
          <div class="stat"><span>Total Keys</span><strong id="mTotal">0</strong></div>
          <div class="stat" style="--c:var(--ok)"><span>Active</span><strong id="mActive">0</strong></div>
          <div class="stat" style="--c:var(--warn)"><span>Tester Keys</span><strong id="mService">0</strong></div>
          <div class="stat" style="--c:var(--bad)"><span>Banned Keys</span><strong id="mBanned">0</strong></div>
        </div>
        <div class="panel">
          <div class="panel-head">
            <div class="ptitle"><span id="tblTitle">API Keys</span><span class="count" id="rowCount">0 keys</span></div>
            <div class="filters">
              <input id="search" placeholder="Search name or key..." oninput="renderRows()">
              <select id="statusFilter" onchange="renderRows()"><option value="">Status</option><option value="Active">Active</option><option value="Paused">Paused</option><option value="Expired">Expired</option></select>
              <select id="typeFilter" onchange="renderRows()"><option value="">Type</option><option value="NORMAL">NORMAL</option><option value="TESTER">TESTER</option></select>
              <button class="btn" onclick="resetFilters()" id="btnReset">Reset</button>
            </div>
          </div>
          <div class="tw"><table>
            <thead><tr><th>Name</th><th>Key</th><th>Type</th><th>Status</th><th>Devices</th><th>Time left</th><th>Created</th><th></th></tr></thead>
            <tbody id="rows"></tbody>
          </table></div>
        </div>
      </section>

      <!-- GENERATOR -->
      <section class="view" id="view-generator">
        <div class="heading"><div><h1 id="h1Gen">Key Generator</h1><p id="subGen"></p></div></div>
        <div class="panel" style="padding:20px">
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
          <button class="btn primary" style="margin-top:18px" onclick="generateKeys()">Generate API Key(s)</button>
          <div id="generated" style="margin-top:16px"></div>
        </div>
      </section>

      <!-- BANNED -->
      <section class="view" id="view-banned">
        <div class="heading"><div><h1 id="h1Ban">Banned Keys</h1><p id="subBan">Blocked keys list</p></div><button class="btn primary" onclick="openBan()">＋ Ban key</button></div>
        <div class="panel"><div class="tw"><table style="min-width:600px">
          <thead><tr><th>Key</th><th>Reason</th><th>Date</th><th></th></tr></thead><tbody id="bannedRows"></tbody>
        </table></div></div>
      </section>

      <!-- SETTINGS -->
      <section class="view" id="view-settings">
        <div class="heading"><div><h1 id="h1Set">Settings</h1><p id="subSet">System controls, UPDATE switch and backup</p></div></div>
        <div class="sgrid">
          <div class="card hot">
            <h3>UPDATE!!!</h3>
            <p id="updateDesc"></p>
            <div class="switch-row"><b id="updateStatusText">OFF</b>
              <label class="switch"><input type="checkbox" id="updateToggle" onchange="toggleUpdateMode(this.checked)"><span class="slider"></span></label></div>
            <div id="updateBadgeWrap"></div>
          </div>
          <div class="card"><h3>Backup &amp; Export</h3><p>Export keys to TXT or JSON backup.</p>
            <button class="btn" onclick="exportTxt()">Download keys.txt</button><button class="btn" onclick="backupJson()">Download JSON</button></div>
          <div class="card"><h3>Import Keys</h3><p>Import keys from TXT or restore JSON.</p>
            <label class="btn">Import TXT<input type="file" accept=".txt,text/plain" hidden onchange="importTxt(this.files[0]);this.value=''"></label>
            <label class="btn">Restore JSON<input type="file" accept=".json" hidden onchange="restoreJson(this.files[0])"></label></div>
          <div class="card"><h3>Reset All Keys</h3><p>Delete all keys and active device sessions.</p>
            <button class="btn danger" onclick="clearAllKeys()">Clear all keys</button></div>
        </div>
      </section>
    </main>
  </div>
</div>

<div class="modal-bg" id="modalBg" onclick="if(event.target===this)closeModal()">
  <div class="modal"><div class="modal-top"><h2 id="modalTitle">Action</h2><button class="x" onclick="closeModal()" aria-label="Close">×</button></div><div id="modalBody"></div></div>
</div>
<div class="toast" id="toast"></div>

<script>
const $=s=>document.querySelector(s),uid=()=>Math.random().toString(36).slice(2,10)+Date.now().toString(36).slice(-4);
const RANDOM_TOKEN_LEN=16;
let records=JSON.parse(localStorage.getItem('darkios_keys_v4')||'[]');
let banned=JSON.parse(localStorage.getItem('darkios_banned_v4')||'[]');
let deviceSessions=JSON.parse(localStorage.getItem('darkios_devices_v4')||'[]');
let updateModeOn=JSON.parse(localStorage.getItem('darkios_update_mode_v4')||'false');
let currentLang=localStorage.getItem('darkios_lang_v4')||'en';

const i18n={
  en:{api:'API Keys',generator:'Key Generator',banned:'Banned Keys',settings:'Settings',
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
    updateOffDesc:'When ON, pauses all active keys. When OFF, restores only keys paused by UPDATE!!! (manually paused keys stay paused).'},
  tr:{api:'API Anahtarları',generator:'Anahtar Oluşturucu',banned:'Yasaklı Anahtarlar',settings:'Ayarlar',
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
    updateOffDesc:'Açıldığında tüm aktif anahtarları durdurur. Kapatıldığında yalnızca UPDATE!!! ile durdurulanları geri açar (manuel durdurulanlar durur).'}
};
const t=k=>(i18n[currentLang]||i18n.en)[k]||i18n.en[k]||k;

function setLang(l){currentLang=i18n[l]?l:'en';localStorage.setItem('darkios_lang_v4',currentLang);applyLang();renderAll()}
function applyLang(){
  document.documentElement.lang=currentLang;$('#langSelect').value=currentLang;
  const m={loginSub:'loginSub',lblUser:'user',lblPass:'pass',btnSignIn:'signIn',btnRefresh:'refresh',btnLogout:'logout',h1Api:'api',subApi:'subApi',btnCreateTop:'create',tblTitle:'api',btnReset:'reset',h1Gen:'generator',subGen:'subGen',h1Ban:'banned',subBan:'subBan',h1Set:'settings',subSet:'subSet',nApi:'api',nGen:'generator',nBan:'banned',nSet:'settings'};
  for(const id in m)$('#'+id).textContent=t(m[id]);
  const v=document.querySelector('.view.active')?.id.replace('view-','')||'api';
  $('#topTitle').textContent=t(v);
}
function persist(){
  localStorage.setItem('darkios_keys_v4',JSON.stringify(records));
  localStorage.setItem('darkios_banned_v4',JSON.stringify(banned));
  localStorage.setItem('darkios_devices_v4',JSON.stringify(deviceSessions));
  localStorage.setItem('darkios_update_mode_v4',JSON.stringify(updateModeOn));
}
function notify(msg){const el=$('#toast');el.textContent=msg;el.classList.add('show');setTimeout(()=>el.classList.remove('show'),2200)}
function esc(s){return String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]))}

function go(v){
  document.querySelectorAll('.view').forEach(x=>x.classList.remove('active'));
  $('#view-'+v).classList.add('active');
  document.querySelectorAll('.nav button').forEach(x=>x.classList.toggle('active',x.dataset.view===v));
  $('#topTitle').textContent=t(v);renderAll();
}
$('#rail').addEventListener('click',e=>{const b=e.target.closest('button[data-view]');if(b)go(b.dataset.view)});

function loginAdmin(e){
  e.preventDefault();
  if($('#loginUser').value==='dark'&&$('#loginPass').value==='wear5555'){
    sessionStorage.setItem('darkios_auth','1');
    $('#loginScreen').style.display='none';$('#adminApp').style.display='flex';$('#loginError').textContent='';notify('OK');
  }else $('#loginError').textContent=t('badLogin');
}
function logoutAdmin(){sessionStorage.removeItem('darkios_auth');$('#adminApp').style.display='none';$('#loginScreen').style.display='grid';$('#loginPass').value=''}

function durationToMs(unit,val){
  if(unit==='LIFETIME')return null;
  const n=Math.max(1,+val||1);
  return n*({HOUR:3600000,DAY:86400000,WEEK:604800000,MONTH:2592000000,YEAR:31536000000}[unit]||86400000);
}
function buildDurationSegment(unit,val){
  if(unit==='LIFETIME')return 'LIFETIME';
  const n=Math.max(1,+val||1);
  const s={HOUR:'HOUR',DAY:'DAY',WEEK:'WEEK',MONTH:'MONTH',YEAR:'YEAR'}[unit]||'DAY';
  return `${n}${n===1?s:s+'S'}`;
}
function randomAlphaNum(len=RANDOM_TOKEN_LEN){
  const c='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',b=new Uint8Array(len);
  crypto.getRandomValues(b);let o='';for(let i=0;i<len;i++)o+=c[b[i]%c.length];return o;
}
// NORMAL: DARKIOS-<DURATION>-XXXXXXXXXXXXXXXX | TESTER: DARKIOS-TESTER-<DURATION>-XXXXXXXXXXXXXXXX
function buildKeyValue({type,prefix,unit,val,customKey}){
  const ck=(customKey||'').trim();if(ck)return ck;
  const p=((prefix||'DARKIOS').trim()||'DARKIOS').toUpperCase();
  const dur=buildDurationSegment(unit,val),token=randomAlphaNum();
  return type==='TESTER'?`${p}-TESTER-${dur}-${token}`:`${p}-${dur}-${token}`;
}

function checkStates(){
  let changed=false;const now=Date.now();
  records.forEach(r=>{
    if(r.pauseType==='temp'&&r.pauseUntil&&r.pauseUntil<=now){r.pauseType=null;r.pauseUntil=null;r.status='Active';changed=true}
    if(r.startedAt&&r.durationMs&&r.status==='Active'&&(r.startedAt+r.durationMs)<=now){r.status='Expired';changed=true}
  });
  if(changed)persist();
}
function timeLeftText(r){
  if(!r.durationMs)return 'LIFETIME';
  if(!r.startedAt)return t('waitingDevice');
  const rem=(r.startedAt+r.durationMs)-Date.now();
  if(rem<=0)return t('expired');
  let s=Math.floor(rem/1000);const d=Math.floor(s/86400);s%=86400;
  const h=Math.floor(s/3600);s%=3600;const m=Math.floor(s/60);s%=60;
  return `${d}d ${h}h ${m}m ${s}s`;
}
function statusBadgeText(r){
  if(r.status==='Paused')return r.pauseType==='update'?t('pausedUpdate'):r.pauseType==='temp'?t('pausedTemp'):t('pausedManual');
  if(r.status==='Expired')return t('expired');
  return 'Active';
}

function renderRows(){
  checkStates();
  const q=$('#search').value.toLowerCase(),st=$('#statusFilter').value,ty=$('#typeFilter').value;
  const arr=records.filter(r=>(!q||(r.name||'').toLowerCase().includes(q)||r.key.toLowerCase().includes(q))&&(!st||r.status===st)&&(!ty||r.type===ty));
  $('#rowCount').textContent=arr.length+' keys';
  $('#rows').innerHTML=arr.map(r=>{
    const active=deviceSessions.filter(d=>d.keyId===r.id&&d.status==='Active').length;
    const limit=r.deviceLimit===0?'∞':(r.deviceLimit||1);
    return `<tr>
      <td><div class="nm">${esc(r.name||'Key')}</div><div class="ds">${esc(r.description||'—')}</div></td>
      <td><span class="key" title="Copy" onclick="copyKey('${r.id}')">${esc(r.key)}</span></td>
      <td><span class="chip ${r.type==='TESTER'?'t':''}">${esc(r.type||'NORMAL')}</span></td>
      <td><span class="chip ${esc((r.status||'').toLowerCase())}">${esc(statusBadgeText(r))}</span></td>
      <td>${active} / ${limit}</td><td>${esc(timeLeftText(r))}</td><td>${esc(r.created||'')}</td>
      <td><button class="dots" onclick="rowMenu('${r.id}')" aria-label="Actions">⋮</button></td></tr>`;
  }).join('')||`<tr><td colspan="8" class="blank">${esc(t('noKeys'))}</td></tr>`;
  $('#mTotal').textContent=records.length;
  $('#mActive').textContent=records.filter(r=>r.status==='Active').length;
  $('#mService').textContent=records.filter(r=>r.type==='TESTER').length;
  $('#mBanned').textContent=banned.length;
}

function renderUpdateUI(){
  $('#updateToggle').checked=!!updateModeOn;
  $('#updateStatusText').textContent=updateModeOn?'ON':'OFF';
  $('#updateStatusText').style.color=updateModeOn?'var(--warn)':'var(--text)';
  $('#updateDesc').textContent=updateModeOn?t('updateOnDesc'):t('updateOffDesc');
  $('#updPill').classList.toggle('on',!!updateModeOn);
  const n=records.filter(r=>r.status==='Paused'&&r.pauseType==='update').length;
  $('#updateBadgeWrap').innerHTML=updateModeOn?`<div class="badge">UPDATE!!! ACTIVE · ${n} key(s) paused</div>`:'';
}
function toggleUpdateMode(on){
  let c=0;
  if(on){
    updateModeOn=true;
    records.forEach(r=>{if(r.status==='Active'){r.status='Paused';r.pauseType='update';r.pauseUntil=null;c++}});
    persist();renderAll();notify(`UPDATE!!! ON (${c})`);
  }else{
    updateModeOn=false;
    records.forEach(r=>{if(r.status==='Paused'&&r.pauseType==='update'){r.pauseType=null;r.pauseUntil=null;r.status=(r.startedAt&&r.durationMs&&(r.startedAt+r.durationMs<=Date.now()))?'Expired':'Active';c++}});
    persist();renderAll();notify(`UPDATE!!! OFF (${c})`);
  }
}

function resetFilters(){$('#search').value='';$('#statusFilter').value='';$('#typeFilter').value='';renderRows()}
function modal(title,body){$('#modalTitle').textContent=title;$('#modalBody').innerHTML=body;$('#modalBg').classList.add('open')}
function closeModal(){$('#modalBg').classList.remove('open')}
document.addEventListener('keydown',e=>{if(e.key==='Escape')closeModal()});

function showTurkishInfo(topic){
  const infos={
    addTime:['Zaman Ekleme (+)','Seçili anahtarın süresine istediğin miktarda dakika, saat veya gün ekler. Süresi dolmuş bir anahtara zaman eklersen yeniden aktif hale gelir.'],
    subTime:['Zaman Çıkarma (-)','Seçili anahtarın kalan süresinden girdiğin miktarda dakika, saat veya gün düşürür. Süre sıfırlanırsa anahtar süresi dolmuş (Expired) duruma geçer.'],
    addDevice:['Cihaz Sınırı Ekleme (+)','Anahtara bağlanabilecek maksimum cihaz/IP sayısını girdiğin sayı kadar artırır.'],
    subDevice:['Cihaz Sınırı Çıkarma (-)','Anahtarın maksimum cihaz/IP limitini girdiğin sayı kadar azaltır (en az 1 olarak kalır).']
  };
  const i=infos[topic]||['Bilgi','İşlem açıklaması.'];
  modal(i[0],`<p style="margin:0;font-size:13px;line-height:1.6">${esc(i[1])}</p><div class="modal-actions"><button class="btn primary" onclick="closeModal()">Tamam</button></div>`);
}

function openCreate(){
  modal('Create API Key',`<form onsubmit="createRecord(event)"><div class="formgrid">
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
  <div class="modal-actions"><button type="button" class="btn" onclick="closeModal()">Cancel</button><button class="btn primary">Create API Key</button></div></form>`);
}
function toggleModalDuration(){const l=$('#newDurationUnit').value==='LIFETIME';$('#newDurationValue').disabled=l;$('#newDurationValue').style.opacity=l?'.4':'1'}
function toggleGenDuration(){const l=$('#genDurationUnit').value==='LIFETIME';$('#genDurationValue').disabled=l;$('#genDurationValue').style.opacity=l?'.4':'1'}

function newRecord(o){
  return {id:uid(),name:o.name,description:o.desc,type:o.type,status:updateModeOn?'Paused':'Active',pauseType:updateModeOn?'update':null,pauseUntil:null,
    deviceLimit:o.deviceLimit,created:new Date().toISOString().slice(0,16).replace('T',' '),key:o.key,durationMs:o.durationMs,startedAt:null};
}
function createRecord(e){
  e.preventDefault();
  const type=$('#newType').value,unit=$('#newDurationUnit').value,val=$('#newDurationValue').value;
  const r=newRecord({name:($('#newName').value||'').trim()||'Key',desc:($('#newDesc').value||'').trim()||'—',type,
    deviceLimit:+($('#newDeviceLimit').value||1),durationMs:durationToMs(unit,val),
    key:buildKeyValue({type,prefix:$('#newPrefix').value,unit,val,customKey:$('#newCustomKey').value})});
  records.unshift(r);persist();closeModal();renderAll();notify('OK');
  modal('Key Created',`<input class="key" style="width:100%;padding:11px" id="createdKey" value="${esc(r.key)}" readonly>
    <div class="modal-actions"><button class="btn" onclick="navigator.clipboard?.writeText($('#createdKey').value);notify('Copied')">Copy</button><button class="btn primary" onclick="closeModal()">Done</button></div>`);
}

function rowMenu(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  const lim=r.deviceLimit===0?'Unlimited':(r.deviceLimit||1);
  modal('Key Actions',`
    <div class="meta"><strong>${esc(r.key)}</strong>
      <div>Status: ${esc(statusBadgeText(r))} · Limit: ${esc(lim)} · Time: ${esc(timeLeftText(r))}</div></div>
    <div class="act-list">
      <button class="act" onclick="copyKey('${id}')"><span>Copy Key</span><small>Copy</small></button>
      <button class="act" onclick="simulateConnect('${id}')"><span>Simulate Device Connect</span><small>Start Timer</small></button>
      <div class="act-group">Time</div>
      <div class="row2"><button class="act" onclick="customTimeModal('${id}','add')"><span>+ Add Custom Time</span><small>Custom</small></button><button class="info" title="Info" onclick="showTurkishInfo('addTime')">i</button></div>
      <div class="row2"><button class="act" onclick="customTimeModal('${id}','sub')"><span>- Remove Custom Time</span><small>Custom</small></button><button class="info" title="Info" onclick="showTurkishInfo('subTime')">i</button></div>
      <div class="act-group">Devices</div>
      <div class="row2"><button class="act" onclick="customDeviceModal('${id}','add')"><span>+ Add Custom Device Limit</span><small>Custom</small></button><button class="info" title="Info" onclick="showTurkishInfo('addDevice')">i</button></div>
      <div class="row2"><button class="act" onclick="customDeviceModal('${id}','sub')"><span>- Remove Custom Device Limit</span><small>Custom</small></button><button class="info" title="Info" onclick="showTurkishInfo('subDevice')">i</button></div>
      <div class="act-group">State</div>
      ${r.status==='Paused'
        ?`<button class="act" onclick="resumeKey('${id}')"><span>Resume Key</span><small>Active</small></button>`
        :`<button class="act" onclick="pauseIndefinite('${id}')"><span>Pause Key (Manual)</span><small>Stop</small></button>
          <button class="act" onclick="pauseTimedModal('${id}')"><span>Pause Key (Timed)</span><small>Timer</small></button>`}
      <button class="act danger" onclick="banRecord('${id}')"><span>Ban Key</span><small>Ban</small></button>
      <button class="act danger" onclick="deleteRecord('${id}')"><span>Delete Key</span><small>Delete</small></button>
    </div>`);
}

function copyKey(id){const r=records.find(x=>x.id===id);if(r){navigator.clipboard?.writeText(r.key);notify('Copied')}}

function simulateConnect(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  if(!r.startedAt){r.startedAt=Date.now();notify('Timer started')}
  deviceSessions.unshift({id:uid(),keyId:id,ip:'192.168.1.'+(Math.floor(Math.random()*200)+10),status:'Active',at:new Date().toLocaleString()});
  persist();renderAll();rowMenu(id);
}
function customDeviceModal(id,mode){
  modal(mode==='add'?'+ Add Custom Device Limit':'- Remove Custom Device Limit',`
    <div class="field"><label>Custom device count</label><input id="customDevAmt" type="number" min="1" value="1"></div>
    <div class="modal-actions"><button class="btn" onclick="rowMenu('${id}')">Back</button><button class="btn primary" onclick="applyCustomDevice('${id}','${mode}')">Apply</button></div>`);
}
function applyCustomDevice(id,mode){
  const r=records.find(x=>x.id===id);if(!r)return;
  const amt=Math.max(1,+$('#customDevAmt').value||1),cur=r.deviceLimit===0?1:(r.deviceLimit||1);
  r.deviceLimit=mode==='add'?(cur+amt):Math.max(1,cur-amt);
  persist();renderAll();rowMenu(id);notify(`Devices: ${r.deviceLimit}`);
}
function customTimeModal(id,mode){
  modal(mode==='add'?'+ Add Custom Time':'- Remove Custom Time',`
    <div class="formgrid"><div class="field"><label>Custom amount</label><input id="adjAmt" type="number" min="1" value="1"></div>
    <div class="field"><label>Unit</label><select id="adjUnit"><option value="m">Minutes</option><option value="h" selected>Hours</option><option value="D">Days</option></select></div></div>
    <div class="modal-actions"><button class="btn" onclick="rowMenu('${id}')">Back</button><button class="btn primary" onclick="applyTimeAdjust('${id}','${mode}')">Apply</button></div>`);
}
function applyTimeAdjust(id,mode){
  const r=records.find(x=>x.id===id);if(!r)return;
  const amt=Math.max(1,+$('#adjAmt').value||1),u=$('#adjUnit').value;
  const delta=amt*(u==='m'?60000:u==='h'?3600000:86400000);
  if(!r.durationMs){
    if(mode==='add'){r.startedAt=r.startedAt||Date.now();r.durationMs=delta}
  }else if(mode==='add'){
    r.durationMs+=delta;
    if(r.status==='Expired'&&(r.startedAt||Date.now())+r.durationMs>Date.now())r.status='Active';
  }else{
    r.durationMs=Math.max(0,r.durationMs-delta);
    if(r.startedAt&&(r.startedAt+r.durationMs)<=Date.now())r.status='Expired';
  }
  persist();renderAll();rowMenu(id);notify('Updated');
}
function pauseIndefinite(id){const r=records.find(x=>x.id===id);if(!r)return;r.status='Paused';r.pauseType='manual';r.pauseUntil=null;persist();renderAll();closeModal();notify('Paused')}
function pauseTimedModal(id){
  modal('Pause Key (Timed)',`
    <div class="formgrid"><div class="field"><label>Amount</label><input id="pAmt" type="number" min="1" value="1"></div>
    <div class="field"><label>Unit</label><select id="pUnit"><option value="m">Minutes</option><option value="h" selected>Hours</option><option value="D">Days</option></select></div></div>
    <div class="modal-actions"><button class="btn" onclick="rowMenu('${id}')">Back</button><button class="btn primary" onclick="applyTimedPause('${id}')">Pause</button></div>`);
}
function applyTimedPause(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  const amt=Math.max(1,+$('#pAmt').value||1),u=$('#pUnit').value;
  r.status='Paused';r.pauseType='temp';r.pauseUntil=Date.now()+amt*(u==='m'?60000:u==='h'?3600000:86400000);
  persist();renderAll();closeModal();notify('Temp paused');
}
function resumeKey(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  r.pauseType=null;r.pauseUntil=null;
  r.status=(r.startedAt&&r.durationMs&&(r.startedAt+r.durationMs<=Date.now()))?'Expired':'Active';
  persist();renderAll();closeModal();notify('Resumed');
}
function banRecord(id){
  const r=records.find(x=>x.id===id);if(!r)return;
  banned.unshift({id:uid(),key:r.key,reason:'Banned by admin',date:new Date().toLocaleString()});
  records=records.filter(x=>x.id!==id);persist();renderAll();closeModal();notify('Banned');
}
function deleteRecord(id){records=records.filter(x=>x.id!==id);persist();renderAll();closeModal();notify('Deleted')}

function generateKeys(){
  const n=Math.max(1,Math.min(100,+$('#genCount').value||1));
  const name=($('#genName').value||'').trim()||'Key',desc=($('#genDesc').value||'').trim()||'—';
  const type=$('#genType').value,unit=$('#genDurationUnit').value,val=$('#genDurationValue').value;
  const prefix=$('#genPrefix').value,customKey=$('#genCustomKey').value,durationMs=durationToMs(unit,val),out=[];
  for(let i=0;i<n;i++){
    const key=buildKeyValue({type,prefix,unit,val,customKey:(n===1&&customKey.trim())?customKey:''});
    records.unshift(newRecord({name,desc,type,deviceLimit:+$('#genDevices').value,durationMs,key}));out.push(key);
  }
  persist();
  $('#generated').innerHTML=`<textarea class="key" style="width:100%;height:110px;padding:11px" readonly>${esc(out.join('\n'))}</textarea>
    <button class="btn" style="margin-top:8px" onclick="navigator.clipboard?.writeText(${esc(JSON.stringify(out.join('\n')))});notify('Copied')">Copy all</button>`;
  renderAll();
}

function openBan(){
  modal('Ban API Key',`<form onsubmit="banManual(event)">
    <div class="field"><label>API Key</label><input id="banValue" required></div>
    <div class="field" style="margin-top:10px"><label>Reason</label><input id="banReason" placeholder="Reason"></div>
    <div class="modal-actions"><button class="btn primary">Ban key</button></div></form>`);
}
function banManual(e){
  e.preventDefault();const k=$('#banValue').value.trim();
  banned.unshift({id:uid(),key:k,reason:($('#banReason').value||'').trim()||'Banned',date:new Date().toLocaleString()});
  records=records.filter(r=>r.key!==k);persist();renderAll();closeModal();notify('Banned');
}
function renderBanned(){
  $('#bannedRows').innerHTML=banned.map(b=>`<tr><td><span class="key">${esc(b.key)}</span></td><td>${esc(b.reason)}</td><td>${esc(b.date)}</td>
    <td><button class="btn" onclick="unban('${b.id}')">Unban</button></td></tr>`).join('')||`<tr><td colspan="4" class="blank">—</td></tr>`;
}
function unban(id){banned=banned.filter(x=>x.id!==id);persist();renderAll()}
function clearAllKeys(){records=[];deviceSessions=[];updateModeOn=false;persist();renderAll();notify('Cleared')}

function exportTxt(){const l=records.map(r=>r.key);download('api-keys.txt',l.join('\n')+(l.length?'\n':''),'text/plain')}
function importTxt(file){
  if(!file)return;const rd=new FileReader();
  rd.onload=()=>{
    let added=0;
    String(rd.result).split(/\r?\n/).map(x=>x.trim()).filter(Boolean).forEach(key=>{
      if(records.some(r=>r.key===key))return;
      records.unshift(newRecord({name:'Key',desc:'—',type:'NORMAL',deviceLimit:1,durationMs:null,key}));added++;
    });
    persist();renderAll();notify(`+${added}`);
  };rd.readAsText(file);
}
function backupJson(){download('darkios-backup.json',JSON.stringify({records,banned,updateModeOn},null,2),'application/json')}
function restoreJson(file){
  if(!file)return;const rd=new FileReader();
  rd.onload=()=>{try{const d=JSON.parse(rd.result);records=d.records||[];banned=d.banned||[];updateModeOn=!!d.updateModeOn;persist();renderAll();notify('Restored')}catch{notify('Invalid JSON')}};
  rd.readAsText(file);
}
function download(name,data,type){const a=document.createElement('a'),u=URL.createObjectURL(new Blob([data],{type}));a.href=u;a.download=name;a.click();URL.revokeObjectURL(u)}

function renderAll(){renderRows();renderBanned();renderUpdateUI()}
applyLang();renderAll();
setInterval(()=>{if($('#adminApp').style.display!=='none'){renderRows();renderUpdateUI()}},1000);
if(sessionStorage.getItem('darkios_auth')==='1'){$('#loginScreen').style.display='none';$('#adminApp').style.display='flex'}
</script>
</body>
</html>