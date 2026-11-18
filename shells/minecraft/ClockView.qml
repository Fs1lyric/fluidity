// The date line in the bottom-left corner, in the Minecraft font on a dark see-through strip (like F3 text).
import QtQuick

Rectangle {
    id: c
    property date now: new Date()
    implicitWidth: t.implicitWidth + 12; implicitHeight: t.implicitHeight + 4
    color: "#90000000"
    Text { id: t; anchors.centerIn: parent; text: Qt.formatDateTime(c.now, "ddd MMM d hh:mm:ss AP t yyyy")
           font.family: "Monocraft"; font.pixelSize: 20; color: "#e0e0e0" }
}
