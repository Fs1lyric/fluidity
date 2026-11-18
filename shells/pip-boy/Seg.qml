// One bracketed segment of the Pip-Boy rows: text between thin green rules with ticks at both ends.
import QtQuick
import "Pal.js" as P

Item {
    id: s
    property string text
    property bool bold
    property bool up: true
    signal clicked()
    implicitWidth: t.implicitWidth + 24; implicitHeight: parent ? parent.height : 28
    Rectangle { width: 2; height: 9; color: P.hi; y: s.up ? 0 : s.height - 9 }
    Rectangle { x: s.width - 2; width: 2; height: 9; color: P.hi; y: s.up ? 0 : s.height - 9 }
    Text { id: t; anchors.centerIn: parent; text: s.text; color: P.hi; font.family: "Share Tech Mono"
           font.pixelSize: s.bold ? 16 : 14; font.bold: s.bold; font.letterSpacing: 0.5 }
    MouseArea { anchors.fill: parent; onClicked: s.clicked() }
}
