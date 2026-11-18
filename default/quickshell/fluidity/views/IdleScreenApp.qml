import QtQuick

// The idle screen: before the lock, the island fills the screen with a slow clock. Any key brings you back.
AppBase {
    id: a
    Column {
        anchors.centerIn: parent; spacing: 6
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Text { text: a.d.hours || ""; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 260 }
            Text { text: ":"; color: a.pal.accent; font.family: a.serif; font.italic: true; font.pixelSize: 260
                SequentialAnimation on opacity { running: a.animate; loops: Animation.Infinite; NumberAnimation { to: 0.2; duration: 1400; easing.type: Easing.InOutSine } NumberAnimation { to: 1; duration: 1400; easing.type: Easing.InOutSine } } }
            Text { text: a.d.minutes || ""; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 260 }
        }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: a.d.date || ""; color: a.alpha(a.pal.fg, 0.8); font.family: a.serif; font.pixelSize: 30 }
        Item { width: 1; height: 30 }
        Text { anchors.horizontalCenter: parent.horizontalCenter; visible: !!a.d.song; text: "󰝚  " + (a.d.song || ""); color: a.pal.dim; font.family: a.sans; font.pixelSize: 15 }
        Text { anchors.horizontalCenter: parent.horizontalCenter; visible: !!a.d.next; text: a.d.next || ""; color: a.pal.accent; font.family: a.sans; font.pixelSize: 15 }
    }
    Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 30; text: "any key"; color: a.alpha(a.pal.dim, 0.6); font.family: a.mono; font.pixelSize: 12 }
}
