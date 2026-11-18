// The desktop cards: CHRONO (clock), the glossy blue Aero player, SKY ARC (sun between sunrise and sunset)
// and ATMOS (weather). Lives on the bottom layer, under the windows.
import QtQuick
import "Pal.js" as P

Item {
    id: v
    property var sys
    signal act(string what, var arg)
    readonly property date now: sys?.now ?? new Date()
    function secs(hms) { const p = (hms || "").split(":").map(Number); return p.length >= 2 ? p[0] * 3600 + p[1] * 60 + (p[2] || 0) : NaN }
    readonly property real rise: secs(sys?.sunrise) || 6 * 3600
    readonly property real set: secs(sys?.sunset) || 18 * 3600
    readonly property real nowS: now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds()
    readonly property real dayFrac: Math.max(0, Math.min(1, (nowS - rise) / (set - rise)))
    function hm(s) { s = Math.max(0, s); return Math.floor(s / 3600) + "h " + String(Math.floor(s % 3600 / 60)).padStart(2, "0") + "m" }
    readonly property int doy: Math.floor((now - new Date(now.getFullYear(), 0, 0)) / 86400000)

    Glass {
        x: 24; y: 56; width: 324; height: 148; title: "CHRONO"; note: "LOCAL · UTC" + (-(new Date().getTimezoneOffset()) / 60 >= 0 ? "+" : "") + (-(new Date().getTimezoneOffset()) / 60)
        Row { x: 16; y: 0; spacing: 6
              Text { text: Qt.formatDateTime(v.now, "HH:mm"); font.family: P.sans; font.pixelSize: 54; font.weight: Font.Light; color: P.ink }
              Text { text: Qt.formatDateTime(v.now, "ss"); font.family: P.sans; font.pixelSize: 15; color: P.blue; anchors.bottom: parent.bottom; anchors.bottomMargin: 10 } }
        Text { x: 16; y: 66; text: Qt.formatDateTime(v.now, "dddd · d MMMM yyyy"); font.family: P.sans; font.pixelSize: 12; font.weight: Font.Medium; color: "#4a5361" }
        Text { x: 16; y: 92; text: "DAY " + v.doy + "    WEEK " + Math.ceil(v.doy / 7) + "    UP " + (v.sys?.uptime ?? "").replace(/ hours?,?/, "h").replace(/ minutes?/, "m")
               font.family: P.sans; font.pixelSize: 9; font.letterSpacing: 1.2; color: P.label }
    }
    // the glossy Aero player
    Item {
        x: 24; y: 222; width: 350; height: 136
        Rectangle { anchors.fill: parent; radius: 30; border.color: "#9cc4ec"; border.width: 2
                    gradient: Gradient { GradientStop { position: 0; color: "#7fb8f0" } GradientStop { position: 0.5; color: "#2e7fd8" } GradientStop { position: 1; color: "#1b5fb8" } } }
        Rectangle { x: 6; y: 4; width: parent.width - 12; height: parent.height * 0.42; radius: 26; opacity: 0.45
                    gradient: Gradient { GradientStop { position: 0; color: "white" } GradientStop { position: 1; color: "#00ffffff" } } }
        Column { x: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                 Repeater { model: [["󰒮", "prev"], [v.sys?.playing ? "󰏤" : "󰐊", "play"], ["󰒭", "next"]]
                            Rectangle { required property var modelData; width: 34; height: 30; radius: 15; color: "#e8f2fc"; border.color: "#8ab4e0"
                                        Text { anchors.centerIn: parent; text: parent.modelData[0]; color: P.deep; font.family: P.mono; font.pixelSize: 14 }
                                        MouseArea { anchors.fill: parent; onClicked: v.act(parent.modelData[1], null) } } } }
        Rectangle {
            x: 62; y: 16; width: 214; height: 104; radius: 14; color: "#2a63c4"; border.color: "#9cc4ec"; border.width: 2
            Text { x: 12; y: 8; text: v.sys?.hasPlayer ? "PLAYER" : "NO PLAYER"; font.family: P.sans; font.pixelSize: 8; color: "#bcd8f6" }
            Text { anchors.right: parent.right; anchors.rightMargin: 12; y: 8; text: v.sys?.muted ? "VOL MUTE" : "VOL " + Math.round((v.sys?.volume ?? 0) * 100); font.family: P.sans; font.pixelSize: 8; color: "#bcd8f6" }
            Row { x: 12; y: 24; spacing: 8
                  Rectangle { width: 16; height: 16; color: "#e8f2fc"; anchors.verticalCenter: parent.verticalCenter }
                  Text { text: { const p = v.sys?.position ?? 0; return Math.floor(p / 60) + ":" + String(Math.floor(p % 60)).padStart(2, "0") }
                         font.family: P.sans; font.pixelSize: 24; font.weight: Font.Light; color: "white" }
                  Rectangle { width: 100; height: 2; color: "#9cc4ec"; anchors.verticalCenter: parent.verticalCenter
                              Rectangle { height: 2; color: "white"; width: parent.width * ((v.sys?.length ?? 0) > 0 ? v.sys.position / v.sys.length : 0) } } }
            Text { x: 12; y: 76; width: parent.width - 24; elide: Text.ElideRight; text: v.sys?.hasPlayer ? (v.sys.track + "  ·  " + v.sys.artist).toUpperCase() : "NO DISC"
                   font.family: P.sans; font.pixelSize: 11; color: "#e8f2fc" }
        }
        Column { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 12
                 Repeater { model: [["+", 0.05], ["−", -0.05]]
                            Rectangle { required property var modelData; width: 30; height: 30; radius: 15; color: "#e8f2fc"; border.color: "#8ab4e0"
                                        Text { anchors.centerIn: parent; text: parent.modelData[0]; color: P.deep; font.pixelSize: 16 }
                                        MouseArea { anchors.fill: parent; onClicked: v.act("volumeStep", parent.modelData[1]) } } } }
    }
    Glass {
        x: 24; y: v.height - 196; width: 310; height: 146; title: "SKY ARC"; note: "DAYLIGHT " + v.hm(v.set - v.rise)
        Canvas {
            id: arc; x: 20; y: 4; width: parent.width - 40; height: 76
            property real f: v.dayFrac
            onFChanged: requestPaint()
            onPaint: {
                const g = getContext("2d"); g.reset();
                // a flat half-ellipse: sunrise on the left, sunset on the right
                const cx = width / 2, rx = width / 2 - 10, ry = height - 14, cy = height - 4;
                const pt = u => [cx - rx * Math.cos(Math.PI * u), cy - ry * Math.sin(Math.PI * u)];
                const path = (u0, u1) => { g.beginPath(); for (let i = 0; i <= 60; i++) { const q = pt(u0 + (u1 - u0) * i / 60); i ? g.lineTo(q[0], q[1]) : g.moveTo(q[0], q[1]) } g.stroke() };
                g.lineWidth = 1.4; g.strokeStyle = "#c8d2dc"; g.setLineDash([2, 3]); path(0, 1);
                g.setLineDash([]); g.strokeStyle = P.deep; g.lineWidth = 2; if (f > 0) path(0, f);
                g.fillStyle = P.deep; for (const u of [0, 1]) { const q = pt(u); g.beginPath(); g.arc(q[0], q[1], 3, 0, 2 * Math.PI); g.fill() }
                const s = pt(f);
                g.fillStyle = "#5da6df"; g.beginPath(); g.arc(s[0], s[1], 9, 0, 2 * Math.PI); g.fill();
                g.fillStyle = "#ffffff"; g.beginPath(); g.arc(s[0] - 3, s[1] - 3, 3, 0, 2 * Math.PI); g.fill();
            }
        }
        Text { x: 16; y: 90; text: "▲ " + (v.sys?.sunrise ?? "").slice(0, 5); font.family: P.sans; font.pixelSize: 11; color: P.ink }
        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 92; font.family: P.sans; font.pixelSize: 8; font.letterSpacing: 1.2; color: P.blue
               text: v.nowS < v.rise ? "SUNRISE IN " + v.hm(v.rise - v.nowS) : v.nowS < v.set ? "SUNSET IN " + v.hm(v.set - v.nowS) : "NIGHT" }
        Text { anchors.right: parent.right; anchors.rightMargin: 16; y: 90; text: (v.sys?.sunset ?? "").slice(0, 5) + " ▼"; font.family: P.sans; font.pixelSize: 11; color: P.ink }
    }
    Glass {
        x: v.width * 0.52; y: v.height - 176; width: 240; height: 140; title: "ATMOS"; note: (v.sys?.weatherPlace ?? "").toUpperCase()
        Text { x: 16; y: 4; text: v.sys?.night ? "󰖔" : "󰖐"; font.family: P.mono; font.pixelSize: 34; color: P.deep }
        Text { x: 70; y: -4; text: v.sys?.weatherTemp || "--"; font.family: P.sans; font.pixelSize: 36; font.weight: Font.Light; color: P.ink
               Text { anchors.left: parent.right; y: 6; text: "°C"; font.family: P.sans; font.pixelSize: 10; color: P.label } }
        Text { x: 70; y: 40; text: (v.sys?.weatherCond ?? "").toUpperCase(); font.family: P.sans; font.pixelSize: 10; font.letterSpacing: 1.4; font.weight: Font.DemiBold; color: "#4a5361" }
        Text { x: 16; y: 72; font.family: P.sans; font.pixelSize: 10; color: P.ink; lineHeight: 1.4
               text: "HUM  " + (v.sys?.weatherHumidity || "--") + "\nWIND  " + (v.sys?.weatherWind || "--") }
    }
}
