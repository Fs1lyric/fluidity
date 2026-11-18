// The big clock on the desktop (top right in the post): tty-clock block digits on a dark rounded card, the
// date under it as "yyyy-MM-dd [AM]". Sits on the background layer, so windows cover it.
import QtQuick

Rectangle {
    id: c
    property date now: new Date()
    implicitWidth: digits.implicitWidth + 64; implicitHeight: digits.implicitHeight + 76
    radius: 10; color: "#e60b1117"
    BlockDigits { id: digits; x: 32; y: 30; cell: 13; color: "#8ea4a2"
                  text: Qt.formatDateTime(c.now, "hh:mm:") + " " + Qt.formatDateTime(c.now, "ss") }
    Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 14
           text: Qt.formatDateTime(c.now, "yyyy-MM-dd") + " [" + Qt.formatDateTime(c.now, "AP") + "]"
           font.family: "JetBrains Mono"; font.bold: true; font.pixelSize: 13; color: "#87a987" }
}
