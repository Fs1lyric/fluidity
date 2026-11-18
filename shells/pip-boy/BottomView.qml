// The bottom row: Vault-Tec employee number, the five Pip-Boy tabs, the model name.
import QtQuick
import "Pal.js" as P

Item {
    id: v
    property var sys
    property string tab: ""
    signal pick(string t)
    implicitHeight: 28
    Rectangle { x: 8; width: parent.width - 16; height: 2; y: parent.height - 5; color: P.hi }
    Seg { x: 8; height: 23; up: false; text: "© VAULT-TEC : Employee No." + String((v.sys?.packages ?? 69) % 1000).padStart(3, "0") }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter; height: 23
        Repeater {
            model: ["STATS", "INV", "MAP", "DATA", "RADIO"]
            Seg { required property string modelData; up: false; bold: v.tab === modelData; text: modelData; onClicked: v.pick(modelData) }
        }
    }
    Seg { anchors.right: parent.right; anchors.rightMargin: 8; height: 23; up: false; text: "Pip-Boy-3000" }
}
