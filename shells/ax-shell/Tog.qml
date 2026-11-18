import QtQuick
import "Pal.js" as P

Rectangle {
    property string icon
    property bool on
    signal clicked()
    width: 48; height: 48; radius: 14; color: on ? P.pink : P.pill
    Text { anchors.centerIn: parent; text: parent.icon; font.family: P.mono; font.pixelSize: 20; color: parent.on ? P.bg : P.fg }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
}
