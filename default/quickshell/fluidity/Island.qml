pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

// The island's brain: which view is open, the data for it, what every key does.
// Interactive views (launcher, emoji, clipboard, ...) open in the overlay window, which takes the keyboard;
// passive ones (a notification, the volume OSD) play in the bar's own island.
// Keybinds reach it through `fluidity-island VIEW [ARG]` -> `qs -c fluidity ipc call island toggle VIEW ARG`.
Singleton {
    id: island

    readonly property string home: Quickshell.env("HOME")
    readonly property string root: Quickshell.env("FLUIDITY_PATH") || (home + "/.local/share/fluidity")
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (home + "/.local/state")) + "/fluidity"

    // ---------- overlay (interactive) ----------
    property bool overlayShown: false
    property string view: "idle"          // what the overlay island shows; "idle" while morphing in/out
    property string target: "idle"        // the view being opened
    property string arg: ""
    property string query: ""
    property int index: 0
    property ShellScreen screen: Quickshell.screens[0]
    readonly property var interactive: ["launcher", "emoji", "clipboard", "cheatsheet", "leader", "power", "wallpaper", "switcher", "control", "notifications"]

    // ---------- bar island (passive) ----------
    property string barView: "idle"
    property string passiveTitle: ""
    property string passiveBody: ""
    property string passiveIcon: ""
    property real passiveValue: 0
    property var passiveKeys: []
    property bool barShown: true

    // ---------- data the views read ----------
    property var items: []
    property var groups: []
    property var preview: ({})
    property var calc: null
    property var cats: []
    property int cat: 0
    property string title: ""
    property string body: ""
    property string placeholder: ""
    property var keyHint: []

    // ---------- live sources ----------
    readonly property PwNode sink: Pipewire.defaultAudioSink
    PwObjectTracker { objects: [island.sink] }
    readonly property MprisPlayer player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
    readonly property string song: player && player.trackTitle ? player.trackTitle + (player.trackArtist ? " · " + player.trackArtist : "") : ""

    function sh(cmd) { Quickshell.execDetached(["sh", "-c", cmd]) }
    function q(s) { return "'" + String(s).replace(/'/g, "'\\''") + "'" }
    function later(ms, fn) { const t = Qt.createQmlObject('import QtQuick; Timer { repeat: false }', island); t.interval = ms; t.triggered.connect(() => { fn(); t.destroy(); }); t.start(); }

    // ================= open / close =================
    function focusedScreen() {
        const mon = Hyprland.focusedMonitor?.name;
        return Quickshell.screens.find(s => s.name === mon) ?? Quickshell.screens[0];
    }
    function toggle(v, a) {
        if (overlayShown && target === v && (a || "") === arg) close();
        else open(v, a);
    }
    function open(v, a) {
        if (v === "themes") { ThemePickerState.toggle(); return; }
        if (v === "bar") { barShown = !barShown; return; }
        if (!interactive.includes(v)) return;
        target = v; arg = a || ""; query = ""; index = 0; cat = 0;
        screen = focusedScreen();
        load(v);
        if (!overlayShown) { view = "idle"; overlayShown = true; later(16, () => view = target); }
        else view = target;
    }
    readonly property int hideAfter: 340      // ms: the island shrinks back, then the window (and its keyboard grab) goes
    readonly property string pasteDelay: "0.6" // s: typing/pasting waits for that, so it lands in your window
    function close() {
        view = "idle";
        later(hideAfter, () => { if (view === "idle") overlayShown = false; });
    }

    // ================= passive island (bar) =================
    Timer { id: passiveTimer; onTriggered: island.barView = "idle" }
    function passive(v, ms) { barView = v; passiveTimer.interval = ms; passiveTimer.restart(); }
    function osd(icon, value) { passiveIcon = icon; passiveValue = value; passive("osd", 1400); }
    function notify(n) {
        passiveTitle = n.summary || n.appName || "";
        passiveBody = n.body || "";
        passiveIcon = glyphFor(n.appName || n.desktopEntry || "");
        passiveKeys = [];
        passive("notify", 4500);
    }
    Connections {
        target: Notifs
        function onArrived(n) { island.notify(n) }
    }
    Connections {
        target: island.sink?.audio ?? null
        function onVolumeChanged() { island.osd(island.sink.audio.muted ? "󰝟" : "󰕾", island.sink.audio.volume) }
        function onMutedChanged() { island.osd(island.sink.audio.muted ? "󰝟" : "󰕾", island.sink.audio.muted ? 0 : island.sink.audio.volume) }
    }

    // ================= data per view =================
    function load(v) {
        items = []; groups = []; preview = ({}); calc = null; title = ""; body = ""; keyHint = [];
        if (v === "launcher") { placeholder = "open anything"; keyHint = ["↵ open", "= maths", "? web", "> run", "/ files", "+ calendio", "esc close"]; refreshLauncher(); }
        else if (v === "emoji") { placeholder = "search emoji"; cats = emojiCats; refreshEmoji(); }
        else if (v === "clipboard") { placeholder = "search clipboard"; clipProc.running = true; }
        else if (v === "cheatsheet") { placeholder = "search keys"; keyHint = ["type to filter", "esc close"]; bindsProc.running = true; }
        else if (v === "leader") { const r = leaderRows[arg] || leaderRows[""]; title = r.title; items = r.keys; }
        else if (v === "power") { items = powerItems; }
        else if (v === "wallpaper") { wallProc.running = true; }
        else if (v === "switcher") { refreshSwitcher(); }
        else if (v === "control") { refreshControl(); }
        else if (v === "notifications") { refreshHistory(); }
    }
    onQueryChanged: {
        index = 0;
        if (target === "launcher") refreshLauncher();
        else if (target === "emoji") refreshEmoji();
        else if (target === "clipboard") refreshClip();
        else if (target === "cheatsheet") refreshBinds();
    }

    // ---- launcher ----
    property var recent: []
    FileView {
        id: recentFile
        path: island.stateDir + "/launcher-recent.json"
        onLoaded: { try { island.recent = JSON.parse(text()) } catch (e) { island.recent = [] } }
    }
    readonly property var appKeys: ({ calendio: "A", zen: "B", "zen-browser": "B", vesktop: "D", spotify: "M", obsidian: "N",
        burrow: "E", "claude-desktop": "I", claude: "I", flowday: "U", "code-insiders": "Z", btop: "H" })
    function score(name, q) {
        name = name.toLowerCase(); q = q.toLowerCase();
        if (!q) return 1;
        if (name.startsWith(q)) return 100 - name.length / 100;
        const at = name.indexOf(q);
        if (at >= 0) return 60 - at;
        let i = 0;
        for (const ch of name) if (ch === q[i]) i++;
        return i === q.length ? 20 : -1;
    }
    // apps load asynchronously: refresh an open launcher when they arrive
    readonly property int appCount: DesktopEntries.applications.values.length
    onAppCountChanged: if (target === "launcher" && overlayShown) refreshLauncher()
    function refreshLauncher() {
        const qv = query.trim();
        calc = null;
        if (qv.startsWith("=")) {
            const expr = qv.slice(1).trim();
            let result = "";
            if (/^[\d\s+\-*/().%^]+$/.test(expr) && expr.length) { try { result = String(Function('"use strict";return (' + expr.replace(/\^/g, "**") + ")")()) } catch (e) { result = "…" } }
            calc = { expr: expr || " ", result: result };
            items = [{ icon: "", title: result ? "Copy " + result : "Type a sum", desc: "maths" }];
            return;
        }
        if (qv.startsWith(">")) {   // run a command
            items = [{ icon: "\uf120", title: qv.slice(1).trim() ? "Run " + qv.slice(1).trim() : "Type a command", desc: "runs in the background · ⇧↵ in a terminal" }];
            return;
        }
        if (qv.startsWith("/")) {   // find files in your home
            const term = qv.slice(1).trim();
            items = term ? [] : [{ icon: "\uf002", title: "Type part of a file name", desc: "searches your home" }];
            if (term) { fdProc.running = false; fdProc.command = ["fd", "-a", "-i", "--max-results", "5", "--", term, home]; fdProc.running = true; }
            return;
        }
        if (qv.startsWith("+")) {   // add to Calendio
            items = [{ icon: "\uf073", title: "Add to Calendio", desc: "opens Calendio's quick add", keys: ["❖", "A"] }];
            return;
        }
        if (qv.startsWith("?")) {
            items = [{ icon: "", title: "Search the web for “" + qv.slice(1).trim() + "”", desc: "duckduckgo" }];
            return;
        }
        const apps = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        const scored = [];
        for (const e of apps) {
            const s = Math.max(score(e.name, qv), score(e.genericName || "", qv) - 10, score(e.id || "", qv) - 15);
            if (s < 0) continue;
            const r = recent.indexOf(e.id);
            scored.push({ e: e, s: s + (r >= 0 ? 40 - r : 0) });
        }
        for (const w of webApps) {
            const ws = score(w.name, qv) - 5;
            if (ws >= 0 && qv) scored.push({ e: { name: w.name, id: "webapp:" + w.name, comment: "web app", execute: () => sh("fluidity-launch webapp " + q(w.url)) }, s: ws, web: true });
        }
        scored.sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name));
        items = scored.slice(0, 5).map(x => {
            const k = appKeys[(x.e.id || "").replace(/\.desktop$/, "").toLowerCase()];
            return { entry: x.e, image: x.e.icon ? Quickshell.iconPath(x.e.icon, true) : "", icon: x.e.icon ? "" : "",
                     title: x.e.name, desc: x.e.comment || x.e.genericName || "", keys: k ? ["❖", k] : undefined };
        });
    }
    readonly property var webApps: [
        { name: "ChatGPT", url: "https://chatgpt.com" }, { name: "YouTube", url: "https://youtube.com" },
        { name: "WhatsApp", url: "https://web.whatsapp.com" }, { name: "X", url: "https://x.com" },
        { name: "Google Maps", url: "https://maps.google.com" }, { name: "Google Photos", url: "https://photos.google.com" },
        { name: "Google Messages", url: "https://messages.google.com/web" }, { name: "Gmail", url: "https://mail.google.com" },
        { name: "GitHub", url: "https://github.com" }, { name: "Lichess", url: "https://lichess.org" },
        { name: "Chess.com", url: "https://chess.com" }, { name: "Claude", url: "https://claude.ai" }]
    Process {
        id: fdProc
        stdout: StdioCollector { onStreamFinished: {
            if (!island.query.trim().startsWith("/")) return;
            const files = String(text).split("\n").filter(Boolean);
            island.items = files.length ? files.map(p => ({ path: p, icon: p.endsWith("/") ? "\uf07b" : "\uf15b",
                title: p.replace(/\/$/, "").split("/").pop(), desc: p.replace(island.home, "~") })) : [{ icon: "\uf002", title: "No files found", desc: "" }];
        } }
    }
    function launch(it, shift) {
        const qv = query.trim();
        if (qv.startsWith(">")) { const c = qv.slice(1).trim(); if (c) sh(shift ? "fluidity-launch terminal bash -c " + q(c + "; exec bash") : c); return; }
        if (qv.startsWith("/")) { if (it && it.path) sh("xdg-open " + q(it.path)); return; }
        if (qv.startsWith("+")) { sh("calendio --quick-add"); return; }
        if (calc) { if (calc.result) sh("printf %s " + q(calc.result) + " | wl-copy"); return; }
        if (query.trim().startsWith("?")) { sh("xdg-open " + q("https://duckduckgo.com/?q=" + encodeURIComponent(query.trim().slice(1).trim()))); return; }
        if (!it || !it.entry) return;
        it.entry.execute();
        const id = it.entry.id;
        recent = [id].concat(recent.filter(x => x !== id)).slice(0, 30);
        recentFile.setText(JSON.stringify(recent));
    }

    // ---- emoji ----
    readonly property var emojiCats: ["recent", "people", "animals", "food", "travel", "activity", "objects", "symbols", "flags"]
    property var emojiAll: []
    property var emojiRecent: []
    FileView { path: island.root + "/default/data/emoji.json"; onLoaded: { try { island.emojiAll = JSON.parse(text()) } catch (e) {} } }
    FileView {
        id: emojiRecentFile
        path: island.stateDir + "/emoji-recent.json"
        onLoaded: { try { island.emojiRecent = JSON.parse(text()) } catch (e) {} }
    }
    function refreshEmoji() {
        const qv = query.trim().toLowerCase();
        let list;
        if (qv) list = emojiAll.filter(e => e.name.includes(qv) || (e.keywords || []).some(k => k.includes(qv)));
        else if (cat === 0) {
            list = emojiRecent.map(r => emojiAll.find(e => e.emoji === r)).filter(Boolean);
            if (list.length < 30) list = list.concat(emojiAll.filter(e => !emojiRecent.includes(e.emoji)).slice(0, 30 - list.length));
        } else list = emojiAll.filter(e => e.category === emojiCats[cat]);
        items = list.slice(0, 30).map(e => ({ e: e.emoji, name: e.name }));
    }
    function pickEmoji(it) {
        if (!it) return;
        emojiRecent = [it.e].concat(emojiRecent.filter(x => x !== it.e)).slice(0, 30);
        emojiRecentFile.setText(JSON.stringify(emojiRecent));
        sh("printf %s " + q(it.e) + " | wl-copy; sleep " + pasteDelay + "; wtype " + q(it.e));
    }

    // ---- clipboard ----
    property var clipAll: []
    Process {
        id: clipProc
        command: ["cliphist", "list"]
        stdout: StdioCollector { onStreamFinished: {
            island.clipAll = String(text).split("\n").filter(l => l.includes("\t")).slice(0, 200).map(l => {
                const tab = l.indexOf("\t"), id = l.slice(0, tab), body = l.slice(tab + 1);
                const img = body.startsWith("[[ binary data");
                return { id: id, raw: l, img: img, title: img ? body.replace(/^\[\[ binary data /, "").replace(/ \]\]$/, "") : body };
            });
            island.refreshClip();
        } }
    }
    function refreshClip() {
        const qv = query.toLowerCase();
        items = clipAll.filter(c => !qv || c.title.toLowerCase().includes(qv)).slice(0, 6)
            .map(c => ({ clip: c, icon: c.img ? "󰋩" : (/^https?:\/\//.test(c.title) ? "" : ""), title: c.title.replace(/\s+/g, " "), meta: c.img ? "image" : c.title.length + " ch" }));
        previewClip();
    }
    function previewClip() {
        const it = items[index];
        if (!it) { preview = ({}); return; }
        if (it.clip.img) {
            const f = (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/fluidity-clip-" + it.clip.id + ".png";
            clipDecode.command = ["sh", "-c", "[ -s " + q(f) + " ] || cliphist decode " + q(it.clip.id) + " > " + q(f) + "; echo " + q(f)];
            clipDecode.image = true;
        } else {
            clipDecode.command = ["cliphist", "decode", it.clip.id];
            clipDecode.image = false;
        }
        clipDecode.running = true;
    }
    Process {
        id: clipDecode
        property bool image: false
        stdout: StdioCollector { onStreamFinished: {
            const t = String(text);
            if (clipDecode.image) island.preview = { kind: "image", src: "file://" + t.trim(), info: "image" };
            else island.preview = { kind: "text", text: t.slice(0, 1200), info: "text · " + t.split("\n").length + " lines · " + t.length + " characters" };
        } }
    }
    function pasteClip(it) { if (it) sh("cliphist decode " + q(it.clip.id) + " | wl-copy; sleep " + pasteDelay + "; wtype -M ctrl -k v -m ctrl") }
    function deleteClip(it) { if (it) { sh("printf '%s\\n' " + q(it.clip.raw) + " | cliphist delete"); clipAll = clipAll.filter(c => c !== it.clip); refreshClip(); } }

    // ---- cheat sheet (live from hyprctl binds) ----
    property var bindsAll: []
    Process {
        id: bindsProc
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector { onStreamFinished: { try { island.bindsAll = JSON.parse(text) } catch (e) { island.bindsAll = [] } island.refreshBinds(); } }
    }
    function keysOf(b) {
        const m = b.modmask, out = [];
        if (m & 64) out.push("❖"); if (m & 4) out.push("^"); if (m & 8) out.push("⌥"); if (m & 1) out.push("⇧");
        let k = b.key || "";
        const code = { 10: "1", 11: "2", 12: "3", 13: "4", 14: "5", 15: "6", 16: "7", 17: "8", 18: "9", 19: "0", 61: "/" }[b.keycode];
        if (!k && code) k = code;
        k = ({ RETURN: "↵", SPACE: "Space", ESCAPE: "Esc", BACKSPACE: "⌫", LEFT: "←", RIGHT: "→", UP: "↑", DOWN: "↓", SEMICOLON: ";", PERIOD: ".", COMMA: ",", SLASH: "/", TAB: "Tab" })[k.toUpperCase()] || k;
        out.push(k.length === 1 ? k.toUpperCase() : k);
        return out;
    }
    function groupOf(b) {
        const a = (b.arg || "") + " " + (b.dispatcher || ""), d = (b.description || "").toLowerCase();
        if (/fluidity-launch|uwsm-app/.test(a)) return 0;
        if (/capture|screenshot|record|colour|ocr|print/.test(a + " " + d)) return 2;
        if (/window|focus|move|swap|resize|split|float|fullscreen|pseudo|group|workspace|layout/.test(a + " " + d)) return 1;
        return 3;
    }
    function refreshBinds() {
        const qv = query.toLowerCase();
        const g = [{ name: "apps", binds: [] }, { name: "windows", binds: [] }, { name: "capture", binds: [] }, { name: "system", binds: [] }];
        let first = true;
        for (const b of bindsAll) {
            if (!b.description || b.mouse || /^Switch to workspace [2-9]|^Move window (silently )?to workspace [2-9]|workspace 10/.test(b.description)) continue;
            if (qv && !b.description.toLowerCase().includes(qv)) continue;
            const col = g[groupOf(b)];
            if (col.binds.length >= 10) continue;
            col.binds.push({ desc: b.description, keys: keysOf(b), on: qv !== "" && first, bind: b });
            if (qv) first = false;
        }
        groups = g;
    }
    function runBind() {
        // Hyprland's Lua binds report function references, not commands, so a bind can't be replayed from here
        return;
    }

    // ---- leader ----
    readonly property var leaderRows: ({
        "": { title: "❖ ;", keys: [
            { k: "s", label: "shot", run: "fluidity-capture screenshot" }, { k: "r", label: "record", run: "fluidity-capture record" },
            { k: "o", label: "ocr", run: "fluidity-capture ocr" }, { k: "p", label: "colour", run: "fluidity-capture colour" },
            { k: "c", label: "clipboard", open: "clipboard" }, { k: "e", label: "emoji", open: "emoji" },
            { k: "n", label: "night", run: "fluidity-toggle nightlight" }, { k: "d", label: "dnd", run: "fluidity-notify dnd" },
            { k: "i", label: "idle", run: "fluidity-toggle idle" }, { k: "g", label: "gaps", run: "fluidity-window gaps" },
            { k: "t", label: "theme", run: "fluidity-theme next" }, { k: "m", label: "mode", run: "fluidity-mode toggle" },
            { k: "w", label: "wall", run: "fluidity-wallpaper next" }, { k: "l", label: "lock", run: "fluidity-lock" },
            { k: "x", label: "power", open: "power" }, { k: "a", label: "windows", open: "switcher" }, { k: "b", label: "widgets", run: "fluidity-widgets toggle" },
            { k: "f", label: "focus 25", run: "fluidity-focus toggle" }, { k: "v", label: "layouts", open: "leader:layouts" }] },
        layouts: { title: "layouts", keys: [
            { k: "s", label: "study", run: "fluidity-layout study" }, { k: "c", label: "code", run: "fluidity-layout code" },
            { k: "w", label: "web", run: "fluidity-layout web" }, { k: "h", label: "chill", run: "fluidity-layout chill" }] },
        capture: { title: "capture", keys: [
            { k: "s", label: "region", run: "fluidity-capture screenshot" }, { k: "f", label: "full screen", run: "fluidity-capture screenshot full" },
            { k: "w", label: "window", run: "fluidity-capture screenshot window" }, { k: "r", label: "record", run: "fluidity-capture record" },
            { k: "a", label: "record + audio", run: "fluidity-capture record audio" }, { k: "o", label: "ocr", run: "fluidity-capture ocr" },
            { k: "p", label: "colour", run: "fluidity-capture colour" }] },
        toggle: { title: "toggle", keys: [
            { k: "n", label: "night light", run: "fluidity-toggle nightlight" }, { k: "i", label: "stay awake", run: "fluidity-toggle idle" },
            { k: "d", label: "do not disturb", run: "fluidity-notify dnd" }, { k: "g", label: "gaps", run: "fluidity-window gaps" },
            { k: "t", label: "transparency", run: "fluidity-window transparency" }, { k: "b", label: "widgets", run: "fluidity-widgets toggle" },
            { k: "m", label: "mac mode", run: "fluidity-mode toggle" }] },
        hardware: { title: "hardware", keys: [
            { k: "a", label: "audio output", run: "fluidity-audio next-output" }, { k: "m", label: "mirror displays", run: "fluidity-display mirror" },
            { k: "l", label: "laptop display", run: "fluidity-display internal toggle" }, { k: "k", label: "keyboard light", run: "fluidity-hw kbd cycle" },
            { k: "t", label: "touchpad", run: "fluidity-hw touchpad toggle" }, { k: "b", label: "battery", run: "fluidity-util battery" }] },
        share: { title: "share", keys: [
            { k: "c", label: "clipboard", run: "fluidity-share clipboard" }, { k: "f", label: "file", run: "fluidity-share file" },
            { k: "s", label: "screenshot", run: "fluidity-share screenshot" }] }
    })
    function leaderKey(k) {
        const hit = items.find(i => i.k === k);
        close();
        if (!hit) return;
        if (hit.open && hit.open.startsWith("leader:")) later(360, () => open("leader", hit.open.slice(7)));
        else if (hit.open) later(360, () => open(hit.open, ""));
        else later(120, () => sh(hit.run));
    }

    // ---- power ----
    readonly property var powerItems: [
        { icon: "", label: "lock", key: "l", run: "fluidity-lock" },
        { icon: "󰤄", label: "sleep", key: "s", run: "systemctl suspend" },
        { icon: "󰍃", label: "log out", key: "o", run: "uwsm stop || hyprctl dispatch exit" },
        { icon: "󰜉", label: "restart", key: "r", run: "systemctl reboot", danger: true },
        { icon: "󰐥", label: "shut down", key: "p", run: "systemctl poweroff", danger: true }]
    function power(i) { const it = powerItems[i]; close(); if (it) later(200, () => sh(it.run)); }

    // ---- wallpaper ----
    property string wallBefore: ""
    Process {
        id: wallProc
        command: ["sh", "-c", "fluidity-wallpaper list; echo '--'; cat \"${XDG_STATE_HOME:-$HOME/.local/state}/fluidity/wallpaper\" 2>/dev/null"]
        stdout: StdioCollector { onStreamFinished: {
            const parts = String(text).split("\n--\n");
            const list = parts[0].split("\n").filter(Boolean);
            island.wallBefore = (parts[1] || "").trim();
            island.items = list.map(p => ({ src: "file://" + p, path: p, name: p.split("/").pop().replace(/\.[^.]+$/, "").replace(/[-_]+/g, " ") }));
            island.index = Math.max(0, list.indexOf(island.wallBefore));
            island.wallInfo();
        } }
    }
    function wallInfo() { const it = items[index]; title = it ? it.name : ""; body = items.length ? (index + 1) + " of " + items.length : "no images in ~/Wallpapers for desktop"; }
    Timer { id: wallPreview; interval: 260; onTriggered: { const it = island.items[island.index]; if (it) island.sh("fluidity-wallpaper set " + island.q(it.path)); } }

    // ---- window switcher ----
    readonly property var glyphs: ({ ghostty: "", kitty: "", alacritty: "", foot: "", zen: "", firefox: "",
        calendio: "", obsidian: "", spotify: "", vesktop: "", discord: "", code: "", "code-insiders": "",
        burrow: "", flowday: "", claude: "", helium: "", chromium: "", signal: "", steam: "" })
    function glyphFor(cls) {
        cls = String(cls || "").toLowerCase();
        for (const k in glyphs) if (cls.includes(k)) return glyphs[k];
        return "";
    }
    function refreshSwitcher() {
        items = Hyprland.toplevels.values.filter(t => t.lastIpcObject?.workspace?.id > 0).slice(0, 7).map(t => {
            const cls = t.lastIpcObject?.class || "";
            return { toplevel: t, icon: glyphFor(cls), title: cls ? cls.replace(/^.*\./, "") : (t.title || "window") };
        });
        index = items.length > 1 ? 1 : 0;
    }
    function focusWindow(it) { if (it) Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${String(it.toplevel.address).replace(/^0x/, "")}" })`) }

    // ---- control centre ----
    property bool wifiOn: true
    property string wifiName: ""
    property bool btOn: false
    property bool nightOn: false
    property bool awakeOn: false
    Process {
        id: statusProc
        command: ["sh", "-c", "nmcli -t -f WIFI radio 2>/dev/null; nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | sed -n 's/^yes://p' | head -1; " +
                  "bluetoothctl show 2>/dev/null | grep -q 'Powered: yes' && echo bt-on || echo bt-off; fluidity-toggle status nightlight; fluidity-toggle status idle"]
        stdout: StdioCollector { onStreamFinished: {
            const l = String(text).split("\n");
            island.wifiOn = l[0] === "enabled"; island.wifiName = l[1] || "";
            island.btOn = l.includes("bt-on"); island.nightOn = l.includes("nightlight on"); island.awakeOn = l.includes("idle on");
            if (island.target === "control") island.refreshControl(true);
        } }
    }
    function refreshControl(noPoll) {
        if (!noPoll) statusProc.running = true;
        items = [
            { icon: wifiOn ? "󰤨" : "󰤭", label: "Wi-Fi", on: wifiOn, state: wifiOn ? (wifiName || "on") : "off", run: "nmcli radio wifi " + (wifiOn ? "off" : "on") },
            { icon: "󰂯", label: "Bluetooth", on: btOn, run: "bluetoothctl power " + (btOn ? "off" : "on") },
            { icon: "󰂛", label: "Focus", on: Notifs.dnd, state: Notifs.dnd ? "no popups" : "off", toggleDnd: true },
            { icon: "󰖔", label: "Night light", on: nightOn, run: "fluidity-toggle nightlight" },
            { icon: "󰅶", label: "Stay awake", on: awakeOn, run: "fluidity-toggle idle" },
            { icon: "󰓃", label: "Output", on: false, state: "next device", run: "fluidity-audio next-output" }];
        groups = [{ icon: sink?.audio?.muted ? "󰝟" : "󰕾", value: sink?.audio?.volume ?? 0 }];
    }
    function control(i) {
        const it = items[i];
        if (!it) return;
        if (it.toggleDnd) Notifs.dnd = !Notifs.dnd; else sh(it.run);
        later(500, () => refreshControl());
    }
    function volume(d) { if (sink?.audio) { sink.audio.muted = false; sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + d)); refreshControl(true); } }

    // ---- notification history ----
    function refreshHistory() {
        items = Notifs.history.values.slice().reverse().slice(0, 6).map(n => ({ n: n, icon: glyphFor(n.appName), title: n.summary || n.appName, desc: n.body || n.appName, meta: n.appName || "" }));
    }

    // ================= keys =================
    // returns true when the key was used
    function key(event) {
        const k = event.key, t = target, txt = event.text, n = items.length;
        const cols = t === "emoji" ? 10 : t === "control" ? 3 : 1;
        if (k === Qt.Key_Escape) { if (query) { query = ""; } else { if (t === "wallpaper" && wallBefore) sh("fluidity-wallpaper set " + q(wallBefore)); close(); } return true; }
        if (t === "leader") { if (txt) leaderKey(txt.toLowerCase()); return true; }
        if (t === "power") {
            const byKey = powerItems.findIndex(p => p.key === txt);
            if (byKey >= 0) { power(byKey); return true; }
            if (k === Qt.Key_Left) index = (index + n - 1) % n;
            else if (k === Qt.Key_Right || k === Qt.Key_Tab) index = (index + 1) % n;
            else if (k === Qt.Key_Return || k === Qt.Key_Enter) power(index);
            return true;
        }
        if (t === "wallpaper" || t === "switcher") {
            if (k === Qt.Key_Left) index = (index + n - 1) % Math.max(1, n);
            else if (k === Qt.Key_Right || k === Qt.Key_Tab) index = (index + 1) % Math.max(1, n);
            else if (k === Qt.Key_Return || k === Qt.Key_Enter) { if (t === "switcher") focusWindow(items[index]); wallBefore = ""; close(); return true; }
            else return true;
            if (t === "wallpaper") { wallInfo(); wallPreview.restart(); }
            return true;
        }
        if (k === Qt.Key_Down) { index = Math.min(n - 1, index + cols); if (t === "clipboard") previewClip(); return true; }
        if (k === Qt.Key_Up) { index = Math.max(0, index - cols); if (t === "clipboard") previewClip(); return true; }
        if ((t === "emoji" || t === "control") && k === Qt.Key_Right) { index = Math.min(n - 1, index + 1); return true; }
        if ((t === "emoji" || t === "control") && k === Qt.Key_Left) { index = Math.max(0, index - 1); return true; }
        if (t === "emoji" && k === Qt.Key_Tab && !query) { cat = (cat + 1) % emojiCats.length; index = 0; refreshEmoji(); return true; }
        if (t === "control" && (txt === "-" || txt === "=" || txt === "+")) { volume(txt === "-" ? -0.05 : 0.05); return true; }
        if (k === Qt.Key_Return || k === Qt.Key_Enter) {
            const it = items[index];
            if (t === "control") { control(index); return true; }
            const shift = !!(event.modifiers & Qt.ShiftModifier);
            close();
            later(t === "emoji" || t === "clipboard" ? 0 : 120, () => {
                if (t === "launcher") launch(it, shift);
                else if (t === "emoji") pickEmoji(it);
                else if (t === "clipboard") pasteClip(it);
                else if (t === "cheatsheet") runBind();
                else if (t === "notifications" && it?.n) { const a = it.n.actions?.[0]; if (a) a.invoke(); }
            });
            return true;
        }
        if (k === Qt.Key_Delete) {
            if (t === "clipboard") deleteClip(items[index]);
            else if (t === "notifications") { Notifs.clear(); items = []; }
            return true;
        }
        if (k === Qt.Key_Backspace) { query = query.slice(0, -1); return true; }
        if (["launcher", "emoji", "clipboard", "cheatsheet"].includes(t) && txt && txt >= " " && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) { query += txt; return true; }
        return false;
    }

    // ================= IPC =================
    IpcHandler {
        target: "island"
        function toggle(view: string, arg: string): void { island.toggle(view, arg) }
        function open(view: string, arg: string): void { island.open(view, arg) }
        function close(): void { island.close() }
        function notify(title: string, body: string): void { island.passiveTitle = title; island.passiveBody = body; island.passiveIcon = "󰂚"; island.passiveKeys = []; island.passive("notify", 4500) }
        function state(): string { return island.overlayShown ? island.target : "idle" }
    }
    IpcHandler {
        target: "bar"
        function reveal(): void { island.barShown = true }   // not "show": that is a qs ipc subcommand
        function conceal(): void { island.barShown = false }
        function toggle(): void { island.barShown = !island.barShown }
    }
    IpcHandler {
        target: "osd"
        function brightness(percent: int): void { island.osd("󰃠", percent / 100) }
        function volume(percent: int): void { island.osd("󰕾", percent / 100) }
    }
    IpcHandler { // theme shells written for the old shell call these
        target: "panel"
        function toggle(name: string): void { island.toggle(name === "power" ? "power" : "control", "") }
        function close(): void { island.close() }
    }
    IpcHandler {
        target: "media"
        function toggle(): void { island.player?.togglePlaying() }
        function next(): void { island.player?.next() }
        function previous(): void { island.player?.previous() }
    }
}
