// The TERMINAL / MAIN SHELL frame around the area where windows live (drawn on the background layer).
import QtQuick
import "Pal.js" as P

Item {
    id: f
    property string host: "batcore"
    Rectangle { anchors.fill: parent; anchors.topMargin: 22; color: P.lightBlack; border.color: P.a(0.6); border.width: 1 }
    Hdr { width: parent.width; leftText: "TERMINAL"; rightText: "MAIN SHELL" }
}
