// Neo-brutalist card: flat fill, thick black outline, a hard black shadow offset down-right, no blur.
import QtQuick

Item {
    id: c
    property color fill: "#efe3d8"
    property int r: 10
    property int line: 3
    property int drop: 5
    property bool pressed: false
    Rectangle { x: c.pressed ? 1 : c.drop; y: c.pressed ? 1 : c.drop; width: c.width; height: c.height; radius: c.r; color: "#1a1414" }
    Rectangle {
        id: body
        x: c.pressed ? c.drop - 1 : 0; y: x
        width: c.width; height: c.height; radius: c.r
        color: c.fill; border.color: "#1a1414"; border.width: c.line
    }
}
