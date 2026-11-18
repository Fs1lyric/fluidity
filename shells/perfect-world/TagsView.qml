// amarena top taglist: a 10 px strip of ten colour blocks across the top. Focused = full colour,
// occupied = the colour at 27 %, empty = nothing, urgent = white.  Original: elemental/bar/amarena.lua
import QtQuick
import "Pal.js" as P

Item {
    id: root
    property var tags: []    // [{ id, state }]
    signal clicked(int id)
    readonly property var colors: [P.c1, P.c5, P.c4, P.c6, P.c2, P.c3, P.c1, P.c5, P.c4, P.c6]
    implicitHeight: 10

    Row {
        anchors.fill: parent
        spacing: 10
        Repeater {
            model: root.tags
            Rectangle {
                required property var modelData
                required property int index
                width: (root.width - 10 * (root.tags.length - 1)) / Math.max(1, root.tags.length)
                height: root.height
                readonly property color c: root.colors[index % 10]
                color: modelData.state === "focused" ? c : modelData.state === "urgent" ? P.fg
                     : modelData.state === "occupied" ? Qt.rgba(c.r, c.g, c.b, 0.27) : "transparent"
                MouseArea { anchors.fill: parent; onClicked: root.clicked(parent.modelData.id) }
            }
        }
    }
}
