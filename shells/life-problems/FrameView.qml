// The screen frame: cream margin round the edge and a 3 px rounded ink outline, drawn above the windows
// (click-through). Hyprland's outer gap keeps every window inside it.
import QtQuick
import "Pal.js" as P

Item {
    id: f
    readonly property int inset: 30
    // cream ring whose inner edge is the frame's rounded inside (inset - 3, radius 22)
    Rectangle { anchors.fill: parent; anchors.margins: -40; radius: 22 + f.inset + 37; color: "transparent"; border.color: P.cream; border.width: f.inset + 37 }
    Rectangle { anchors.fill: parent; anchors.margins: f.inset - 3; radius: 22; color: "transparent"; border.color: P.ink; border.width: 3 }
}
