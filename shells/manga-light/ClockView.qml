// The clock card (top right in the post): tty-clock block digits in olive on a cream card with a soft
// shadow, the date "yyyy-MM-dd" bottom-left in the same olive.
import QtQuick

Rectangle {
    id: c
    property date now: new Date()
    implicitWidth: 350; implicitHeight: 130
    radius: 8; color: "#fbf1c7"; border.color: "#d5c4a1"; border.width: 1
    BlockDigits { anchors.horizontalCenter: parent.horizontalCenter; y: 26; cell: 12; color: "#79740e"
                  text: Qt.formatDateTime(c.now, "hh:") + " " + Qt.formatDateTime(c.now, "mm") }
    Text { x: 86; anchors.bottom: parent.bottom; anchors.bottomMargin: 6; text: Qt.formatDateTime(c.now, "yyyy-MM-dd")
           font.family: "JetBrains Mono"; font.pixelSize: 12; color: "#79740e" }
}
