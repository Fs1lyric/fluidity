// elenapan's exit screen: "Goodbye <Name>" and five big icons. Keys as in the original:
// p poweroff, r reboot, s suspend, e exit, l lock; Escape / q / x closes.
// Original: config/awesome/exit_screen.lua
import QtQuick

Rectangle {
    id: root
    property string iconDir: "icons/"
    property string font: "Google Sans"
    property string userName: "Lyric"
    signal chosen(string action)   // poweroff reboot suspend exit lock
    signal closed()

    implicitWidth: 1366
    implicitHeight: 768
    color: "#cc282a36"   // xcolor0 .. "CC"
    focus: true

    Keys.onPressed: e => {
        const k = e.text.toLowerCase();
        const map = { p: "poweroff", r: "reboot", s: "suspend", e: "exit", l: "lock" };
        if (map[k]) { root.chosen(map[k]); e.accepted = true; }
        else if (e.key === Qt.Key_Escape || k === "q" || k === "x") { root.closed(); e.accepted = true; }
    }

    MouseArea { anchors.fill: parent; onClicked: root.closed() }

    Column {
        anchors.centerIn: parent
        spacing: 40
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Goodbye " + root.userName
            color: "#fdfdfd"; font.family: root.font; font.pointSize: 50
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 50
            Repeater {
                model: [["poweroff", "Poweroff"], ["reboot", "Reboot"], ["suspend", "Suspend"], ["exit", "Exit"], ["lock", "Lock"]]
                Column {
                    required property var modelData
                    spacing: 14
                    Image {
                        width: 110; height: 110
                        sourceSize: Qt.size(192, 192); smooth: true; mipmap: true
                        source: root.iconDir + parent.modelData[0] + ".png"
                        scale: ma.containsMouse ? 1.08 : 1
                        Behavior on scale { NumberAnimation { duration: 120 } }
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.chosen(parent.parent.modelData[0]) }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: parent.modelData[1]
                        color: "#fdfdfd"; font.family: root.font; font.pointSize: 14
                    }
                }
            }
        }
    }
}
