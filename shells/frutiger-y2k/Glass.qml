// A frosted Y2K glass card: white, hairline rim, soft drop, a small spaced-caps title and a right-hand note.
import QtQuick
import "Pal.js" as P

Item {
    id: g
    default property alias content: body.data
    property string title: ""
    property string note: ""
    Rectangle { x: 0; y: 3; width: g.width; height: g.height; radius: 14; color: "#14000000" }
    Rectangle { anchors.fill: parent; radius: 14; color: P.glass; border.color: P.rim; border.width: 1
                Rectangle { x: 1; y: 1; width: parent.width - 2; height: parent.height * 0.45; radius: 13; opacity: 0.6
                            gradient: Gradient { GradientStop { position: 0; color: "#ffffff" } GradientStop { position: 1; color: "#00ffffff" } } } }
    Text { x: 14; y: 11; visible: g.title !== ""; text: g.title; font.family: P.sans; font.pixelSize: 10; font.letterSpacing: 1.6; color: P.label }
    Text { anchors.right: parent.right; anchors.rightMargin: 14; y: 11; text: g.note; font.family: P.sans; font.pixelSize: 9; font.letterSpacing: 1.2; color: P.label }
    Item { id: body; anchors.fill: parent; anchors.topMargin: g.title !== "" ? 30 : 0 }
}
