pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Polkit

// The Fluid showcase apps' brain: data for each app's island view (views/*App.qml) and its keys.
// Island.qml opens them like any view and hands their keys here (key() returns true when used).
Singleton {
    id: apps
    readonly property var views: ["calendar", "media", "network", "bluetooth", "syspanel", "quickactions", "wellbeing", "guide", "widgets", "polkit", "idlescreen", "dockkeys"]
    property string open: ""       // the app on screen, "" when none (polling runs only then)
    property var data: ({})
    // leader ; u: one letter per app
    readonly property var leaderKeys: [{ k: "c", label: "calendar", open: "calendar" }, { k: "m", label: "media", open: "media" }, { k: "w", label: "wi-fi", open: "network" }, { k: "b", label: "bluetooth", open: "bluetooth" }, { k: "s", label: "system", open: "syspanel" }, { k: "q", label: "quick", open: "quickactions" }, { k: "h", label: "wellbeing", open: "wellbeing" }, { k: "g", label: "guide", open: "guide" }, { k: "d", label: "widgets", open: "widgets" }, { k: "k", label: "dock", open: "dockkeys" }]
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
        else if (v === "syspanel") { sysTick(); }
        else if (v === "quickactions") qaRefresh();
        else if (v === "wellbeing") wbProc.running = true;
        else if (v === "widgets") wgRows();
        else if (v === "polkit") pkShow();
        else if (v === "idlescreen") idleTick();
        else if (v === "dockkeys") Dock.sel = 0;
        else if (v === "widgets") { Island.index = i; wgFlip(); }
        else if (v === "guide") { guidePage = 0; patch({ pages: guidePages, page: 0, focus: "pages" }); }
    }
    function key(event, v) {
        if (v === "calendar") return calKey(event);
        if (v === "media") return mediaKey(event);
        if (v === "network") return netKey(event);
        if (v === "bluetooth") return btKey(event);
        if (v === "syspanel") return sysKey(event);
        if (v === "quickactions") return qaKey(event);
        if (v === "wellbeing") { if (event.text === "r") { wbProc.running = true; return true; } return false; }
        if (v === "guide") return guideKey(event);
        if (v === "widgets") return wgKey(event);
        if (v === "polkit") return pkKey(event);
        if (v === "idlescreen") { Island.close(); return true; }
        if (v === "dockkeys") return Dock.key(event);
        return false;
    }
    function picked(v, i) {
        if (v === "calendar") { const c = calCells()[i]; if (c) calGo(c); }
        else if (v === "media") { Island.index = i; mediaPress(i); }
        else if (v === "network") { Island.index = i; netPress(); }
        else if (v === "bluetooth") { Island.index = i; btPress(); }
        else if (v === "syspanel") Island.index = i;
        else if (v === "quickactions") { Island.index = i; qaPress(i); }
        else if (v === "guide") { guidePage = i; Island.index = 0; patch({ page: i, focus: "pages" }); }
    }

    readonly property bool shown: Island.overlayShown && Island.target === open
    onShownChanged: if (!shown) { if (open === "dockkeys") Dock.sel = -1; if (open === "polkit" && pkFlow && !pkFlow.isCompleted) pkFlow.cancelAuthenticationRequest(); open = "" }

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

    // ================= system =================
    property var cpuHist: []
    property var brightness: -1
    // the history fills all the time (cheap: Status already polls every 5 s), so the line is there on open
    Connections { target: Status; function onSysChanged() { apps.cpuHist = apps.cpuHist.concat([Status.sys.cpu]).slice(-40); if (apps.open === "syspanel") apps.sysTick(true) } }
    Timer { interval: 3000; repeat: true; running: apps.open === "syspanel"; onTriggered: apps.sysTick() }
    Process {
        id: sysProc
        command: ["sh", "-c", "cut -d. -f1 /proc/uptime; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo | awk '{print $2}'; " +
                  "b=$(brightnessctl -m -c backlight 2>/dev/null | cut -d, -f4 | tr -d %); echo ${b:--1}; echo --; ps -eo comm,%cpu --sort=-%cpu --no-headers | grep -v '^ps ' | head -3"]
        stdout: StdioCollector { onStreamFinished: {
            const parts = String(text).split("--\n"), l = parts[0].split("\n");
            const up = Number(l[0]) || 0, mt = Number(l[1]) || 1, ma = Number(l[2]) || 0;
            apps.brightness = Number(l[3]);
            const gib = k => (k / 1048576).toFixed(1);
            apps.patch({ uptime: (up >= 86400 ? Math.floor(up / 86400) + "d " : "") + Math.floor(up % 86400 / 3600) + "h " + Math.floor(up % 3600 / 60) + "m",
                         ramText: gib(mt - ma) + " / " + gib(mt) + " GiB",
                         top: (parts[1] || "").split("\n").filter(Boolean).map(r => { const m = r.trim().match(/^(.*\S)\s+([\d.]+)$/); return m ? { name: m[1], cpu: Number(m[2]) } : null }).filter(Boolean) });
            apps.sysTick(true);
        } }
    }
    function sysTick(noPoll) {
        if (!noPoll && !sysProc.running) sysProc.running = true;
        const st = Status.sys, sink = Island.sink?.audio;
        const sliders = [{ icon: sink?.muted ? "󰝟" : "󰕾", label: "volume", value: sink ? sink.volume : 0 }];
        if (brightness >= 0) sliders.push({ icon: "󰃠", label: "brightness", value: brightness / 100 });
        patch({ cpu: st.cpu, ram: st.ram, temp: st.temp, disk: st.disk, battery: Status.battery, hist: cpuHist, sliders: sliders });
    }
    function sysKey(event) {
        const k = event.key, t = event.text, n = (data.sliders || []).length;
        if (listMove(event, n)) return true;
        if (k === Qt.Key_Left || k === Qt.Key_Right || t === "-" || t === "=" || t === "+") {
            const up = k === Qt.Key_Right || t === "=" || t === "+";
            if (Island.index === 0) Island.volume(up ? 0.05 : -0.05);
            else { brightness = Math.max(1, Math.min(100, brightness + (up ? 5 : -5))); Island.sh("brightnessctl -q set " + brightness + "%"); Island.osd("󰃠", brightness / 100); }
            sysTick(true); return true;
        }
        if (t === "h") { Island.close(); Island.sh("fluidity-launch focus-tui btop"); return true; }
        return false;
    }

    // ================= quick actions =================
    property var qa: ({})
    Process {
        id: qaProc
        command: ["sh", "-c", "fluidity-toggle status nightlight; fluidity-toggle status idle; " +
            "timeout 3 nmcli -t -f NAME,TYPE con show --active 2>/dev/null | awk -F: '$2 ~ /vpn|wireguard/ {print \"vpn \" $1; exit}'; " +
            "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED && echo mic-muted; " +
            "o=$(timeout 3 rfkill -n -o SOFT 2>/dev/null); [ -n \"$o\" ] && ! echo \"$o\" | grep -q unblocked && echo airplane; " +
            "[ -e \"${XDG_STATE_HOME:-$HOME/.local/state}/fluidity/toggles/window-no-gaps.lua\" ] && echo gaps-off; true"]
        stdout: StdioCollector { onStreamFinished: {
            const t = String(text);
            const vpn = (t.match(/^vpn (.*)$/m) || [])[1] || "";
            apps.qa = { night: t.includes("nightlight on"), awake: t.includes("idle on"), vpn: vpn, mic: !t.includes("mic-muted"), airplane: /^airplane$/m.test(t), gaps: !t.includes("gaps-off") };
            apps.qaRefresh(true);
        } }
    }
    function qaTiles() {
        const s = qa;
        return [
            { icon: "󰖔", label: "Night light", on: !!s.night, run: "fluidity-toggle nightlight" },
            { icon: "󰂛", label: "Do not disturb", on: Notifs.dnd, state: Notifs.dnd ? "no popups" : "off", dnd: true },
            { icon: "󰅶", label: "Caffeine", on: !!s.awake, state: s.awake ? "stays awake" : "off", run: "fluidity-toggle idle" },
            { icon: "󰖂", label: "VPN", on: !!s.vpn, state: s.vpn || "off", run: s.vpn ? "nmcli con down id " + Island.q(s.vpn) : "fluidity-launch focus protonvpn protonvpn-app" },
            { icon: s.mic === false ? "󰍭" : "󰍬", label: "Mic", on: s.mic !== false, state: s.mic === false ? "muted" : "live", run: "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
            { icon: "󰀝", label: "Airplane", on: !!s.airplane, run: "rfkill " + (s.airplane ? "unblock" : "block") + " all" },
            { icon: "󰹑", label: "Screen record", once: true, run: "fluidity-capture record", close: true },
            { icon: "󰈊", label: "Colour pick", once: true, run: "fluidity-capture colour", close: true },
            { icon: "󰕰", label: "Gaps", on: s.gaps !== false, run: "fluidity-window gaps" }];
    }
    readonly property var qaPower: [{ icon: "\uf023", label: "lock", key: "l" }, { icon: "󰤄", label: "sleep", key: "s" }, { icon: "󰜉", label: "restart", key: "r" }, { icon: "󰐥", label: "shut down", key: "p" }]
    function qaRefresh(noPoll) {
        if (!noPoll && !qaProc.running) qaProc.running = true;
        patch({ tiles: qaTiles(), power: qaPower });
    }
    function qaPress(i) {
        const tiles = qaTiles(), t = tiles[i];
        if (!t) { const p = qaPower[i - tiles.length]; if (p) Island.power(Island.powerItems.findIndex(x => x.key === p.key)); return; }
        if (t.dnd) Notifs.dnd = !Notifs.dnd; else if (t.close) { Island.close(); later(300, () => Island.sh(t.run)); return; } else Island.sh(t.run);
        later(500, () => qaRefresh());
        qaRefresh(true);
    }
    function qaKey(event) {
        const k = event.key, t = event.text, nt = qaTiles().length, n = nt + qaPower.length, i = Island.index;
        const p = qaPower.findIndex(x => x.key === t);
        if (p >= 0) { qaPress(nt + p); return true; }
        if (k === Qt.Key_Right || k === Qt.Key_Tab) Island.index = Math.min(n - 1, i + 1);
        else if (k === Qt.Key_Left || k === Qt.Key_Backtab) Island.index = Math.max(0, i - 1);
        else if (k === Qt.Key_Down) Island.index = i < nt ? Math.min(n - 1, i + 3 >= nt ? nt + Math.min(qaPower.length - 1, i % 3) : i + 3) : i;
        else if (k === Qt.Key_Up) Island.index = i >= nt ? nt - 3 + Math.min(2, i - nt) : Math.max(0, i - 3);
        else if (k === Qt.Key_Return || k === Qt.Key_Enter || t === " ") qaPress(i);
        else return false;
        return true;
    }

    // ================= wellbeing =================
    Process {
        id: wbProc
        command: ["fluidity-wellbeing", "today"]
        stdout: StdioCollector { onStreamFinished: { try { const j = JSON.parse(text); j.now = new Date().getHours(); j.breakAfter = 50; apps.patch(j) } catch (e) { apps.patch({ total: 0, apps: [], hours: [] }) } } }
    }

    // ================= guide =================
    property int guidePage: 0
    readonly property var guidePages: [
        { icon: "󰍜", title: "The bar", body: "Left: the droplet and your workspaces. Then the app row: every Fluid app is one click, or ❖ ; u and a letter. The island in the middle shows the song, the time and your next Calendio block; click it for the calendar. The right pill: weather, load, Wi-Fi, Bluetooth, volume, battery and AI usage.",
          keys: [{ desc: "Apps row", keys: ["❖", ";", "U"] }, { desc: "Hide every widget", keys: ["❖", "⇧", "Space"] }, { desc: "Leader keys", keys: ["❖", ";"] }],
          actions: [{ label: "Hide or show widgets", run: "fluidity-widgets toggle" }, { label: "Choose widgets", run: "fluidity-widgets pick" }] },
        { icon: "󰍹", title: "Display", body: "Scale, mirroring and the laptop panel. Night light warms the screen after dark; stay awake keeps it from locking.",
          keys: [{ desc: "Night light", keys: ["❖", "^", "N"] }, { desc: "Stay awake", keys: ["❖", "^", "I"] }, { desc: "Hardware keys", keys: ["❖", "^", "H"] }],
          actions: [{ label: "Night light", run: "fluidity-toggle nightlight" }, { label: "Mirror displays", run: "fluidity-display mirror" }, { label: "Scale up", run: "fluidity-window scale up" }, { label: "Scale down", run: "fluidity-window scale down" }] },
        { icon: "󰂚", title: "Notifications", body: "They land in the island and wait in the history. Do not disturb keeps them quiet (the focus timer turns it on for you). Battery and weather alerts come here too.",
          keys: [{ desc: "History", keys: ["❖", "⌥", ","] }, { desc: "Dismiss", keys: ["❖", ","] }, { desc: "Do not disturb", keys: ["❖", "^", ","] }],
          actions: [{ label: "Open history", open: "notifications" }, { label: "Do not disturb", dnd: true }, { label: "Clear all", run: "fluidity-notify clear" }] },
        { icon: "󰄀", title: "Screenshot", body: "A region, a window or the full screen; recordings with or without sound; text from the screen (OCR) and a colour picker. Everything lands in your clipboard.",
          keys: [{ desc: "Capture keys", keys: ["❖", "^", "C"] }, { desc: "Region", keys: ["❖", ";", "S"] }, { desc: "Record", keys: ["❖", ";", "R"] }],
          actions: [{ label: "Region", run: "fluidity-capture screenshot", close: true }, { label: "Full screen", run: "fluidity-capture screenshot full", close: true }, { label: "Record", run: "fluidity-capture record", close: true }] },
        { icon: "󰏘", title: "Theme", body: "Fluid is the default; every Luminescent theme came along. A theme changes the colours of the bar, the island, your terminal and editor together. Mac mode swaps in the Tahoe bar and dock.",
          keys: [{ desc: "Theme picker", keys: ["❖", "⇧", "^", "Space"] }, { desc: "Next theme", keys: ["❖", ";", "T"] }, { desc: "Mac mode", keys: ["❖", ";", "M"] }],
          actions: [{ label: "Theme picker", open: "themes" }, { label: "Next theme", run: "fluidity-theme next" }, { label: "Mac mode", run: "fluidity-mode toggle" }] },
        { icon: "󰸉", title: "Wallpaper", body: "Your fern is the default. Put images in ~/Wallpapers and they show up in the picker next to the theme's own.",
          keys: [{ desc: "Wallpaper picker", keys: ["❖", "^", "Space"] }, { desc: "Next wallpaper", keys: ["❖", ";", "W"] }],
          actions: [{ label: "Wallpaper picker", open: "wallpaper" }, { label: "Next wallpaper", run: "fluidity-wallpaper next" }] },
        { icon: "󰔟", title: "Wellbeing", body: "One sample a minute of the app in front, kept on this PC only (~/.local/state/fluidity/wellbeing). After 50 minutes without a break you get a nudge. The focus timer runs 25 minutes with notifications off.",
          keys: [{ desc: "Focus 25", keys: ["❖", ";", "F"] }, { desc: "Wellbeing", keys: ["❖", ";", "U", "H"] }],
          actions: [{ label: "Screen time", open: "wellbeing" }, { label: "Start focus", run: "fluidity-focus toggle" }] },
        { icon: "󰀻", title: "Apps", body: "The Fluid apps: calendar, media, Wi-Fi, Bluetooth, system, quick actions, wellbeing and this guide. Each opens in the island, from the bar's app row or the apps leader row.",
          keys: [{ desc: "Calendar", keys: ["❖", ";", "U", "C"] }, { desc: "Media", keys: ["❖", ";", "U", "M"] }, { desc: "System", keys: ["❖", ";", "U", "S"] }],
          actions: [{ label: "Calendar", open: "calendar" }, { label: "Media", open: "media" }, { label: "Quick actions", open: "quickactions" }] }]
    function guideRun(act) {
        if (!act) return;
        if (act.dnd) { Notifs.dnd = !Notifs.dnd; return; }
        if (act.open) { Island.close(); later(360, () => Island.open(act.open, "")); return; }
        if (act.close) { Island.close(); later(300, () => Island.sh(act.run)); return; }
        Island.sh(act.run);
    }
    function guideKey(event) {
        const k = event.key, inA = data.focus === "actions", acts = guidePages[guidePage].actions || [];
        if (inA) {
            if (k === Qt.Key_Left && Island.index === 0 || k === Qt.Key_Backspace) patch({ focus: "pages" });
            else if (k === Qt.Key_Right || k === Qt.Key_Tab || k === Qt.Key_Down) Island.index = Math.min(acts.length - 1, Island.index + 1);
            else if (k === Qt.Key_Left || k === Qt.Key_Backtab || k === Qt.Key_Up) Island.index = Math.max(0, Island.index - 1);
            else if (k === Qt.Key_Return || k === Qt.Key_Enter) guideRun(acts[Island.index]);
            else return false;
            return true;
        }
        if (k === Qt.Key_Down) guidePage = Math.min(guidePages.length - 1, guidePage + 1);
        else if (k === Qt.Key_Up) guidePage = Math.max(0, guidePage - 1);
        else if (k === Qt.Key_Right || k === Qt.Key_Tab || k === Qt.Key_Return || k === Qt.Key_Enter) { if (acts.length) { Island.index = 0; patch({ focus: "actions" }); } return true; }
        else return false;
        patch({ page: guidePage });
        return true;
    }

    // ================= widgets picker =================
    function wgRows() { patch({ rows: Widgets.all.map(n => ({ name: n, on: Widgets.shown.includes(n) })) }) }
    Connections { target: Widgets; function onShownChanged() { if (apps.open === "widgets") apps.wgRows() } }
    function wgFlip() { const n = Widgets.all[Island.index]; if (n) Island.sh("fluidity-widgets flip " + n); }
    function wgKey(event) {
        if (listMove(event, Widgets.all.length)) return true;
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.text === " ") { wgFlip(); return true; }
        return false;
    }

    // ================= polkit agent =================
    // Fluidity answers system password prompts in the island. Only one agent can hold a session, so
    // hyprpolkitagent has to be off (fluidity-install polkit); tests set FLUIDITY_NO_POLKIT.
    property string pkSecret: ""
    property string pkError: ""
    Loader {
        id: pkLoader
        active: !Quickshell.env("FLUIDITY_NO_POLKIT")
        sourceComponent: PolkitAgent {
            onAuthenticationRequestStarted: { apps.pkSecret = ""; apps.pkError = ""; Island.open("polkit", "") }
            onIsActiveChanged: if (!isActive && Island.target === "polkit") Island.close()
        }
    }
    readonly property var pkFlow: pkLoader.item?.flow ?? null
    Connections {
        target: apps.pkFlow
        function onAuthenticationFailed() { apps.pkSecret = ""; apps.pkError = "That wasn't it. Try again."; apps.pkShow() }
        function onSupplementaryMessageChanged() { if (apps.pkFlow.supplementaryIsError) { apps.pkError = apps.pkFlow.supplementaryMessage; apps.pkShow() } }
        function onIsResponseRequiredChanged() { apps.pkShow() }
        function onIsCompletedChanged() { if (apps.pkFlow.isCompleted && Island.target === "polkit") Island.close() }
    }
    function pkShow() {
        const f = pkFlow;
        patch({ message: f ? f.message : "", user: Quickshell.env("USER") || "", prompt: f ? f.inputPrompt : "", echo: f ? f.responseVisible : false, secret: pkSecret, error: pkError });
    }
    function pkKey(event) {
        const k = event.key, t = event.text, f = pkFlow;
        if (k === Qt.Key_Escape) { if (f) f.cancelAuthenticationRequest(); Island.close(); return true; }
        if (k === Qt.Key_Return || k === Qt.Key_Enter) { if (f && f.isResponseRequired) { f.submit(pkSecret); pkSecret = ""; pkError = ""; patch({ secret: "", error: "" }) } return true; }
        if (k === Qt.Key_Backspace) pkSecret = pkSecret.slice(0, -1);
        else if (t && t >= " " && !(event.modifiers & (Qt.ControlModifier | Qt.MetaModifier))) pkSecret += t;
        patch({ secret: pkSecret });
        return true;
    }

    // ================= idle screen =================
    Timer { interval: 1000; repeat: true; running: apps.open === "idlescreen"; onTriggered: apps.idleTick() }
    function idleTick() {
        const now = new Date();
        patch({ hours: Qt.formatTime(now, "HH"), minutes: Qt.formatTime(now, "mm"), date: Qt.formatDate(now, "dddd, d MMMM"), song: Island.song, next: Status.nextText });
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
