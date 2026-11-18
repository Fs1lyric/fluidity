import QtQuick

// A showcase app's title row: serif name, a status line, and an on/off switch on the right.
Item {
    id: h
    property var pal: ({})
    property string title: ""
    property string status: ""
    property bool showSwitch: true
    property bool on: false
    property string hint: ""
    height: 60
    Text { id: t; x: 24; anchors.verticalCenter: parent.verticalCenter; text: h.title; color: h.pal.fg; font.family: "Instrument Serif"; font.italic: true; font.pixelSize: 30 }
    Text { anchors.left: t.right; anchors.leftMargin: 12; anchors.baseline: t.baseline; text: h.status; color: h.pal.dim; font.family: "Geist"; font.pixelSize: 13
        width: Math.max(0, sw.x - x - 16); elide: Text.ElideRight }
    Rectangle {
        id: sw; visible: h.showSwitch
        anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter
        width: 52; height: 30; radius: 15; color: h.on ? "transparent" : Qt.rgba(1, 1, 1, 0.1)
        Grad { anchors.fill: parent; radius: 15; pal: h.pal; visible: h.on }
        Rectangle { width: 22; height: 22; radius: 11; y: 4; x: h.on ? 26 : 4; color: h.on ? "#101316" : h.pal.dim }
        Text { anchors.right: parent.left; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: h.hint; color: h.pal.dim; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11 }
    }
}
