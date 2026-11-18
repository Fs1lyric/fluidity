// The menu bar: an outlined cream strip inside the screen frame. App square, "Play Edit Video Window Enjoy",
// the focused window's title in the middle, the date and time on the right.
import QtQuick
import "Pal.js" as P

Card {
    id: b
    property var sys
    signal act(string what, var arg)
    shadow: 0
    Rectangle { x: 12; anchors.verticalCenter: parent.verticalCenter; width: 18; height: 18; radius: 3; color: P.ink
                Rectangle { x: 4; y: 9; width: 10; height: 3; color: P.cream }
                MouseArea { anchors.fill: parent; onClicked: b.act("launcher", null) } }
    Row {
        x: 44; anchors.verticalCenter: parent.verticalCenter; spacing: 14
        Repeater {
            model: [["Play", "play"], ["Edit", "terminal"], ["Video", "videos"], ["Window", "launcher"], ["Enjoy", "power"]]
            Text { required property var modelData; text: modelData[0]; font.family: P.mono; font.pixelSize: 14; font.weight: Font.Medium; color: P.ink
                   MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                               onClicked: parent.modelData[1] === "videos" ? b.act("exec", ["bash", "-c", "xdg-open ~/Videos"]) : b.act(parent.modelData[1], null) } }
        }
    }
    Text { anchors.centerIn: parent; width: Math.min(implicitWidth, parent.width * 0.4); elide: Text.ElideRight
           text: b.sys?.title ?? ""; font.family: P.mono; font.pixelSize: 14; font.weight: Font.Medium; color: P.ink }
    Text { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
           text: Qt.formatDateTime(b.sys?.now ?? new Date(), "ddd MMM d    hh:mm AP"); font.family: P.mono; font.pixelSize: 14; font.weight: Font.Medium; color: P.ink }
}
