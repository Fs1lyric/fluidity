// The Plasma desktop right-click menu in his see-through glass (Create New, Paste, Icons, Edit Mode,
// Desktop and Wallpaper, Display Configuration).
import QtQuick

Rectangle {
    id: m
    signal pick(string what)
    implicitWidth: 210; implicitHeight: col.implicitHeight + 12
    radius: 10
    color: Qt.rgba(0.80, 0.90, 1.0, 0.22)
    border.color: Qt.rgba(1, 1, 1, 0.35); border.width: 1
    readonly property var items: [
        [0xf0224, "Create New Folder", "", "new", false], [0xf014c, "Paste Clipboard Contents...", "Ctrl+V", "paste", false],
        [0xf054d, "Undo", "", "", false], [0xf0570, "Icons", "", "", true], [0xf03eb, "Enter Edit Mode", "", "", false],
        [0xf0e09, "Desktop and Wallpaper", "Ctrl+Shift+D", "wallpaper", false], [0xf0379, "Display Configuration", "", "display", false]]
    Column {
        id: col
        x: 6; y: 6; width: parent.width - 12
        Repeater {
            model: m.items
            Rectangle {
                required property var modelData
                width: col.width; height: 22; radius: 5
                color: hov.containsMouse && modelData[3] ? Qt.rgba(1, 1, 1, 0.18) : "transparent"
                opacity: modelData[3] ? 1 : 0.45
                Text { x: 8; anchors.verticalCenter: parent.verticalCenter; text: String.fromCodePoint(parent.modelData[0]); color: "#ffffff"
                       font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
                Text { x: 30; anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[1]; color: "#ffffff"; font.family: "Inter"; font.pixelSize: 11 }
                Text { anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                       text: parent.modelData[4] ? "›" : parent.modelData[2]; color: Qt.rgba(1, 1, 1, 0.6); font.family: "Inter"; font.pixelSize: parent.modelData[4] ? 14 : 10 }
                MouseArea { id: hov; anchors.fill: parent; hoverEnabled: true; enabled: parent.modelData[3] !== ""; onClicked: m.pick(parent.modelData[3]) }
            }
        }
    }
}
