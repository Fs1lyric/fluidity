import QtQuick

// Screen Time: the whole window of the Screen Time app (shell.qml here; fluidity/views links it for tools/render.py). Pure: the shell fills
// `d` from `fluidity-wellbeing stats PERIOD DATE` and owns period / sel; this only draws and emits.
//   d: {start, end, total, prev, days, avg, apps: [{app, minutes}], bars: [n]}
//   period: day | week | month | year   sel: the selected bar   now: "YYYY-MM-DDTHH" (to light the current bar)
Item {
    id: v
    property var pal: ({})
    property bool animate: true
    property var d: ({})
    property string period: "week"
    property int sel: -1
    property string now: ""
    signal pickPeriod(string p)
    signal step(int dir)
    signal pickBar(int i)
    signal drill(int i)

    readonly property string sans: "Geist"
    readonly property string serif: "Instrument Serif"
    readonly property string mono: "JetBrainsMono Nerd Font"
    function alpha(c, a) { const q = Qt.color(c || "#ffffff"); return Qt.rgba(q.r, q.g, q.b, a) }
    function hm(m) { m = Math.round(m || 0); return m >= 60 ? Math.floor(m / 60) + "h " + (m % 60) + "m" : m + "m" }
    function day(s) { const p = String(s || "2000-01-01").split("-").map(Number); return new Date(p[0], p[1] - 1, p[2]) }
    function plus(dt, n) { const x = new Date(dt); x.setDate(x.getDate() + n); return x }
    readonly property var start: day(d.start)
    readonly property var nowDay: day(now.slice(0, 10))
    readonly property int nowHour: Number(now.slice(11, 13)) || 0
    readonly property var bars: d.bars || []
    readonly property int peak: Math.max(1, ...bars)
    readonly property var apps: (d.apps || []).slice(0, 8)
    readonly property int most: Math.max(1, ...(apps.map(x => x.minutes)))
    readonly property var months: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    readonly property var weekdays: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // the bar that holds "now", or -1 when this period isn't the current one
    readonly property int current: {
        const n = nowDay, s = start;
        if (period === "day") return n.getTime() === s.getTime() ? nowHour : -1;
        if (period === "year") return n.getFullYear() === s.getFullYear() ? n.getMonth() : -1;
        const i = Math.round((n - s) / 86400000);
        return i >= 0 && i < bars.length ? i : -1;
    }
    readonly property string title: {
        const s = start, e = day(d.end), yr = s.getFullYear() !== nowDay.getFullYear() ? " " + s.getFullYear() : "";
        if (period === "day") return current >= 0 ? "Today" : Math.round((nowDay - s) / 86400000) === 1 ? "Yesterday" : Qt.formatDate(s, "ddd d MMM") + yr;
        if (period === "week") return current >= 0 ? "This week" : s.getMonth() === e.getMonth()
            ? s.getDate() + " – " + e.getDate() + " " + months[e.getMonth()] + yr : s.getDate() + " " + months[s.getMonth()] + " – " + e.getDate() + " " + months[e.getMonth()] + yr;
        if (period === "month") return Qt.formatDate(s, "MMMM yyyy");
        return String(s.getFullYear());
    }
    readonly property string sub: {
        const s = start, e = day(d.end);
        if (period === "day") return Qt.formatDate(s, "dddd d MMMM yyyy");
        if (period === "week") return s.getDate() + " " + months[s.getMonth()] + " – " + e.getDate() + " " + months[e.getMonth()] + " " + e.getFullYear();
        return (d.days || 0) + " days with screen time";
    }
    function barLabel(i) {
        if (period === "day") return i % 6 ? "" : i === 0 ? "12a" : i === 12 ? "12p" : i < 12 ? i + "a" : (i - 12) + "p";
        if (period === "week") return weekdays[i];
        if (period === "month") return i === 0 || (i + 1) % 5 === 0 ? String(i + 1) : "";
        return months[i];
    }
    function barName(i) {
        if (period === "day") { const h = i % 12 || 12, ap = i < 12 ? "am" : "pm"; return h + ap + " – " + ((i + 1) % 12 || 12) + ((i + 1) % 24 < 12 ? "am" : "pm"); }
        if (period === "year") return months[i] + " " + start.getFullYear();
        return Qt.formatDate(plus(start, i), "ddd d MMM");
    }
    readonly property string unit: ({ day: "day", week: "week", month: "month", year: "year" })[period]
    readonly property var delta: {
        const t = d.total || 0, p = d.prev || 0;
        if (!p) return t ? { text: "nothing the " + unit + " before", up: true } : { text: "", up: true };
        const pct = Math.round((t - p) / p * 100);
        return { text: (pct >= 0 ? "↑ " : "↓ ") + Math.abs(pct) + "% from the " + unit + " before (" + hm(p) + ")", up: pct >= 0 };
    }

    Rectangle { anchors.fill: parent; color: v.pal.bg || "#111417" }

    // ---- header: the period tabs and where you are ----
    Row {
        id: tabs
        x: 32; y: 26; spacing: 6
        Repeater {
            model: [["day", "d"], ["week", "w"], ["month", "m"], ["year", "y"]]
            Rectangle {
                readonly property bool on: v.period === modelData[0]
                width: tl.implicitWidth + 34; height: 32; radius: 16
                color: on ? v.pal.accent : tm.containsMouse ? v.alpha(v.pal.fg, 0.08) : v.alpha(v.pal.fg, 0.04)
                Behavior on color { enabled: v.animate; ColorAnimation { duration: 140 } }
                Row {
                    anchors.centerIn: parent; spacing: 7
                    Text { id: tl; text: modelData[0]; color: parent.parent.on ? "#101316" : v.pal.fg; font.family: v.sans; font.pixelSize: 14; font.weight: Font.Medium }
                    Text { text: modelData[1]; anchors.verticalCenter: parent.verticalCenter; color: parent.parent.on ? v.alpha("#101316", 0.55) : v.pal.dim; font.family: v.mono; font.pixelSize: 11 }
                }
                MouseArea { id: tm; anchors.fill: parent; hoverEnabled: true; onClicked: v.pickPeriod(modelData[0]) }
            }
        }
    }
    Row {
        anchors.right: parent.right; anchors.rightMargin: 32; y: 26; height: 32; spacing: 6
        Repeater {
            model: [[-1, "\u{f0141}", "h"], [1, "\u{f0142}", "l"]]
            Rectangle {
                width: 32; height: 32; radius: 16; color: nm.containsMouse ? v.alpha(v.pal.fg, 0.1) : v.alpha(v.pal.fg, 0.04)
                Text { anchors.centerIn: parent; text: modelData[1]; color: v.pal.fg; font.family: v.mono; font.pixelSize: 16 }
                MouseArea { id: nm; anchors.fill: parent; hoverEnabled: true; onClicked: v.step(modelData[0]) }
            }
        }
    }

    // ---- the headline ----
    Column {
        x: 32; y: 84; spacing: 2
        Text { text: v.title; color: v.pal.dim; font.family: v.sans; font.pixelSize: 15; font.weight: Font.Medium }
        Row {
            spacing: 16
            Text { text: v.hm(v.d.total); color: v.pal.fg; font.family: v.serif; font.italic: true; font.pixelSize: 64 }
            Column {
                anchors.bottom: parent.bottom; anchors.bottomMargin: 12; spacing: 3
                Text { visible: v.period !== "day"; text: v.hm(v.d.avg) + " a day on average"; color: v.pal.accent; font.family: v.sans; font.pixelSize: 14; font.weight: Font.Medium }
                Text { text: v.delta.text; color: v.delta.up ? v.pal.orange : v.pal.cyan; font.family: v.sans; font.pixelSize: 13 }
            }
        }
        Text { text: v.sub; color: v.alpha(v.pal.dim, 0.8); font.family: v.sans; font.pixelSize: 12 }
    }

    // ---- the chart ----
    Item {
        id: chart
        x: 32; y: 222; width: v.width - 64; height: 210
        readonly property int n: Math.max(1, v.bars.length)
        readonly property real gap: n > 24 ? 4 : 6
        readonly property real bw: (width - gap * (n - 1)) / n
        readonly property real plot: height - 26
        // average line (per day) on the week and month charts
        Rectangle {
            visible: (v.period === "week" || v.period === "month") && (v.d.avg || 0) > 0
            y: chart.plot - chart.plot * Math.min(1, (v.d.avg || 0) / v.peak); width: parent.width; height: 1
            color: v.alpha(v.pal.accent, 0.45)
            Text { anchors.right: parent.right; anchors.bottom: parent.top; anchors.bottomMargin: 2; text: "avg"; color: v.alpha(v.pal.accent, 0.8); font.family: v.mono; font.pixelSize: 10 }
        }
        Repeater {
            model: v.bars
            Item {
                x: index * (chart.bw + chart.gap); width: chart.bw; height: chart.height
                readonly property bool picked: index === v.sel
                Rectangle {
                    anchors.bottom: parent.bottom; anchors.bottomMargin: 26; width: parent.width; radius: Math.min(5, width / 3)
                    height: Math.max(3, chart.plot * modelData / v.peak)
                    color: parent.picked ? v.pal.accent : index === v.current ? v.alpha(v.pal.accent, 0.75)
                         : bm.containsMouse ? v.alpha(v.pal.cyan, 0.8) : v.alpha(v.pal.cyan, modelData ? 0.5 : 0.1)
                    Behavior on height { enabled: v.animate; NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                }
                Text { anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; text: v.barLabel(index)
                    color: parent.picked || index === v.current ? v.pal.fg : v.pal.dim; font.family: v.mono; font.pixelSize: 11 }
                MouseArea { id: bm; anchors.fill: parent; hoverEnabled: true; onEntered: v.pickBar(index); onClicked: v.drill(index) }
            }
        }
    }
    Text {
        x: 32; y: 442
        text: v.sel >= 0 && v.sel < v.bars.length ? v.barName(v.sel) + "  ·  " + v.hm(v.bars[v.sel]) + (v.period === "day" ? "" : "   ↵ open") : " "
        color: v.pal.fg; font.family: v.sans; font.pixelSize: 13
    }

    // ---- most used ----
    Text { x: 32; y: 478; text: "most used"; color: v.pal.dim; font.family: v.sans; font.pixelSize: 13; font.weight: Font.Medium }
    Grid {
        x: 32; y: 504; width: v.width - 64; columns: 2; columnSpacing: 40; rowSpacing: 10
        Text { visible: !v.apps.length; text: "No screen time in this " + v.unit + "."; color: v.pal.dim; font.family: v.sans; font.pixelSize: 14 }
        Repeater {
            model: v.apps
            Item {
                width: (v.width - 64 - 40) / 2; height: 24
                Text { width: 110; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter; text: modelData.app; color: v.pal.fg; font.family: v.sans; font.pixelSize: 14 }
                Rectangle { x: 118; width: Math.max(6, (parent.width - 118 - 110) * modelData.minutes / v.most); height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter
                    gradient: Gradient { orientation: Gradient.Horizontal; GradientStop { position: 0; color: v.pal.accent } GradientStop { position: 1; color: v.pal.cyan } } }
                Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    text: v.hm(modelData.minutes) + "  " + Math.round(100 * modelData.minutes / Math.max(1, v.d.total)) + "%"; color: v.pal.dim; font.family: v.mono; font.pixelSize: 12 }
            }
        }
    }

    Text {
        anchors.bottom: parent.bottom; anchors.bottomMargin: 16; anchors.horizontalCenter: parent.horizontalCenter
        text: "d w m y  period   ·   h l  back / forward   ·   ← →  pick a bar   ·   ↵  open it   ·   u  zoom out   ·   t  today   ·   q  close"
        color: v.alpha(v.pal.dim, 0.7); font.family: v.mono; font.pixelSize: 11
    }
}
