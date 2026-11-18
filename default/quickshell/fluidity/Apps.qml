pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// The Fluid showcase apps' brain: data for each app's island view (views/*App.qml) and its keys.
// Island.qml opens them like any view and hands their keys here (key() returns true when used).
Singleton {
    id: apps
    readonly property var views: ["calendar", "media"]
    property string open: ""       // the app on screen, "" when none (polling runs only then)
    property var data: ({})
    // leader ; u: one letter per app
    readonly property var leaderKeys: [{ k: "c", label: "calendar", open: "calendar" }, { k: "m", label: "media", open: "media" }]
    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (home + "/.local/state")) + "/fluidity"
    readonly property string calDb: home + "/.local/share/calendio/cal.db"
    function patch(o) { const n = Object.assign({}, data); for (const k in o) n[k] = o[k]; data = n; }
    function iso(dt) { return Qt.formatDate(dt, "yyyy-MM-dd") }

    function load(v, arg) {
        data = ({}); open = v;
        if (v === "calendar") calOpen(arg);
        else if (v === "media") { Island.index = 1; mediaTick(); }
    }
    function key(event, v) {
        if (v === "calendar") return calKey(event);
        if (v === "media") return mediaKey(event);
        return false;
    }
    function picked(v, i) {
        if (v === "calendar") { const c = calCells()[i]; if (c) calGo(c); }
        else if (v === "media") { Island.index = i; mediaPress(i); }
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
