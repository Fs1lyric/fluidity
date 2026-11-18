// His polybar: a dark brown strip inset from the edges, pixel mono. Quick-launch icons on the left, the song
// (or "Play some music!") in the middle, volume and time on the right, and the tan power block.
import QtQuick

Item {
    id: b
    property var sys
    signal act(string what, var arg)
    implicitHeight: 30
    readonly property color ink: "#fce4d3"
    readonly property string px: "Monocraft"
    Rectangle {
        x: parent.width * 0.06; width: parent.width * 0.88; y: 4; height: 24; color: "#2e230a"
        Row {
            x: 16; height: parent.height; spacing: 26
            Repeater {
                model: [["󰍹", "settings"], ["󰍺", "launcher"], ["󰹑", "shot"], ["󰆍", "terminal"], ["󰉋", "files"]]
                Text { required property var modelData; anchors.verticalCenter: parent.verticalCenter; text: modelData[0]
                       font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; color: b.ink
                       MouseArea { anchors.fill: parent; onClicked: b.act(parent.modelData[1], null) } }
            }
        }
        Text { anchors.centerIn: parent; width: Math.min(implicitWidth, parent.width * 0.45); elide: Text.ElideRight
               text: b.sys?.hasPlayer ? b.sys.track + " - " + b.sys.artist : "Play some music!"; font.family: b.px; font.pixelSize: 12; color: b.ink
               MouseArea { anchors.fill: parent; onClicked: b.act("play", null) } }
        Row {
            anchors.right: power.left; anchors.rightMargin: 24; height: parent.height; spacing: 24
            Text { anchors.verticalCenter: parent.verticalCenter; text: (b.sys?.muted ? "󰖁 " : "󰕾 ") + Math.round((b.sys?.volume ?? 0) * 100) + "%"
                   font.family: b.px; font.pixelSize: 12; color: b.ink
                   MouseArea { anchors.fill: parent; onClicked: b.act("mute", null); onWheel: w => b.act("volumeStep", w.angleDelta.y > 0 ? 0.05 : -0.05) } }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "󰥔 " + Qt.formatDateTime(b.sys?.now ?? new Date(), "hh:mm AP"); font.family: b.px; font.pixelSize: 12; color: b.ink }
        }
        Rectangle { id: power; anchors.right: parent.right; width: 50; height: parent.height; color: "#ad8d6c"
                    Text { anchors.centerIn: parent; text: "⏻"; color: "#fce4d3"; font.pixelSize: 13 }
                    MouseArea { anchors.fill: parent; onClicked: b.act("power", null) } }
    }
}
