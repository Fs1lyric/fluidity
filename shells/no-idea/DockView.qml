// Axarva's tint2 launcher at the bottom: a #121212 bar of candy-icons app icons (24 px).
import QtQuick
import "Pal.js" as P

Rectangle {
    id: root
    property string iconDir: "file:///usr/share/icons/candy-icons/apps/scalable/"
    property var apps: []   // [{ icon, cmd }]
    signal launch(var cmd)
    implicitWidth: row.width + 24; implicitHeight: 34
    radius: 8; color: P.bg
    Row {
        id: row; anchors.centerIn: parent; spacing: 15
        Repeater { model: root.apps
            Image { required property var modelData; width: 24; height: 24; sourceSize: Qt.size(48, 48)
                    source: root.iconDir + modelData.icon + ".svg"
                    scale: ma.containsMouse ? 1.15 : 1; Behavior on scale { NumberAnimation { duration: 100 } }
                    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.launch(parent.modelData.cmd) } } }
    }
}
