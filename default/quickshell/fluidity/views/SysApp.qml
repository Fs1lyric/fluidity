import QtQuick

// System: CPU / RAM / temperature / disk / battery rings, a CPU history line, the busiest processes, and
// volume + brightness sliders. Keys: ↑ ↓ pick a slider, ← → change it, h opens btop.
AppBase {
    id: a
    readonly property var rings: [{ label: "cpu", v: d.cpu, unit: "%" }, { label: "ram", v: d.ram, unit: "%" }, { label: "temp", v: d.temp, unit: "°" },
                                  { label: "disk", v: d.disk, unit: "%" }].concat(d.battery >= 0 ? [{ label: "battery", v: d.battery, unit: "%" }] : [])
    AppHeader { width: parent.width; pal: a.pal; title: "System"; status: "up " + (a.d.uptime || "") + (a.d.ramText ? " · " + a.d.ramText : ""); showSwitch: false }
    Row {
        x: 24; y: 66; spacing: 16
        Repeater {
            model: a.rings
            Item {
                width: 92; height: 112
                Canvas {
                    width: 92; height: 92
                    property var watch: [modelData.v, a.pal.accent]
                    onWatchChanged: requestPaint()
                    onPaint: { const c = getContext("2d"), p = Math.max(0, Math.min(1, (modelData.v || 0) / 100)); c.reset(); c.lineWidth = 8; c.lineCap = "round"
                        c.strokeStyle = "rgba(255,255,255,0.08)"; c.beginPath(); c.arc(46, 46, 38, 0, 2 * Math.PI); c.stroke()
                        c.strokeStyle = p > 0.85 ? a.pal.red : index % 2 ? a.pal.cyan : a.pal.accent; c.beginPath(); c.arc(46, 46, 38, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * p); c.stroke() }
                    Text { anchors.centerIn: parent; text: Math.round(modelData.v || 0) + modelData.unit; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 26 }
                }
                Text { y: 96; width: 92; horizontalAlignment: Text.AlignHCenter; text: modelData.label; color: a.pal.dim; font.family: a.mono; font.pixelSize: 11 }
            }
        }
    }
    Rectangle { // cpu history + top processes
        x: 24; y: 194; width: parent.width - 48; height: 96; radius: 20; color: a.faint
        Canvas {
            x: 14; y: 12; width: parent.width - 260; height: parent.height - 24
            property var watch: [a.d.hist, a.pal.accent]
            onWatchChanged: requestPaint()
            onPaint: { const c = getContext("2d"), h = a.d.hist || [], w = width, ht = height; c.reset(); if (h.length < 2) return;
                c.beginPath(); h.forEach((v, i) => { const x = w * i / (h.length - 1), y = ht - ht * Math.min(100, v) / 100; i ? c.lineTo(x, y) : c.moveTo(x, y) });
                c.strokeStyle = a.pal.accent; c.lineWidth = 2; c.stroke(); c.lineTo(w, ht); c.lineTo(0, ht); c.closePath(); c.fillStyle = a.alpha(a.pal.accent, 0.12); c.fill() }
        }
        Column {
            anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; width: 210; spacing: 4
            Repeater { model: (a.d.top || []).slice(0, 3)
                Item { width: parent.width; height: 20
                    Text { text: modelData.name; color: a.pal.fg; font.family: a.sans; font.pixelSize: 13; width: 150; elide: Text.ElideRight }
                    Text { anchors.right: parent.right; text: modelData.cpu.toFixed(1) + "%"; color: a.pal.dim; font.family: a.mono; font.pixelSize: 12 } } }
        }
    }
    Column {
        x: 24; y: 306; spacing: 8
        Repeater {
            model: a.d.sliders || []
            Rectangle {
                readonly property bool lit: index === a.sel
                width: a.width - 48; height: 42; radius: 18; color: lit ? a.alpha(a.pal.accent, 0.1) : "transparent"
                border.width: lit ? 1 : 0; border.color: a.alpha(a.pal.accent, 0.5)
                Text { x: 14; anchors.verticalCenter: parent.verticalCenter; text: modelData.icon; font.family: a.mono; font.pixelSize: 18; color: a.pal.accent }
                Rectangle { x: 50; width: parent.width - 120; height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter; color: a.faint
                    Grad { pal: a.pal; height: 8; radius: 4; width: parent.width * Math.max(0, Math.min(1, modelData.value)) } }
                Text { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: Math.round(modelData.value * 100); color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 22 }
                MouseArea { anchors.fill: parent; onClicked: a.picked(index) }
            }
        }
    }
}
