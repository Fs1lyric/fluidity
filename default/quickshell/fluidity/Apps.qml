pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// The Fluid showcase apps' brain: data for each app's island view (views/*App.qml) and its keys.
// Island.qml opens them like any view and hands their keys here (key() returns true when used).
Singleton {
    id: apps
    readonly property var views: ["calendar"]
    property var data: ({})
    // leader ; u: one letter per app
    readonly property var leaderKeys: [{ k: "c", label: "calendar", open: "calendar" }]
    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME") || (home + "/.local/state")) + "/fluidity"
    readonly property string calDb: home + "/.local/share/calendio/cal.db"
    function patch(o) { const n = Object.assign({}, data); for (const k in o) n[k] = o[k]; data = n; }
    function iso(dt) { return Qt.formatDate(dt, "yyyy-MM-dd") }

    function load(v, arg) {
        data = ({});
        if (v === "calendar") calOpen(arg);
    }
    function key(event, v) {
        if (v === "calendar") return calKey(event);
        return false;
    }
    function picked(v, i) {
        if (v === "calendar") { const c = calCells()[i]; if (c) calGo(c); }
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
