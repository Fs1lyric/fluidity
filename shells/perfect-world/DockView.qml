// amarena dock (noodle/dock.lua): 50 px squircles in the background colour, one per app class, with the
// class's icon in its colour; under each a bump (open) or a wide tab (focused).
import QtQuick
import "Pal.js" as P

Item {
    id: root
    property var items: []   // [{ cls, open, focused }]
    signal activate(string cls)
    signal closeClass(string cls)
    implicitWidth: row.width
    implicitHeight: 50 + 8 + 7

    Row {
        id: row
        Repeater {
            model: root.items
            Item {
                required property var modelData
                readonly property var ic: P.classIcon(modelData.cls)
                width: 50 + 16; height: root.implicitHeight
                Rectangle {
                    x: 8; width: 50; height: 50; radius: 17; color: P.bg
                    Text { anchors.centerIn: parent; text: parent.parent.ic.glyph; color: parent.parent.ic.color
                           font.family: P.icons; font.pixelSize: 22 }
                }
                // indicator: wide rounded tab when focused, a small half-dot when just open
                Rectangle {
                    visible: parent.modelData.focused
                    x: 8; y: 58; width: 50 - 16 + 16; height: 7; topLeftRadius: 7; topRightRadius: 7
                    color: parent.ic.color
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Item {
                    visible: parent.modelData.open && !parent.modelData.focused
                    y: 58; width: 14; height: 7; clip: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle { width: 14; height: 14; radius: 7; color: parent.parent.ic.color }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: m => m.button === Qt.MiddleButton ? root.closeClass(parent.modelData.cls) : root.activate(parent.modelData.cls)
                }
            }
        }
    }
}
