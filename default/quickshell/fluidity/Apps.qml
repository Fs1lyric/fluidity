pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// The Fluid showcase apps' brain: data for each app's island view (views/*App.qml) and its keys.
// Island.qml opens them like any view and hands their keys here (key() returns true when used).
Singleton {
    id: apps
    readonly property var views: ["calendar", "media", "network", "bluetooth"]
    property string open: ""       // the app on screen, "" when none (polling runs only then)
    property var data: ({})
    // leader ; u: one letter per app
    readonly property var leaderKeys: [{ k: "c", label: "calendar", open: "calendar" }, { k: "m", label: "media", open: "media" }, { k: "w", label: "wi-fi", open: "network" }, { k: "b", label: "bluetooth", open: "bluetooth" }]
    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (home + "/.local/state")) + "/fluidity"
    readonly property string calDb: home + "/.local/share/calendio/cal.db"
    function patch(o) { const n = Object.assign({}, data); for (const k in o) n[k] = o[k]; data = n; }
    function iso(dt) { return Qt.formatDate(dt, "yyyy-MM-dd") }

    function load(v, arg) {
        data = ({}); open = v;
        if (v === "calendar") calOpen(arg);
        else if (v === "media") { Island.index = 1; mediaTick(); }
        else if (v === "network") { netAsk = ""; netSecret = ""; netRefresh(); }
        else if (v === "bluetooth") btRefresh();
    }
    function key(event, v) {
        if (v === "calendar") return calKey(event);
        if (v === "media") return mediaKey(event);
        if (v === "network") return netKey(event);
        if (v === "bluetooth") return btKey(event);
        return false;
    }
    function picked(v, i) {
        if (v === "calendar") { const c = calCells()[i]; if (c) calGo(c); }
        else if (v === "media") { Island.index = i; mediaPress(i); }
        else if (v === "network") { Island.index = i; netPress(); }
        else if (v === "bluetooth") { Island.index = i; btPress(); }
    }

    readonly property bool shown: Island.overlayShown && Island.target === open
    onShownChanged: if (!shown) open = ""

    // ================= media =================
    readonly property MprisPlayer player: Island.player
    property bool showLyrics: true
    property var bars: []
    property var lyricLines: []      // [{t: seconds, text}]
    property string lyricFor: ""
    function fmt(s) { s = Math.max(0, Math.floor(s || 0)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }
    Timer { interval: 500; repeat: true; running: apps.open === "media"; onTriggered: apps.mediaTick() }
    function mediaTick() {
        const p = player;
        if (!p || !p.trackTitle) { patch({ title: "", bars: [] }); return; }
        p.positionChanged();
        const pos = p.position || 0, len = p.length || 0, key = (p.trackArtist || "") + "\t" + p.trackTitle;
        if (showLyrics && key !== lyricFor) { lyricFor = key; lyricLines = []; lyricProc.command = ["curl", "-fsm", "8", "-G", "https://lrclib.net/api/get",
            "--data-urlencode", "artist_name=" + (p.trackArtist || ""), "--data-urlencode", "track_name=" + p.trackTitle]; lyricProc.running = true; }
        let li = -1;
        for (let i = 0; i < lyricLines.length; i++) if (lyricLines[i].t <= pos + 0.3) li = i;
        const lines = li < 0 ? [] : lyricLines.slice(Math.max(0, li - 1), li + 3).map(l => l.text);
        patch({ title: p.trackTitle, artist: p.trackArtist || "", album: p.trackAlbum || "", art: p.trackArtUrl || "", player: p.identity || "",
                playing: p.isPlaying, position: fmt(pos), length: len > 0 ? fmt(len) : "", progress: len > 0 ? pos / len : 0,
                shuffle: p.shuffleSupported && p.shuffle, loop: p.loopSupported && p.loopState !== MprisLoopState.None, showLyrics: showLyrics,
                lyrics: showLyrics ? lines : [], lyric: li < 1 ? 0 : 1, bars: bars });
    }
    Process {
        id: lyricProc
        stdout: StdioCollector { onStreamFinished: {
            let j = null; try { j = JSON.parse(text) } catch (e) {}
            const synced = j && j.syncedLyrics ? String(j.syncedLyrics).split("\n") : [];
            apps.lyricLines = synced.map(l => { const m = l.match(/^\[(\d+):(\d+(?:\.\d+)?)\]\s*(.*)$/); return m && m[3] ? { t: Number(m[1]) * 60 + Number(m[2]), text: m[3] } : null }).filter(Boolean);
        } }
    }
    // cava: 36 bars as "n;n;...", only while the media app is open
    Process {
        id: cava
        running: apps.open === "media"
        command: ["sh", "-c", "c=${XDG_RUNTIME_DIR:-/tmp}/fluidity-cava.conf; printf '[general]\\nbars = 36\\nframerate = 30\\n[output]\\nmethod = raw\\nraw_target = /dev/stdout\\ndata_format = ascii\\nascii_max_range = 100\\nbar_delimiter = 59\\n' > \"$c\"; exec cava -p \"$c\""]
        stdout: SplitParser { onRead: line => { apps.bars = line.split(";").filter(x => x !== "").map(x => Number(x) / 100); if (apps.open === "media") apps.patch({ bars: apps.bars }); } }
    }
    function mediaPress(i) {
        const p = player;
        if (!p) { Island.close(); Island.sh("fluidity-launch focus spotify spotify"); return; }
        if (i === 0) p.previous(); else if (i === 1) p.togglePlaying(); else if (i === 2) p.next();
        else if (i === 3 && p.shuffleSupported) p.shuffle = !p.shuffle;
        else if (i === 4 && p.loopSupported) p.loopState = p.loopState === MprisLoopState.None ? MprisLoopState.Playlist : MprisLoopState.None;
        else if (i === 5) { showLyrics = !showLyrics; lyricFor = ""; }
        later(150, mediaTick);
    }
    function later(ms, fn) { Island.later(ms, fn) }
    function mediaKey(event) {
        const k = event.key, t = event.text, p = player;
        if (t === " ") mediaPress(1);
        else if (t === "n") mediaPress(2);
        else if (t === "p") mediaPress(0);
        else if (t === "l") mediaPress(5);
        else if (k === Qt.Key_Left || k === Qt.Key_Right) { if (p && p.canSeek) { p.position = Math.max(0, p.position + (k === Qt.Key_Left ? -5 : 5)); mediaTick(); } }
        else if (k === Qt.Key_Tab || k === Qt.Key_Down) Island.index = (Island.index + 1) % 6;
        else if (k === Qt.Key_Backtab || k === Qt.Key_Up) Island.index = (Island.index + 5) % 6;
        else if (k === Qt.Key_Return || k === Qt.Key_Enter) mediaPress(Island.index);
        else return false;
        return true;
    }

    function say(msg) { Island.sh("notify-send -a Fluidity " + Island.q(msg)) }
    // list keys shared by the list apps
    function listMove(event, n) {
        if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) { Island.index = Math.min(Math.max(0, n - 1), Island.index + 1); return true; }
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) { Island.index = Math.max(0, Island.index - 1); return true; }
        return false;
    }
    Timer { interval: 4000; repeat: true; running: apps.open === "network" || apps.open === "bluetooth"
        onTriggered: apps.open === "network" ? apps.netRefresh() : apps.btRefresh() }

    // ================= network (nmcli) =================
    property string netAsk: ""       // the network a password is being typed for
    property string netSecret: ""
    property var nets: []
    function netRefresh() { if (!netProc.running) netProc.running = true }
    // nmcli -t escapes ':' inside fields as '\:'
    function nmSplit(line) {
        const out = []; let cur = "";
        for (let i = 0; i < line.length; i++) {
            if (line[i] === "\\" && i + 1 < line.length) cur += line[++i];
            else if (line[i] === ":") { out.push(cur); cur = ""; }
            else cur += line[i];
        }
        out.push(cur);
        return out;
    }
    Process {
        id: netProc
        command: ["sh", "-c", "export NMCLI=1; nmcli -w 3 -t -f WIFI radio; echo --; nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list 2>/dev/null; echo --; " +
                  "nmcli -t -f NAME,TYPE con show 2>/dev/null; echo --; d=$(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2==\"wifi\"{print $1; exit}'); [ -n \"$d\" ] && nmcli -t -g IP4.ADDRESS dev show \"$d\" | head -1; echo --; nmcli -t -f TYPE,STATE dev | grep -q '^ethernet:connected' && echo wired"]
        stdout: StdioCollector { onStreamFinished: {
            const parts = String(text).split("--\n");
            const on = (parts[0] || "").trim() === "enabled";
            const known = (parts[2] || "").split("\n").filter(Boolean).map(apps.nmSplit).filter(f => /wireless/.test(f[1] || "")).map(f => f[0]);
            const seen = {};
            for (const l of (parts[1] || "").split("\n").filter(Boolean)) {
                const f = apps.nmSplit(l), ssid = f[1];
                if (!ssid) continue;
                const n = { ssid: ssid, signal: Number(f[2]) || 0, secure: !!f[3] && f[3] !== "--", active: f[0] === "*", known: known.includes(ssid) };
                if (!seen[ssid] || n.active || n.signal > seen[ssid].signal && !seen[ssid].active) seen[ssid] = n;
            }
            apps.nets = Object.values(seen).sort((a, b) => b.active - a.active || b.signal - a.signal);
            const act = apps.nets.find(n => n.active), ip = (parts[3] || "").trim().replace(/\/\d+$/, "");
            apps.patch({ on: on, nets: apps.nets.slice(0, 7), ask: apps.netAsk, secret: apps.netSecret,
                         status: act ? "connected to " + act.ssid + (ip ? " · " + ip : "") : (parts[4] || "").trim() === "wired" ? "on ethernet" : on ? "not connected" : "" });
            Island.index = Math.min(Island.index, Math.max(0, Math.min(7, apps.nets.length) - 1));
        } }
    }
    function netPress() {
        const n = nets[Island.index];
        if (!n) return;
        const id = Island.q(n.ssid);
        if (n.active) Island.sh("nmcli con down id " + id);
        else if (n.known) Island.sh("nmcli con up id " + id + " || notify-send -a Fluidity 'Could not join' " + id);
        else if (n.secure) { netAsk = n.ssid; netSecret = ""; patch({ ask: netAsk, secret: "" }); return; }
        else Island.sh("nmcli dev wifi connect " + id + " || notify-send -a Fluidity 'Could not join' " + id);
        later(1500, netRefresh);
    }
    function netKey(event) {
        const k = event.key, t = event.text;
        if (netAsk) {
            if (k === Qt.Key_Escape) { netAsk = ""; patch({ ask: "" }); return true; }
            if (k === Qt.Key_Return || k === Qt.Key_Enter) {
                Island.sh("nmcli dev wifi connect " + Island.q(netAsk) + " password " + Island.q(netSecret) + " || notify-send -a Fluidity 'Wrong password?' " + Island.q(netAsk));
                netAsk = ""; netSecret = ""; patch({ ask: "", secret: "" }); later(2500, netRefresh); return true;
            }
            if (k === Qt.Key_Backspace) netSecret = netSecret.slice(0, -1);
            else if (t && t >= " ") netSecret += t;
            patch({ secret: netSecret });
            return true;
        }
        if (listMove(event, Math.min(7, nets.length))) return true;
        if (k === Qt.Key_Return || k === Qt.Key_Enter) netPress();
        else if (t === "r") { Island.sh("nmcli dev wifi rescan"); later(2500, netRefresh); }
        else if (t === "w") { Island.sh("nmcli radio wifi " + (data.on ? "off" : "on")); later(800, netRefresh); }
        else if (t === "f") { const n = nets[Island.index]; if (n && n.known) { Island.sh("nmcli con delete id " + Island.q(n.ssid)); later(800, netRefresh); } }
        else return false;
        return true;
    }

    // ================= bluetooth (bluetoothctl) =================
    property var devs: []
    readonly property var btIcons: ({ "audio-headset": "󰋋", "audio-headphones": "󰋋", "audio-card": "󰓃", "input-keyboard": "󰌌", "input-mouse": "󰍽",
        "input-gaming": "󰊴", phone: "󰄜", computer: "󰟀", "video-display": "󰍹" })
    function btRefresh() { if (!btProc.running) btProc.running = true }
    Process {
        id: btProc
        command: ["bash", "-c", "timeout 4 bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo on || echo off; " +
            "timeout 4 bluetoothctl devices 2>/dev/null | while read -r _ mac name; do i=$(timeout 3 bluetoothctl info \"$mac\"); " +
            "printf '%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' \"$mac\" \"$name\" \"$(grep -q 'Paired: yes' <<<\"$i\" && echo 1)\" \"$(grep -q 'Connected: yes' <<<\"$i\" && echo 1)\" " +
            "\"$(sed -n 's/.*Icon: //p' <<<\"$i\")\" \"$(sed -n 's/.*Battery Percentage: .*(\\([0-9]*\\)).*/\\1/p' <<<\"$i\")\"; done"]
        stdout: StdioCollector { onStreamFinished: {
            const l = String(text).split("\n").filter(Boolean);
            const on = l[0] === "on";
            apps.devs = l.slice(1).map(r => r.split("\t")).map(f => ({ mac: f[0], name: f[1] || f[0], paired: f[2] === "1", connected: f[3] === "1",
                icon: apps.btIcons[f[4]] || "󰂯", battery: f[5] ? Number(f[5]) : -1 }))
                .sort((a, b) => b.connected - a.connected || b.paired - a.paired || a.name.localeCompare(b.name)).slice(0, 7);
            apps.patch({ on: on, devs: apps.devs, scanning: btScan.running });
            Island.index = Math.min(Island.index, Math.max(0, apps.devs.length - 1));
        } }
    }
    Process { id: btScan; command: ["bluetoothctl", "--timeout", "12", "scan", "on"]; onRunningChanged: apps.patch({ scanning: running }) }
    function btPress() {
        const x = devs[Island.index];
        if (!x) return;
        const m = Island.q(x.mac);
        if (x.connected) Island.sh("bluetoothctl disconnect " + m);
        else if (x.paired) Island.sh("bluetoothctl connect " + m + " || notify-send -a Fluidity 'Could not connect' " + Island.q(x.name));
        else Island.sh("bluetoothctl pair " + m + " && bluetoothctl trust " + m + " && bluetoothctl connect " + m + " || notify-send -a Fluidity 'Could not pair' " + Island.q(x.name));
        later(2500, btRefresh);
    }
    function btKey(event) {
        const k = event.key, t = event.text;
        if (listMove(event, devs.length)) return true;
        if (k === Qt.Key_Return || k === Qt.Key_Enter) btPress();
        else if (t === "s") { if (!data.on) Island.sh("bluetoothctl power on"); btScan.running = true; }
        else if (t === "b") { Island.sh("bluetoothctl power " + (data.on ? "off" : "on")); later(800, btRefresh); }
        else if (t === "x") { const x = devs[Island.index]; if (x) { Island.sh("bluetoothctl remove " + Island.q(x.mac)); later(800, btRefresh); } }
        else return false;
        return true;
    }

    // ================= calendar =================
    property date calSel: new Date()
    function calOpen(arg) {
        calSel = arg ? new Date(arg + "T12:00") : new Date();
        if (isNaN(calSel.getTime())) calSel = new Date();
        calRefresh(true);
        sunProc.running = true;
    }
    function calCells() {
        const y = calSel.getFullYear(), m = calSel.getMonth(), lead = (new Date(y, m, 1).getDay() + 6) % 7, out = [];
        for (let i = 0; i < 42; i++) out.push(new Date(y, m, i - lead + 1, 12));
        return out;
    }
    function calGo(dt) { const month = dt.getMonth() !== calSel.getMonth() || dt.getFullYear() !== calSel.getFullYear(); calSel = dt; calRefresh(month); }
    function calRefresh(month) {
        patch({ year: calSel.getFullYear(), month: calSel.getMonth(), today: iso(new Date()), sel: iso(calSel), now: Qt.formatTime(new Date(), "HH:mm") });
        const sel = iso(calSel);
        dayProc.command = ["sqlite3", "-readonly", "-separator", "\t", calDb,
            "select strftime('%H:%M', start, 'localtime'), strftime('%H:%M', end, 'localtime'), title, ifnull(color, '') from events " +
            "where all_day = 0 and date(start, 'localtime') = '" + sel + "' order by start"];
        dayProc.running = true;
        if (month) {
            const first = iso(calCells()[0]), last = iso(calCells()[41]);
            marksProc.command = ["sqlite3", "-readonly", calDb, "select distinct date(start, 'localtime') from events where date(start, 'localtime') between '" + first + "' and '" + last + "'"];
            marksProc.running = true;
        }
    }
    Process {
        id: dayProc
        stdout: StdioCollector { onStreamFinished: {
            const now = Qt.formatTime(new Date(), "HH:mm"), today = apps.data.sel === apps.data.today;
            apps.patch({ blocks: String(text).split("\n").filter(Boolean).map(r => r.split("\t")).map(r => ({
                time: r[0], end: r[1], title: r[2], color: r[3] || undefined,
                now: today && r[0] <= now && now < r[1], done: today && r[1] <= now })) });
        } }
    }
    Process { id: marksProc; stdout: StdioCollector { onStreamFinished: apps.patch({ marks: String(text).split("\n").filter(Boolean) }) } }
    // sunrise / sunset from wttr.in (by your IP), once a day, cached
    Process {
        id: sunProc
        command: ["sh", "-c", "f=" + apps.stateDir + "/sun; d=$(date +%F); if [ \"$(head -1 \"$f\" 2>/dev/null)\" != \"$d\" ]; then " +
                  "s=$(curl -fsm 6 'https://wttr.in/?format=%S+%s') && mkdir -p " + apps.stateDir + " && printf '%s\\n%s\\n' \"$d\" \"$s\" > \"$f\"; fi; sed -n 2p \"$f\" 2>/dev/null"]
        stdout: StdioCollector { onStreamFinished: {
            const p = String(text).trim().split(/\s+/);
            if (p.length === 2) apps.patch({ sunrise: p[0].slice(0, 5), sunset: p[1].slice(0, 5) });
        } }
    }
    function calKey(event) {
        const k = event.key, t = event.text, d = new Date(calSel);
        const step = n => { d.setDate(d.getDate() + n); calGo(d); };
        if (k === Qt.Key_Left) step(-1);
        else if (k === Qt.Key_Right) step(1);
        else if (k === Qt.Key_Up) step(-7);
        else if (k === Qt.Key_Down) step(7);
        else if (t === "," || k === Qt.Key_PageUp) { d.setMonth(d.getMonth() - 1, 1); calGo(d); }
        else if (t === "." || k === Qt.Key_PageDown) { d.setMonth(d.getMonth() + 1, 1); calGo(d); }
        else if (t === "t") calGo(new Date());
        else if (k === Qt.Key_Return || k === Qt.Key_Enter) { Island.close(); Island.sh("fluidity-launch focus calendio calendio"); }
        else return false;
        return true;
    }
}
