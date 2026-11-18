// Ax-Shell's bar: three groups of floating pills, nothing in between (the wallpaper shows through).
import QtQuick
import "Pal.js" as P

Item {
    id: b
    property var sys
    signal act(string what, var arg)
    signal notch()
    implicitHeight: 40
    Row {
        x: 6; y: 4; spacing: 6
        Btn { icon: "󰣇"; onClicked: b.act("launcher", null) }
        Rectangle {
            width: wsRow.width + 20; height: 32; radius: 16; color: P.bg
            Row {
                id: wsRow; anchors.centerIn: parent; spacing: 7
                Repeater {
                    model: (b.sys?.tags ?? []).slice(0, 10)
                    Rectangle {
                        required property var modelData
                        readonly property bool on: modelData.state === "focused"
                        anchors.verticalCenter: parent.verticalCenter
                        width: on ? 34 : 8; height: 8; radius: 4
                        color: on ? P.pink : modelData.count > 0 ? P.fg : P.line
                        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        MouseArea { anchors.fill: parent; anchors.margins: -5; onClicked: b.act("ws", parent.modelData.id) }
                    }
                }
            }
            WheelHandler { onWheel: e => b.act("wsStep", e.angleDelta.y > 0 ? -1 : 1) }
        }
    }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter; y: 4; spacing: 6
        Btn { icon: "󰄀"; onClicked: b.act("shot", null) }
        Rectangle {
            width: Math.max(220, nt.implicitWidth + 40); height: 32; radius: 16; color: P.bg
            Text { id: nt; anchors.centerIn: parent; width: Math.min(implicitWidth, 420); elide: Text.ElideRight
                   text: (b.sys?.title ?? "") !== "" ? b.sys.title : (b.sys?.user ?? "") + "@" + (b.sys?.host ?? "")
                   color: P.fg; font.family: P.mono; font.pixelSize: 13 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.notch() }
        }
        Btn { icon: "󰏫"; onClicked: b.act("terminal", null) }
    }
    Row {
        anchors.right: parent.right; anchors.rightMargin: 6; y: 4; spacing: 6
        Btn { icon: b.sys?.muted ? "󰖁" : "󰕾"; onClicked: b.act("mute", null) }
        Rectangle {
            width: clk.implicitWidth + 22; height: 32; radius: 16; color: P.bg
            Text { id: clk; anchors.centerIn: parent; text: Qt.formatDateTime(b.sys?.now ?? new Date(), "HH:mm")
                   color: P.fg; font.family: P.mono; font.pixelSize: 13 }
            MouseArea { anchors.fill: parent; onClicked: b.notch() }
        }
        Btn { icon: "⏻"; onClicked: b.act("power", null) }
    }
}
