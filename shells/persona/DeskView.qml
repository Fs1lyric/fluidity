// The desktop: "DD MM" in huge translucent serif numerals and the P3R clock card in the top right.
import QtQuick

Item {
    id: v
    property var sys
    property bool depth: false     // the Persona wallpaper is up: put its foreground (train + party) back over the date
    readonly property date now: sys?.now ?? new Date()
    readonly property int h: now.getHours()
    readonly property string daytime: h < 5 ? "Dark Hour" : h < 8 ? "Early Morning" : h < 12 ? "Morning" : h < 13 ? "Noon"
                                      : h < 17 ? "Afternoon" : h < 19 ? "After School" : h < 23 ? "Evening" : "Late Night"
    // moon phase 0..1 (0 new, 0.5 full) from a known new moon
    readonly property real moon: (((now - new Date(2000, 0, 6, 18, 14)) / 86400000) % 29.530588) / 29.530588
    Row {
        x: v.width * 0.28; y: v.height * 0.005; spacing: v.width * 0.075
        Repeater {
            model: [Qt.formatDateTime(v.now, "dd"), Qt.formatDateTime(v.now, "MM")]
            Text { required property string modelData; text: modelData; font.family: "DM Serif Display"; font.pixelSize: v.height * 0.27
                   color: "#2a5f8f"; opacity: 0.6; font.letterSpacing: -v.height * 0.006 }
        }
    }
    Image { anchors.fill: parent; visible: v.depth; source: "fg.png"; fillMode: Image.PreserveAspectCrop; smooth: true; asynchronous: true }
    // P3R clock card: a slanted dark-blue slab with a wave of light blue at the bottom
    Item {
        id: card
        anchors { right: parent.right; top: parent.top; rightMargin: v.width * 0.02; topMargin: v.height * 0.04 }
        width: v.width * 0.26; height: v.width * 0.075
        Rectangle { anchors.fill: parent; color: "#0c1a3c"; opacity: 0.88; transform: Matrix4x4 { matrix: Qt.matrix4x4(1, -0.12, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1) }
                    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: parent.height * 0.22; color: "#1788b6" } }
        Text { id: time; x: card.width * 0.05; anchors.verticalCenter: parent.verticalCenter; anchors.verticalCenterOffset: -card.height * 0.05
               text: Qt.formatDateTime(v.now, "HH:mm"); font.family: "Anton"; font.pixelSize: card.height * 0.78; color: "white"; font.letterSpacing: -2 }
        Column {
            anchors { left: time.right; leftMargin: card.width * 0.04; verticalCenter: parent.verticalCenter; verticalCenterOffset: -card.height * 0.05 }
            spacing: 0
            Text { text: Qt.formatDateTime(v.now, "ddd").toUpperCase(); font.family: "Anton"; font.pixelSize: card.height * 0.3; color: "white" }
            Text { text: v.daytime; font.family: "Anton"; font.pixelSize: card.height * 0.22; color: "#00dbff" }
            Text { text: "󰁹 " + Math.round((v.sys?.battery ?? 1) * 100) + "%"; font.family: "JetBrainsMono Nerd Font"; font.bold: true; font.pixelSize: card.height * 0.18; color: "#fffb9f" }
        }
        // moon: a yellow disc with the dark part on the waning / waxing side
        Rectangle {
            anchors { right: parent.right; rightMargin: card.width * 0.05; verticalCenter: parent.verticalCenter }
            width: card.height * 0.5; height: width; radius: width / 2; color: "#302c24"; clip: true
            Rectangle { width: parent.width; height: parent.height; radius: width / 2; color: "#ffe700"
                        x: (v.moon < 0.5 ? 1 - v.moon * 2 : -(v.moon - 0.5) * 2) * parent.width }
        }
    }
}
