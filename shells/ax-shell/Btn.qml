import QtQuick
import "Pal.js" as P

Rectangle {
    property string icon
    signal clicked()
    width: 32; height: 32; radius: 16; color: P.bg
    Text { anchors.centerIn: parent; text: parent.icon; color: P.fg; font.family: P.mono; font.pixelSize: 16 }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
}
