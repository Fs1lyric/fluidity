// The bar that repaints itself from each wallpaper (pywal's job in the post): workspaces, the focused window,
// media, status and the clock, in the picture's own darkest, lightest and two most vivid colours.
import QtQuick

Rectangle {
    id: b
    property var sys
    property var pal: ["#0f1012", "#e6e6e6", "#e0c080", "#7aa2d8"]   // bg fg accent accent2
    signal act(string what, var arg)
    implicitHeight: 30
    color: Qt.rgba(Qt.color(pal[0]).r, Qt.color(pal[0]).g, Qt.color(pal[0]).b, 0.82)
    Behavior on color { ColorAnimation { duration: 900 } }
    readonly property color fg: pal[1]
    readonly property color acc: pal[2]
    readonly property color acc2: pal[3]
    readonly property string font: "JetBrainsMono Nerd Font"
    function g(cp) { return String.fromCodePoint(cp) }
    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 2; color: b.acc; Behavior on color { ColorAnimation { duration: 900 } } }

    component T: Text { color: b.fg; font.family: b.font; font.pixelSize: 12; anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                        Behavior on color { ColorAnimation { duration: 900 } } }

    Row {
        x: 10; height: parent.height; spacing: 6
        Repeater {
            model: (b.sys?.tags ?? []).filter(t => t.id <= 5 || t.state !== "empty")
            Rectangle {
                required property var modelData
                anchors.verticalCenter: parent.verticalCenter
                width: 20; height: 18
                color: modelData.state === "focused" ? b.acc : "transparent"
                border.color: modelData.state === "empty" ? Qt.rgba(1, 1, 1, 0.15) : b.acc2; border.width: 1
                Behavior on color { ColorAnimation { duration: 900 } }
                Text { anchors.centerIn: parent; text: parent.modelData.id; font.family: b.font; font.pixelSize: 11
                       color: parent.modelData.state === "focused" ? b.pal[0] : b.fg }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.act("ws", parent.modelData.id) }
            }
        }
        T { text: "  " + (b.sys?.title ?? ""); width: Math.min(implicitWidth, 420); elide: Text.ElideRight; color: Qt.rgba(1, 1, 1, 0.7) }
    }

    Row {
        anchors.centerIn: parent; spacing: 8; visible: b.sys?.hasPlayer ?? false
        T { text: b.g(b.sys?.playing ? 0xf03e4 : 0xf040a); color: b.acc
            MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: b.act("play", null) } }
        T { text: [b.sys?.track, b.sys?.artist].filter(x => x).join(" · "); width: Math.min(implicitWidth, 360); elide: Text.ElideRight }
    }

    Row {
        anchors { right: parent.right; rightMargin: 10 } height: parent.height; spacing: 14
        T { text: b.g(0xf0e09); color: b.acc2
            MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: b.act("nextWall", null) } }
        T { text: b.g(b.sys?.muted ? 0xf075f : 0xf057e) + " " + Math.round((b.sys?.volume ?? 0) * 100) + "%"
            MouseArea { anchors.fill: parent; onClicked: b.act("mute", null); onWheel: w => b.act("volumeStep", w.angleDelta.y > 0 ? 0.05 : -0.05) } }
        T { text: b.g(b.sys?.online ? 0xf0928 : 0xf092e) }
        T { visible: b.sys?.hasBattery ?? false; text: b.g(0xf0079) + " " + Math.round((b.sys?.battery ?? 1) * 100) + "%" }
        T { text: Qt.formatDateTime(b.sys?.now ?? new Date(), "ddd dd  HH:mm"); color: b.acc; font.weight: Font.Bold }
        T { text: b.g(0xf0425); MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: b.act("power", null) } }
    }
}
