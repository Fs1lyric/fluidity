import QtQuick

// A key cap: "❖", "A", "Space". `on` = drawn on an accent pill (dark ink).
Rectangle {
    property string text: ""
    property bool on: false
    property bool lit: false
    property var pal: ({})
    implicitWidth: Math.max(22, t.implicitWidth + 14); implicitHeight: 22; radius: 8
    color: lit ? (pal.accent || "#d7e59b") : on ? Qt.rgba(0.06, 0.07, 0.09, 0.14) : Qt.rgba(1, 1, 1, 0.07)
    Text { id: t; anchors.centerIn: parent; text: parent.text; color: parent.lit || parent.on ? "#101316" : (parent.pal.fg || "#e3e4da"); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 }
}
