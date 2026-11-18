// The little dock at the bottom: his app icons in their own colours, no background.
import QtQuick

Row {
    id: k
    signal act(string what, var arg)
    spacing: 14
    Repeater {
        model: [["󰈹", "#ff7139", "browser"], ["󰙯", "#5865f2", ["vesktop"]], ["󰓇", "#1ed760", ["spotify"]], ["󱎒", "#2b7cd3", ["margin"]],
                ["󰕼", "#ff8800", ["mpv", "--player-operation-mode=pseudo-gui"]], ["󰅟", "#0f78d4", "files"]]
        Text {
            required property var modelData
            text: modelData[0]; color: modelData[1]; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 40
            style: Text.Outline; styleColor: "#2e230a"
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: Array.isArray(parent.modelData[2]) ? k.act("exec", parent.modelData[2]) : k.act(parent.modelData[2], null) }
        }
    }
}
