// The Material You desktop clock: a scalloped "cookie" dial with minute ticks, hour + minute hands,
// the time in big lavender digits, a day badge (top left) and a month badge (bottom right).
import QtQuick

Item {
    id: c
    property date now: new Date()
    implicitWidth: 260; implicitHeight: 260
    readonly property color accent: "#e3b5f5"
    readonly property color dial: Qt.rgba(0.12, 0.08, 0.13, 0.86)

    Canvas {
        id: cookie
        anchors.fill: parent
        property real minute: c.now.getMinutes()
        property real hour: c.now.getHours() % 12 + c.now.getMinutes() / 60
        onMinuteChanged: requestPaint()
        onPaint: {
            const g = getContext("2d"), cx = width / 2, cy = height / 2, R = width * 0.40;
            g.reset();
            g.beginPath();
            for (let a = 0; a <= Math.PI * 2 + 0.01; a += 0.02) {
                const r = R + Math.cos(a * 12) * R * 0.035, x = cx + Math.cos(a) * r, y = cy + Math.sin(a) * r;
                a === 0 ? g.moveTo(x, y) : g.lineTo(x, y);
            }
            g.closePath(); g.fillStyle = c.dial; g.fill();
            g.strokeStyle = "rgba(236,224,242,0.55)";
            for (let i = 0; i < 60; i++) {
                const a = i / 60 * Math.PI * 2, r1 = R * 0.86, r2 = R * (i % 5 === 0 ? 0.76 : 0.81);
                g.lineWidth = i % 5 === 0 ? 2 : 1;
                g.beginPath(); g.moveTo(cx + Math.cos(a) * r1, cy + Math.sin(a) * r1); g.lineTo(cx + Math.cos(a) * r2, cy + Math.sin(a) * r2); g.stroke();
            }
            g.lineCap = "round";
            const ha = hour / 12 * Math.PI * 2 - Math.PI / 2, ma = minute / 60 * Math.PI * 2 - Math.PI / 2;
            g.strokeStyle = "#f2c2c8"; g.lineWidth = 9;
            g.beginPath(); g.moveTo(cx, cy); g.lineTo(cx + Math.cos(ha) * R * 0.45, cy + Math.sin(ha) * R * 0.45); g.stroke();
            g.strokeStyle = "#ece0f2"; g.lineWidth = 7;
            g.beginPath(); g.moveTo(cx, cy); g.lineTo(cx + Math.cos(ma) * R * 0.62, cy + Math.sin(ma) * R * 0.62); g.stroke();
        }
    }
    Column {
        anchors { horizontalCenter: parent.horizontalCenter; horizontalCenterOffset: 22; verticalCenter: parent.verticalCenter }
        spacing: -14
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: String(c.now.getHours() % 12 || 12).padStart(2, "0"); color: c.accent; font.family: "Inter"; font.pixelSize: 64; font.weight: Font.Medium }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatTime(c.now, "mm"); color: c.accent; font.family: "Inter"; font.pixelSize: 64; font.weight: Font.Medium }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: c.now.getHours() < 12 ? "AM" : "PM"; color: c.accent; font.family: "Inter"; font.pixelSize: 16; topPadding: 12 }
    }
    // day badge: a soft pentagon
    Canvas {
        x: 12; y: 18; width: 56; height: 56
        onPaint: { const g = getContext("2d"); g.reset(); g.fillStyle = "#4a3236"; g.beginPath();
            for (let i = 0; i < 5; i++) { const a = -Math.PI / 2 + i * Math.PI * 2 / 5; g.lineTo(28 + Math.cos(a) * 27, 30 + Math.sin(a) * 27) }
            g.closePath(); g.fill() }
        Text { anchors.centerIn: parent; anchors.verticalCenterOffset: 2; text: c.now.getDate(); color: "#ffffff"; font.family: "Inter"; font.pixelSize: 20; font.weight: Font.Bold }
    }
    // month badge: a little cookie
    Canvas {
        x: parent.width - 66; y: parent.height - 92; width: 50; height: 50
        onPaint: { const g = getContext("2d"); g.reset(); g.fillStyle = "#5a5560"; g.beginPath();
            for (let a = 0; a <= Math.PI * 2 + 0.01; a += 0.05) { const r = 22 + Math.cos(a * 8) * 2; g.lineTo(25 + Math.cos(a) * r, 25 + Math.sin(a) * r) }
            g.closePath(); g.fill() }
        Text { anchors.centerIn: parent; text: c.now.getMonth() + 1; color: "#ffffff"; font.family: "Inter"; font.pixelSize: 18; font.weight: Font.Bold }
    }
}
