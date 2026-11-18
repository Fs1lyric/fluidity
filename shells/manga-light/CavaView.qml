// The cava card (bottom right): solid black bars on cream, like his terminal running cava.
import QtQuick

Rectangle {
    id: v
    property var levels: []
    implicitWidth: 476; implicitHeight: 146
    radius: 8; color: "#fbf1c7"; border.color: "#d5c4a1"; border.width: 1
    Row {
        anchors.bottom: parent.bottom; anchors.bottomMargin: 10; anchors.horizontalCenter: parent.horizontalCenter; spacing: 5
        Repeater { model: v.levels.length
                   Rectangle { required property int index; width: 14; color: "#282828"; anchors.bottom: parent.bottom
                               height: Math.max(2, (v.levels[index] ?? 0) * (v.height - 30)) } }
    }
}
