// amarena exit screen (elemental/exit_screen/ephemeral.lua): five 120 px rounded squares in color0 with a
// glyph; hovering paints the glyph and an 8 px border in the button's colour. Keys p r s e l, Esc/q/x closes.
import QtQuick
import "Pal.js" as P

Rectangle {
    id: root
    signal chosen(string action)
    signal closed()
    implicitWidth: 1920; implicitHeight: 1080
    color: "#cc242d35"
    focus: true
    Keys.onPressed: e => {
        const k = e.text.toLowerCase(), map = { p: "poweroff", r: "reboot", s: "suspend", e: "exit", l: "lock" };
        if (map[k]) { root.chosen(map[k]); e.accepted = true }
        else if (e.key === Qt.Key_Escape || k === "q" || k === "x") { root.closed(); e.accepted = true }
    }
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons; onClicked: root.closed() }

    Row {
        anchors.centerIn: parent
        spacing: 50
        Repeater {
            model: [["poweroff", "power", P.c1], ["reboot", "reboot", P.c2], ["suspend", "sleep", P.c3],
                    ["exit", "logout", P.c4], ["lock", "lock", P.c5]]
            Rectangle {
                required property var modelData
                width: 120; height: 120; radius: 20; color: P.c0
                border.width: 8; border.color: ma.containsMouse ? modelData[2] : P.c0
                Text { anchors.centerIn: parent; text: P.g(P.glyph[parent.modelData[1]])
                       color: ma.containsMouse ? parent.modelData[2] : P.fg; font.family: P.icons; font.pointSize: 40 }
                MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root.chosen(parent.modelData[0]) }
            }
        }
    }
}
