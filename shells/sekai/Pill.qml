// One outlined pill of the Sekai bar. Children go in the row.
import QtQuick
import "Pal.js" as P

Rectangle {
    id: p
    default property alias content: row.data
    property color fill: P.pill
    signal clicked()
    implicitWidth: row.implicitWidth + 20; implicitHeight: 26
    radius: height / 2; color: fill; border.color: P.ink; border.width: 2
    MouseArea { anchors.fill: parent; onClicked: p.clicked() }
    Row { id: row; anchors.centerIn: parent; spacing: 8 }
}
