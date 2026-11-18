// The SDDM astronaut "post-apocalyptic hacker" clock (Themes/post-apocalyptic_hacker.conf): "HH:mm" in
// Fragile Bombers Attack over "dddd d", both in the dusty tan #685841 lifted a little for the desktop.
import QtQuick

Column {
    id: c
    property date now: new Date()
    spacing: 6
    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(c.now, "HH:mm"); font.family: "Fragile Bombers Attack"; font.pixelSize: 170; color: "#8f7d5c" }
    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(c.now, "dddd d"); font.family: "Fragile Bombers Attack"; font.pixelSize: 40; color: "#8f7d5c" }
}
