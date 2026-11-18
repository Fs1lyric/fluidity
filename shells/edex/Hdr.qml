// An eDEX module header: a thin line with bright end ticks, small left and right captions under it.
import QtQuick
import "Pal.js" as P

Item {
    id: h
    property string leftText: ""
    property string rightText: ""
    property int size: 11
    implicitHeight: 18
    // the eDEX fonts ship next to the shell; loading them here makes them available to every view
    FontLoader { source: "united_sans_medium.ttf" }
    FontLoader { source: "united_sans_light.otf" }
    FontLoader { source: "fira_mono.ttf" }
    Rectangle { width: parent.width; height: 1; color: P.a(0.3) }
    Rectangle { width: 6; height: 2; color: P.c }
    Rectangle { anchors.right: parent.right; width: 6; height: 2; color: P.c }
    Text { y: 4; text: h.leftText; color: P.c; font.family: P.main; font.pixelSize: h.size; font.letterSpacing: 0.6 }
    Text { y: 4; anchors.right: parent.right; text: h.rightText; color: P.c; font.family: P.main; font.pixelSize: h.size; font.letterSpacing: 0.6 }
}
