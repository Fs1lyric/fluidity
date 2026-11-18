// A small brutalist button: coloured fill, black outline, 2 px hard shadow; sinks when pressed.
import QtQuick
import "Pal.js" as P

Item {
    id: b
    property color fill: P.paper2
    property string glyph: ""
    property string label: ""
    property int size: 26
    property bool round: false
    signal clicked()
    width: label ? txt.implicitWidth + (glyph ? 30 : 18) : size; height: size
    Rectangle { x: ma.pressed ? 0 : 2; y: x; width: b.width; height: b.height; radius: b.round ? b.height / 2 : 6; color: P.ink }
    Rectangle {
        x: ma.pressed ? 2 : 0; y: x; width: b.width; height: b.height; radius: b.round ? b.height / 2 : 6
        color: b.fill; border.color: P.ink; border.width: 2
        Row { anchors.centerIn: parent; spacing: 5
            Text { visible: b.glyph !== ""; text: b.glyph; color: P.ink; font.family: P.mono; font.pixelSize: b.size * 0.48; anchors.verticalCenter: parent.verticalCenter }
            Text { id: txt; visible: b.label !== ""; text: b.label; color: P.ink; font.family: P.mono; font.pixelSize: 11; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter } }
    }
    MouseArea { id: ma; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.clicked() }
}
