// Axarva's tint2 pills along the top: workspaces on the left; launch buttons, status icons and the clock on the right.
import QtQuick
import "Pal.js" as P

Item {
    id: root
    property var tags: []   // [{ id, state }] for workspaces 1..9
    property string time: "21:06"
    property string wifi: ""
    property bool caffeine: false
    property string batteryGlyph: ""
    signal clicked(int id)
    signal launch(string what)
    implicitHeight: 44

    Pill { x: 8; width: wsRow.width + 24
        Row { id: wsRow; anchors.centerIn: parent; spacing: 14
            Repeater { model: root.tags
                Text { required property var modelData; required property int index
                    text: P.v2(P.workspaces[index]); font.family: P.icons; font.pixelSize: 12
                    color: modelData.state === "focused" ? P.red : modelData.state === "urgent" ? P.purple
                         : modelData.state === "occupied" ? P.fg : "#8a7a77"
                    MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor; onClicked: root.clicked(parent.modelData.id) } } } } }

    Row {
        anchors { right: parent.right; rightMargin: 8 }
        y: 8; spacing: 8
        Pill { y: 0; width: btns.width + 26
            Row { id: btns; anchors.centerIn: parent; spacing: 18
                Repeater { model: [[0xf66b, "#a3be8c", "apps"], [0xf1a1, "#b48ead", "reddit"], [0xf09b, "#81a1c1", "github"], [0xf0e0, "#bf616a", "mail"]]
                    Text { required property var modelData; text: P.v2(modelData[0]); color: modelData[1]; font.family: P.icons; font.pixelSize: 11
                        MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor; onClicked: root.launch(parent.modelData[2]) } } } } }
        Pill { y: 0; width: st.width + 26
            Row { id: st; anchors.centerIn: parent; spacing: 18
                Text { text: root.wifi || P.g(0xf05a9); color: P.red; font.family: P.icons; font.pixelSize: 12 }
                Text { text: P.g(root.caffeine ? 0xf0208 : 0xf0209); color: "#f0ac7b"; font.family: P.icons; font.pixelSize: 12
                       MouseArea { anchors.fill: parent; anchors.margins: -5; onClicked: root.launch("caffeine") } }
                Text { text: root.batteryGlyph || P.g(0xf06a5); color: P.purple; font.family: P.icons; font.pixelSize: 12 } } }
        Pill { y: 0; width: ck.width + 26
            Text { id: ck; anchors.centerIn: parent; text: P.g(0xf017) + " " + root.time; color: P.fg; font.family: P.sans; font.pixelSize: 13 } }
    }
}
