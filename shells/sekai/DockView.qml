// The bottom dock: dark teal slab, white-rimmed round app buttons, a divider, and the now-playing card.
import QtQuick
import "Pal.js" as P

Rectangle {
    id: k
    property var sys
    signal act(string what, var arg)
    implicitWidth: apps.implicitWidth + media.width + 44; implicitHeight: 54
    radius: 14; color: P.ink; border.color: P.light; border.width: 2
    Row {
        id: apps; x: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 8
        Repeater {
            model: [["󰍉", "launcher"], ["󰆍", "terminal"], ["󰉋", "files"], ["󰈹", "browser"], ["󰃭", ["calendio"]], ["󰙯", ["vesktop"]], ["󰓇", ["spotify"]], ["󰒓", "settings"]]
            Rectangle {
                required property var modelData
                width: 32; height: 32; radius: 16; color: "#1d5663"; border.color: P.paper; border.width: 2
                Text { anchors.centerIn: parent; text: parent.modelData[0]; font.family: P.icon; font.pixelSize: 15; color: P.paper }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: Array.isArray(parent.modelData[1]) ? k.act("exec", parent.modelData[1]) : k.act(parent.modelData[1], null) }
            }
        }
    }
    Rectangle {
        id: media
        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
        width: 250; height: 40; radius: 10; color: P.mid; border.color: P.paper; border.width: 2
        Column { x: 12; anchors.verticalCenter: parent.verticalCenter; width: 140
                 Text { width: parent.width; elide: Text.ElideRight; text: k.sys?.hasPlayer ? k.sys.track : "No music"; font.family: P.round; font.pixelSize: 12; font.weight: Font.Black; color: P.paper }
                 Text { width: parent.width; elide: Text.ElideRight; text: k.sys?.artist ?? ""; font.family: P.round; font.pixelSize: 10; color: P.paper } }
        Row { anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter } spacing: 8
              Repeater { model: [["󰒮", "prev"], [k.sys?.playing ? "󰏤" : "󰐊", "play"], ["󰒭", "next"]]
                         Rectangle { required property var modelData; width: 24; height: 24; radius: 12; color: modelData[1] === "play" ? P.light : "transparent"
                                     Text { anchors.centerIn: parent; text: parent.modelData[0]; font.family: P.icon; font.pixelSize: 14; color: P.ink }
                                     MouseArea { anchors.fill: parent; onClicked: k.act(parent.modelData[1], null) } } } }
    }
}
