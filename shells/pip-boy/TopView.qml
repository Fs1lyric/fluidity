// The top row: STATS | RAD on the left, S.P.E.C.I.A.L. (workspaces) in the middle, SKILLS on the right.
import QtQuick
import "Pal.js" as P

Item {
    id: v
    property var sys
    signal act(string what, var arg)
    implicitHeight: 30
    readonly property var special: ["S", "P", "E", "C", "I", "A", "L"]
    Rectangle { x: 8; width: parent.width - 16; height: 2; y: 3; color: P.hi }
    Row {
        x: 8; y: 3; height: 26
        Seg { text: "STATS"; bold: true }
        Seg { text: "󰁹 HP " + Math.round((v.sys?.battery ?? 1) * 100) + "/100   AP " + Math.round((v.sys?.ramTotal ?? 0) - (v.sys?.ramUsed ?? 0)) + "/" + Math.round(v.sys?.ramTotal ?? 0)
                    + "   XP " + Math.round((v.sys?.diskUsed ?? 0) * 100) + "/100" }
        Seg { text: "󰐼 RAD " + Math.round((v.sys?.cpu ?? 0) * 100) + "/100"; onClicked: v.act("exec", ["ghostty", "-e", "btop"]) }
    }
    Seg {
        x: (parent.width - width) / 2; y: 3; height: 26
        text: v.special.join(" . ") + " ."
        Row {   // the underline under the focused workspace's letter + click targets
            anchors.centerIn: parent
            Repeater {
                model: v.special
                Item {
                    required property int index
                    width: parent.parent.width / 7.6; height: 26
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; y: 21; width: 14; height: 2; color: P.hi
                                visible: (v.sys?.workspace ?? 1) === parent.index + 1 }
                    MouseArea { anchors.fill: parent; onClicked: v.act("ws", parent.index + 1) }
                }
            }
        }
    }
    Row {
        anchors.right: parent.right; anchors.rightMargin: 8; y: 3; height: 26
        Seg { text: "SKILLS"; bold: true }
        Seg { text: (v.sys?.muted ? "󰖁 " : "󰕾 ") + Math.round((v.sys?.volume ?? 0) * 100) + "%"; onClicked: v.act("mute", null) }
        Seg { text: "󰖩 " + (v.sys?.online ? (v.sys.wired ? "VAULT-LAN" : (v.sys.ssid || "VAULT-101").toUpperCase()) : "NO SIGNAL"); onClicked: v.act("wifi", null) }
        Seg { text: "󰃭 " + Qt.formatDateTime(v.sys?.now ?? new Date(), "ddd dd MMM HH:mm") }
        Seg { text: "󰌾"; onClicked: v.act("lock", null) }
    }
}
