// Three glass pills: "HYPER AERO" + workspaces 01-05 / the clock and date / NET BT VOL LUM BAT SIG + power.
import QtQuick
import "Pal.js" as P

Item {
    id: t
    property var sys
    signal act(string what, var arg)
    implicitHeight: 40
    Rectangle {
        x: 12; y: 6; height: 28; width: left.implicitWidth + 24; radius: 14; color: P.glass; border.color: P.rim
        Row {
            id: left; anchors.centerIn: parent; spacing: 10
            Text { text: "◢  HYPER AERO"; font.family: P.sans; font.pixelSize: 11; font.letterSpacing: 2.2; color: P.ink; anchors.verticalCenter: parent.verticalCenter }
            Repeater {
                model: [1, 2, 3, 4, 5]
                Rectangle {
                    required property int modelData
                    readonly property bool on: (t.sys?.workspace ?? 1) === modelData
                    width: 34; height: 18; radius: 9; anchors.verticalCenter: parent.verticalCenter
                    color: on ? P.blue : "transparent"
                    Text { anchors.centerIn: parent; text: "0" + parent.modelData; font.family: P.sans; font.pixelSize: 10; color: parent.on ? "white" : "#a0aab4" }
                    MouseArea { anchors.fill: parent; onClicked: t.act("ws", parent.modelData) }
                }
            }
        }
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter; anchors.horizontalCenterOffset: -150; y: 6; height: 28; width: mid.implicitWidth + 36; radius: 14; color: P.glass; border.color: P.rim
        Row { id: mid; anchors.centerIn: parent; spacing: 10
              Text { text: Qt.formatDateTime(t.sys?.now ?? new Date(), "HH:mm"); font.family: P.sans; font.pixelSize: 15; font.weight: Font.Light; color: P.ink; anchors.verticalCenter: parent.verticalCenter }
              Text { text: Qt.formatDateTime(t.sys?.now ?? new Date(), "ddd d MMM"); font.family: P.sans; font.pixelSize: 10; color: P.label; anchors.verticalCenter: parent.verticalCenter } }
    }
    Rectangle {
        anchors.right: parent.right; anchors.rightMargin: 262; y: 6; height: 28; width: right.implicitWidth + 16; radius: 14; color: P.glass; border.color: P.rim
        Row {
            id: right; anchors.centerIn: parent; spacing: 16
            Repeater {
                model: [["NET", t.sys?.online ? Math.round((t.sys?.wifiStrength || 1) * 100) + "%" : "OFF", "wifi"], ["BT", t.sys?.btOn ? "ON" : "OFF", "bt"],
                        ["VOL", t.sys?.muted ? "MUTE" : Math.round((t.sys?.volume ?? 0) * 100), "mute"], ["LUM", "45", ""]]
                Row { required property var modelData; spacing: 6; anchors.verticalCenter: parent.verticalCenter
                      Text { text: parent.modelData[0]; font.family: P.sans; font.pixelSize: 10; font.letterSpacing: 1.2; color: P.label }
                      Text { text: parent.modelData[1]; font.family: P.sans; font.pixelSize: 10; font.letterSpacing: 1.2; color: parent.modelData[1] === "MUTE" ? P.red : P.ink }
                      TapHandler { onTapped: if (parent.modelData[2]) t.act(parent.modelData[2], null) } }
            }
            Row { spacing: 6; anchors.verticalCenter: parent.verticalCenter
                  Text { text: "BAT"; font.family: P.sans; font.pixelSize: 10; font.letterSpacing: 1.2; color: P.label }
                  Row { spacing: 2; anchors.verticalCenter: parent.verticalCenter
                        Repeater { model: 6; Rectangle { required property int index; width: 8; height: 3; color: index < Math.round((t.sys?.battery ?? 1) * 6) ? P.ink : "#cfd6dd" } } }
                  Text { text: Math.round((t.sys?.battery ?? 1) * 100); font.family: P.sans; font.pixelSize: 10; color: P.ink } }
            Text { text: "✲"; color: P.blue; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
            Row { spacing: 6; anchors.verticalCenter: parent.verticalCenter
                  Text { text: "SIG"; font.family: P.sans; font.pixelSize: 10; font.letterSpacing: 1.2; color: P.label }
                  Rectangle { width: 7; height: 7; radius: 4; color: t.sys?.online ? P.deep : P.red; anchors.verticalCenter: parent.verticalCenter } }
            Rectangle { width: 22; height: 22; radius: 11; color: P.blue; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: "⏻"; color: "white"; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; onClicked: t.act("power", null) } }
        }
    }
}
