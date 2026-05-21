/* jn-idgun | NUI Script — ByJanni */
'use strict';

const panel       = document.getElementById('idgun-panel');
const entityBadge = document.getElementById('entity-badge');
const scanDot     = document.getElementById('scan-dot');

// Row groups
const rowsBase    = document.getElementById('rows-base');
const rowsHealth  = document.getElementById('rows-health');
const rowsPlayer  = document.getElementById('rows-player');
const rowsVehicle = document.getElementById('rows-vehicle');
const divHealth   = document.getElementById('div-health');
const divPlayer   = document.getElementById('div-player');
const divVehicle  = document.getElementById('div-vehicle');

const noEntityMsg   = document.getElementById('no-entity-msg');
const outOfRangeMsg = document.getElementById('out-of-range-msg');
const historySection = document.getElementById('history-section');
const historyList    = document.getElementById('history-list');
const historyCount   = document.getElementById('history-count');
const copyBtn        = document.getElementById('copy-btn');
const targetDot      = document.getElementById('target-dot');

let currentType  = null;
let panelVisible = false;

// ── Target Dot ────────────────────────────────────

function showDot(x, y) {
    targetDot.style.left = (x * 100) + 'vw';
    targetDot.style.top  = (y * 100) + 'vh';
    targetDot.classList.add('visible');
}

function hideDot() {
    targetDot.classList.remove('visible');
}

// ── Helpers ───────────────────────────────────────

function setVal(id, text) {
    const el = document.getElementById(id);
    if (el && el.textContent !== text) el.textContent = text;
}

function setHtml(id, html) {
    const el = document.getElementById(id);
    if (el) el.innerHTML = html;
}

function show(el)  { el.classList.remove('hidden'); }
function hide(el)  { el.classList.add('hidden'); }

function setBar(barId, pct) {
    const el = document.getElementById(barId);
    if (!el) return;
    el.style.setProperty('--pct', Math.max(0, Math.min(100, pct)) + '%');
    if (barId === 'bar-health') {
        el.classList.toggle('low',    pct < 25);
        el.classList.toggle('medium', pct >= 25 && pct < 60);
    }
}

function parsePct(str) {
    if (!str) return 0;
    const n = parseInt(str, 10);
    return isNaN(n) ? 0 : n;
}

function wantedStars(level) {
    level = Math.max(0, Math.min(5, level || 0));
    return '<span class="wanted-star-full">' + '★'.repeat(level) + '</span>'
         + '<span class="wanted-star-empty">' + '☆'.repeat(5 - level) + '</span>';
}

function typeBadgeClass(type) {
    const map = { player: 'player', vehicle: 'vehicle', object: 'object', ped: 'ped' };
    return map[type] || 'idle';
}

function typeBadgeLabel(type) {
    const map = { player: 'PLAYER', vehicle: 'VEHICLE', object: 'OBJECT', ped: 'PED' };
    return map[type] || '—';
}

function badgeColor(type) {
    entityBadge.className = 'entity-badge ' + typeBadgeClass(type);
    entityBadge.textContent = typeBadgeLabel(type);
}

// ── Panel State ───────────────────────────────────

function showPanel() {
    panelVisible = true;
    panel.classList.add('visible');
    resetToIdle();
}

function hidePanel() {
    panelVisible = false;
    panel.classList.remove('visible');
}

function resetToIdle() {
    scanDot.className = 'scan-dot idle';
    entityBadge.className = 'entity-badge idle';
    entityBadge.textContent = '—';
    hide(rowsBase);
    hide(rowsHealth);
    hide(rowsPlayer);
    hide(rowsVehicle);
    hide(divHealth);
    hide(divPlayer);
    hide(divVehicle);
    hide(outOfRangeMsg);
    show(noEntityMsg);
    panel.classList.remove('frozen-mode');
    hideDot();
    currentType = null;
}

function freezePanel() {
    scanDot.className = 'scan-dot frozen';
    panel.classList.add('frozen-mode');
    hideDot();
}

// ── Update Panel ──────────────────────────────────

function updatePanel(data) {
    hide(noEntityMsg);
    hide(outOfRangeMsg);
    scanDot.className = 'scan-dot';

    badgeColor(data.type);

    // Base rows
    show(rowsBase);
    setVal('val-model',   data.model   || '—');
    setVal('val-hash',    '#' + (data.hash || '?'));
    setVal('val-coords',  data.coords  || '—');
    setVal('val-heading', data.heading || '—');
    setVal('val-distance', data.distance || '—');

    const isPlayerLike = data.type === 'ped' || data.type === 'player';
    const isVehicle    = data.type === 'vehicle';
    const isPlayer     = data.type === 'player';

    // Health/Armor
    if (isPlayerLike && (data.health || data.armor)) {
        show(divHealth);
        show(rowsHealth);
        if (data.health) {
            setVal('val-health', data.health);
            setBar('bar-health', parsePct(data.health));
        }
        if (data.armor) {
            setVal('val-armor', data.armor);
            setBar('bar-armor', parsePct(data.armor));
        }
    } else {
        hide(divHealth);
        hide(rowsHealth);
    }

    // Player rows
    if (isPlayer) {
        show(divPlayer);
        show(rowsPlayer);
        setVal('val-serverid',   '#' + (data.serverid   || '?'));
        setVal('val-playername', data.playername || '—');
        setVal('val-job',        data.job        || '...');
        setHtml('val-wanted',    wantedStars(data.wanted));
        setVal('val-ping',       data.ping || '—');
    } else {
        hide(divPlayer);
        hide(rowsPlayer);
    }

    // Vehicle rows
    if (isVehicle) {
        show(divVehicle);
        show(rowsVehicle);
        setVal('val-plate', data.plate || '—');
        if (data.fuel) {
            setVal('val-fuel', data.fuel);
            setBar('bar-fuel', parsePct(data.fuel));
        }
        if (data.driver) {
            setVal('val-driver', data.driver + ' (#' + data.driverid + ')');
        } else {
            setVal('val-driver', 'No driver');
        }
    } else {
        hide(divVehicle);
        hide(rowsVehicle);
    }

    currentType = data.type;
    panel.classList.remove('frozen-mode');

    // Show / position target dot
    if (data.dotX !== undefined && data.dotY !== undefined) {
        showDot(data.dotX, data.dotY);
    } else {
        hideDot();
    }
}

function updateExtra(job) {
    if (currentType === 'player' && job) {
        setVal('val-job', job);
    }
}

// ── History ───────────────────────────────────────

function renderHistory(history) {
    if (!history || history.length === 0) {
        historyList.innerHTML = '<div style="padding:6px 12px;color:var(--text-2);font-size:9px">No scans yet</div>';
        historyCount.textContent = '0';
        return;
    }

    historyCount.textContent = history.length;
    historyList.innerHTML = history.map(item => {
        const cls   = typeBadgeClass(item.type);
        const label = typeBadgeLabel(item.type);
        const model = (item.model || '').substring(0, 22);
        return `<div class="history-item">
            <span class="history-type entity-badge ${cls}">${label}</span>
            <span class="history-model">${model}</span>
            <span class="history-time">${item.timestamp || ''}</span>
        </div>`;
    }).join('');
}

function toggleHistory(open, history) {
    if (open) {
        show(historySection);
        renderHistory(history);
    } else {
        hide(historySection);
    }
}

// ── Copy Feedback ─────────────────────────────────

function doCopyFeedback(coordsStr, history) {
    copyBtn.classList.add('copied');
    copyBtn.textContent = '✓';
    setTimeout(() => {
        copyBtn.classList.remove('copied');
        copyBtn.textContent = '⎘';
    }, 1500);

    if (history) renderHistory(history);
}

// ── Copy Button (in-panel) ────────────────────────

copyBtn.addEventListener('click', () => {
    // Trigger copy via Lua (F8 console print)
    // Since NUI has no focus, we can't use clipboard API.
    // The Lua command idgun_copy handles the actual copy.
    copyBtn.classList.add('copied');
    setTimeout(() => copyBtn.classList.remove('copied'), 1500);
});

// ── Message Listener ──────────────────────────────

window.addEventListener('message', (event) => {
    const msg = event.data;
    if (!msg || !msg.action) return;

    switch (msg.action) {

        case 'show':
            showPanel();
            break;

        case 'hide':
            hidePanel();
            break;

        case 'update':
            if (!panelVisible) break;
            updatePanel(msg.data);
            if (msg.history) renderHistory(msg.history);
            break;

        case 'frozen':
            if (!panelVisible) break;
            freezePanel();
            break;

        case 'updateExtra':
            if (!panelVisible) break;
            updateExtra(msg.job);
            if (msg.history) renderHistory(msg.history);
            break;

        case 'idle':
            if (!panelVisible) break;
            resetToIdle();
            break;

        case 'outOfRange':
            if (!panelVisible) break;
            scanDot.className = 'scan-dot idle';
            hide(noEntityMsg);
            hide(rowsBase);
            hide(rowsHealth);
            hide(rowsPlayer);
            hide(rowsVehicle);
            hide(divHealth);
            hide(divPlayer);
            hide(divVehicle);
            show(outOfRangeMsg);
            break;

        case 'copyFeedback':
            doCopyFeedback(msg.coords, msg.history);
            break;

        case 'toggleHistory':
            toggleHistory(msg.open, msg.history);
            break;
    }
});

// Signal ready
fetch('https://jn-idgun/ready', { method: 'POST', body: JSON.stringify({}) }).catch(() => {});
