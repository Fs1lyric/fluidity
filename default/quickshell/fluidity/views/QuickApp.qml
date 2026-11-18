import QtQuick

// Quick actions: a grid of toggles and one-shot actions, then the power row. Arrows move, ↵ toggles,
// l / s / r / p lock, sleep, restart, shut down.
AppBase {
    id: a
    readonly property var tiles: d.tiles || []
    readonly property var power: d.power || []
    Text { x: 24; y: 16; text: "Quick actions"; color: a.pal.fg; font.family: a.serif; font.italic: true; font.pixelSize: 30 }
    Grid {
        x: 20; y: 64; columns: 3; spacing: 10
        Repeater {
            model: a.tiles
            Rectangle {
                readonly property bool lit: index === a.sel
                width: (a.width - 40 - 20) / 3; height: 70; radius: 24
                color: modelData.on ? "transparent" : a.faint
                Grad { anchors.fill: parent; radius: 24; pal: a.pal; visible: !!modelData.on }
                Rectangle { z: 2; anchors.fill: parent; anchors.margins: -3; radius: 27; color: "transparent"; visible: parent.lit; border.width: 2; border.color: a.pal.fg }
                Row {
                    anchors.verticalCenter: parent.verticalCenter; leftPadding: 18; spacing: 12
                    Text { text: modelData.icon; font.family: a.mono; font.pixelSize: 20; color: modelData.on ? a.ink : a.pal.fg; anchors.verticalCenter: parent.verticalCenter }
                    Column { anchors.verticalCenter: parent.verticalCenter
                        Text { text: modelData.label; color: modelData.on ? a.ink : a.pal.fg; font.family: a.sans; font.pixelSize: 14; font.weight: Font.Medium }
                        Text { text: modelData.state || (modelData.once ? "run" : modelData.on ? "on" : "off"); color: modelData.on ? a.alpha(a.ink, 0.6) : a.pal.dim; font.family: a.sans; font.pixelSize: 11 } }
                }
                MouseArea { anchors.fill: parent; onClicked: a.picked(index) }
            }
        }
    }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 18; spacing: 12
        Repeater {
            model: a.power
            Rectangle {
                readonly property bool lit: index + a.tiles.length === a.sel
                width: 120; height: 48; radius: 24; color: lit ? "transparent" : a.faint
                Grad { anchors.fill: parent; radius: 24; visible: parent.lit; pal: index >= 2 ? ({ accent: a.pal.red, cyan: a.pal.orange }) : a.pal }
                Row { anchors.centerIn: parent; spacing: 8
                    Text { text: modelData.icon; font.family: a.mono; font.pixelSize: 16; color: parent.parent.lit ? a.ink : index >= 2 ? a.pal.red : a.pal.fg }
                    Text { text: modelData.label; font.family: a.sans; font.pixelSize: 13; color: parent.parent.lit ? a.ink : a.pal.dim } }
                MouseArea { anchors.fill: parent; onClicked: a.picked(index + a.tiles.length) }
            }
        }
    }
}
