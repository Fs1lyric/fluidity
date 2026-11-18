import QtQuick

// Calendar: the month on the left (dots on days with Calendio blocks), the chosen day's blocks on the right,
// and the sun's arc for today along the bottom. Keys: arrows move the day, , . the month, t today, ↵ Calendio.
AppBase {
    id: a
    readonly property int year: d.year ?? 2026
    readonly property int month: d.month ?? 0
    readonly property var names: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    function iso(y, m, day) { return y + "-" + String(m + 1).padStart(2, "0") + "-" + String(day).padStart(2, "0") }
    readonly property var cells: {
        const first = new Date(year, month, 1), lead = (first.getDay() + 6) % 7, n = new Date(year, month + 1, 0).getDate(), out = [];
        for (let i = 0; i < 42; i++) {
            const dt = new Date(year, month, i - lead + 1);
            out.push({ day: dt.getDate(), iso: iso(dt.getFullYear(), dt.getMonth(), dt.getDate()), inMonth: dt.getMonth() === month });
        }
        return out;
    }
    function mins(t) { return t ? Number(t.slice(0, 2)) * 60 + Number(t.slice(3, 5)) : 0 }

    // ---- month ----
    Column {
        x: 24; y: 20; width: 360; spacing: 10
        Row {
            spacing: 10
            Text { text: a.names[a.month]; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 34 }
            Text { text: a.year; color: a.pal.dim; font.family: a.mono; font.pixelSize: 13; anchors.baseline: parent.children[0].baseline }
        }
        Grid {
            columns: 7; spacing: 4
            Repeater { model: ["M", "T", "W", "T", "F", "S", "S"]
                Text { width: 48; horizontalAlignment: Text.AlignHCenter; text: modelData; color: index > 4 ? a.pal.accent : a.pal.dim; font.family: a.mono; font.pixelSize: 11 } }
            Repeater {
                model: a.cells
                Item {
                    width: 48; height: 38
                    readonly property bool isSel: modelData.iso === a.d.sel
                    readonly property bool isToday: modelData.iso === a.d.today
                    Grad { anchors.fill: parent; radius: 14; pal: a.pal; visible: parent.isSel }
                    Rectangle { anchors.fill: parent; radius: 14; color: "transparent"; visible: parent.isToday && !parent.isSel; border.width: 1.5; border.color: a.pal.accent }
                    Text { anchors.centerIn: parent; text: modelData.day; font.family: a.sans; font.pixelSize: 14; font.weight: parent.isToday ? Font.DemiBold : Font.Normal
                        color: parent.isSel ? a.ink : !modelData.inMonth ? a.alpha(a.pal.dim, 0.4) : a.pal.fg }
                    Rectangle { width: 4; height: 4; radius: 2; anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 4
                        visible: (a.d.marks || []).includes(modelData.iso); color: parent.isSel ? a.ink : a.pal.accent }
                    MouseArea { anchors.fill: parent; onClicked: a.picked(index) }
                }
            }
        }
    }

    // ---- the chosen day ----
    Rectangle {
        x: 404; y: 20; width: parent.width - 404 - 20; height: 318; radius: 22; color: a.faint
        Column {
            anchors.fill: parent; anchors.margins: 18; spacing: 8
            Text {
                text: { const p = (a.d.sel || "2026-01-01").split("-").map(Number), dt = new Date(p[0], p[1] - 1, p[2]);
                        return (a.d.sel === a.d.today ? "Today, " : "") + Qt.formatDate(dt, "dddd d MMMM") }
                color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 24
            }
            Text { visible: !(a.d.blocks || []).length; topPadding: 30; text: "Nothing planned. ↵ opens Calendio."; color: a.pal.dim; font.family: a.sans; font.pixelSize: 14 }
            Repeater {
                model: (a.d.blocks || []).slice(0, 6)
                Rectangle {
                    width: parent.width; height: 40; radius: 14
                    color: modelData.now ? a.alpha(modelData.color || a.pal.accent, 0.18) : "transparent"
                    opacity: modelData.done ? 0.5 : 1
                    Rectangle { x: 10; width: 4; height: 22; radius: 2; anchors.verticalCenter: parent.verticalCenter; color: modelData.color || a.pal.accent }
                    Text { x: 26; anchors.verticalCenter: parent.verticalCenter; text: modelData.time; color: a.pal.dim; font.family: a.mono; font.pixelSize: 12 }
                    Text { x: 80; width: parent.width - 150; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter; text: modelData.title; color: a.pal.fg; font.family: a.sans; font.pixelSize: 14; font.weight: Font.Medium }
                    Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: modelData.now ? "now" : "→ " + modelData.end
                        color: modelData.now ? a.pal.accent : a.pal.dim; font.family: a.mono; font.pixelSize: 11 }
                }
            }
        }
    }

    // ---- the sun ----
    Item {
        id: sun
        x: 24; y: 352; width: parent.width - 48; height: 70
        readonly property real rise: a.mins(a.d.sunrise)
        readonly property real set: a.mins(a.d.sunset)
        readonly property real now: a.mins(a.d.now)
        readonly property real t: set > rise ? Math.max(0, Math.min(1, (now - rise) / (set - rise))) : -1
        Canvas {
            anchors.fill: parent
            property var watch: [sun.t, a.pal.accent]
            onWatchChanged: requestPaint()
            onPaint: {
                const c = getContext("2d"), w = width, h = height; c.reset();
                c.strokeStyle = "rgba(255,255,255,0.1)"; c.lineWidth = 1; c.beginPath(); c.moveTo(0, h - 8); c.lineTo(w, h - 8); c.stroke();
                if (sun.t < 0) return;
                c.setLineDash([4, 5]); c.strokeStyle = "rgba(255,255,255,0.22)"; c.lineWidth = 2;
                c.beginPath(); for (let i = 0; i <= 60; i++) { const x = 80 + (w - 160) * i / 60, y = h - 8 - (h - 20) * Math.sin(Math.PI * i / 60); i ? c.lineTo(x, y) : c.moveTo(x, y) } c.stroke();
                c.setLineDash([]);
                const x = 80 + (w - 160) * sun.t, y = h - 8 - (h - 20) * Math.sin(Math.PI * sun.t);
                c.fillStyle = a.pal.accent; c.beginPath(); c.arc(x, y, 7, 0, 2 * Math.PI); c.fill();
                c.fillStyle = a.alpha(a.pal.accent, 0.18); c.beginPath(); c.arc(x, y, 14, 0, 2 * Math.PI); c.fill();
            }
        }
        Text { visible: sun.t >= 0; anchors.left: parent.left; anchors.bottom: parent.bottom; text: "󰖜 " + a.d.sunrise; color: a.pal.dim; font.family: a.mono; font.pixelSize: 12 }
        Text { visible: sun.t >= 0; anchors.right: parent.right; anchors.bottom: parent.bottom; text: a.d.sunset + " 󰖛"; color: a.pal.dim; font.family: a.mono; font.pixelSize: 12 }
        Text { visible: sun.t < 0; anchors.bottom: parent.bottom; anchors.bottomMargin: 14; text: "← → day · , . month · t today · ↵ Calendio"; color: a.pal.dim; font.family: a.sans; font.pixelSize: 12 }
    }
}
