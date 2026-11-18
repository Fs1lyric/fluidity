// One sidebar meter: icon + rounded bar (track is the bar colour at 22%).
import QtQuick

Row {
    id: sb
    property string iconSource
    property real value
    property color barColor
    spacing: 16
    Image { source: sb.iconSource; width: 34; height: 34; sourceSize: Qt.size(80, 80); smooth: true; mipmap: true
            anchors.verticalCenter: parent.verticalCenter }
    Rectangle {
        width: 200; height: 18; radius: 9
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(sb.barColor.r, sb.barColor.g, sb.barColor.b, 0.22)
        Rectangle {
            width: Math.max(height, parent.width * Math.min(1, Math.max(0, sb.value))); height: parent.height
            radius: 9; color: sb.barColor
            Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        }
    }
}
