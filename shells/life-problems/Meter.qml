import QtQuick
import "Pal.js" as P

Row {
    id: m
    property string label
    property real value
    property color fill
    spacing: 14
    Text { width: 40; text: m.label; font.family: P.mono; font.pixelSize: 15; color: P.ink; anchors.verticalCenter: parent.verticalCenter }
    Rectangle { width: 150; height: 16; radius: 8; color: P.cream; border.color: P.ink; border.width: 3
                Rectangle { x: 3; y: 3; height: 10; radius: 5; color: m.fill; width: Math.max(8, (parent.width - 6) * Math.max(0, Math.min(1, m.value))) } }
}
