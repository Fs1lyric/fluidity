// Screen Time: a real window with your screen time by day, week, month and year.
// `fluidity-wellbeing app` opens it (qs -n -c screentime, so never twice); Super+F and the bar's screen time button
// call that. The numbers come from `fluidity-wellbeing stats PERIOD DATE`; the drawing is ScreenTimeView.qml.
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root
    property string period: "week"
    property string anchor: iso(new Date())   // any day inside the period on show
    property int sel: -1
    property var data: ({})
    property string now: ""

    function iso(dt) { return Qt.formatDate(dt, "yyyy-MM-dd") }
    function day(s) { const p = s.split("-").map(Number); return new Date(p[0], p[1] - 1, p[2]) }
    function stamp() { now = Qt.formatDateTime(new Date(), "yyyy-MM-ddTHH") }
    function load() { stamp(); stats.command = ["fluidity-wellbeing", "stats", period, anchor]; stats.running = true }
    function show(p, a) { if (p === period && a === anchor) return; period = p; anchor = a; sel = -1; load() }
    function step(dir) {
        const d = day(anchor);
        if (period === "day") d.setDate(d.getDate() + dir);
        else if (period === "week") d.setDate(d.getDate() + 7 * dir);
        else if (period === "month") { d.setDate(1); d.setMonth(d.getMonth() + dir); }
        else d.setFullYear(d.getFullYear() + dir);
        show(period, iso(d));
    }
    // a bar opens the next level down: a day of the week or month, a month of the year
    function drill(i) {
        if (!data.start || period === "day") return;
        const s = day(data.start);
        if (period === "year") show("month", iso(new Date(s.getFullYear(), i, 1)));
        else { s.setDate(s.getDate() + i); show("day", iso(s)); }
    }
    function zoomOut() { show(({ day: "week", week: "month", month: "year", year: "year" })[period], anchor) }

    // the theme's colours, live (same parse as fluidity/Theme.qml)
    property var pal: ({ accent: "#d7e59b", cyan: "#c2e6d6", blue: "#a9b8e8", red: "#f2a7a7", fg: "#e3e4da", dim: "#878880",
                         muted: "#3a3f45", bg: "#111417", yellow: "#e8d98a", magenta: "#c8a8e0", orange: "#f0c08a" })
    readonly property var keys: ({ accent: "accent", cyan: "cyan", blue: "blue", red: "red", foreground: "fg",
        dark_foreground: "dim", muted: "muted", background: "bg", yellow: "yellow", magenta: "magenta", orange: "orange" })
    FileView {
        path: Quickshell.env("HOME") + "/.config/fluidity/theme/colors.toml"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const p = Object.assign({}, root.pal);
            for (const line of String(text()).split("\n")) {
                const m = line.match(/^\s*([a-z_]+)\s*=\s*"(#[0-9a-fA-F]{6})"/);
                if (m && root.keys[m[1]]) p[root.keys[m[1]]] = m[2];
            }
            root.pal = p;
        }
    }

    Process {
        id: stats
        stdout: StdioCollector { onStreamFinished: { try { root.data = JSON.parse(text) } catch (e) { root.data = ({}) } } }
    }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: root.load() }   // a new sample lands every minute
    Component.onCompleted: load()

    FloatingWindow {
        id: win
        title: "Screen Time"
        implicitWidth: 960; implicitHeight: 680
        color: root.pal.bg
        onVisibleChanged: if (!visible) Qt.quit()

        ScreenTimeView {
            anchors.fill: parent
            focus: true
            pal: root.pal; d: root.data; period: root.period; sel: root.sel; now: root.now
            onPickPeriod: p => root.show(p, root.iso(new Date()))
            onStep: dir => root.step(dir)
            onPickBar: i => root.sel = i
            onDrill: i => root.drill(i)
            Keys.onPressed: event => {
                const n = (root.data.bars || []).length, k = event.key, t = event.text;
                if (t === "d" || t === "w" || t === "m" || t === "y")
                    root.show(({ d: "day", w: "week", m: "month", y: "year" })[t], root.iso(new Date()));
                else if (t === "h" || k === Qt.Key_PageUp) root.step(-1);
                else if (t === "l" || k === Qt.Key_PageDown) root.step(1);
                else if (k === Qt.Key_Left) root.sel = root.sel < 0 ? n - 1 : Math.max(0, root.sel - 1);
                else if (k === Qt.Key_Right) root.sel = root.sel < 0 ? 0 : Math.min(n - 1, root.sel + 1);
                else if ((k === Qt.Key_Return || k === Qt.Key_Enter) && root.sel >= 0) root.drill(root.sel);
                else if (t === "u" || k === Qt.Key_Backspace) root.zoomOut();
                else if (t === "t") root.show(root.period, root.iso(new Date()));
                else if (t === "r") root.load();
                else if (t === "q" || k === Qt.Key_Escape) Qt.quit();
                else return;
                event.accepted = true;
            }
        }
    }
}
