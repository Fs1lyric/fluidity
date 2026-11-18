// DMS control centre in his widget order (volume, brightness, wifi, bluetooth, do not disturb, night mode),
// square corners on black like the amoledBlack bar.
import QtQuick

Rectangle {
    id: cc
    property var sys
    property bool dnd: false
    property bool night: false
    signal act(string what, var arg)
    implicitWidth: 360; implicitHeight: col.implicitHeight + 28
    color: "#000000"; border.color: "#e9e4d4"; border.width: 1
    readonly property color ink: "#e9e4d4"
    readonly property string font: "iMWritingQuat Nerd Font Propo"
    function g(cp) { return String.fromCodePoint(cp) }

    component Slider: Item {
        id: sl
        property real value: 0
        property int glyph: 0
        signal moved(real v)
        width: parent.width; height: 26
        Text { id: ic; text: cc.g(sl.glyph); color: cc.ink; font.family: cc.font; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter }
        Rectangle { id: track; anchors { left: ic.right; leftMargin: 12; right: parent.right; verticalCenter: parent.verticalCenter }
                    height: 6; color: "#2b2a26"
            Rectangle { width: parent.width * sl.value; height: parent.height; color: cc.ink } }
        MouseArea { anchors.fill: track; anchors.margins: -8; onPressed: m => sl.moved(m.x / width); onPositionChanged: m => sl.moved(Math.max(0, Math.min(1, m.x / width))) }
    }
    component Toggle: Rectangle {
        id: tg
        property string label
        property string detail
        property int glyph
        property bool on: false
        signal tapped()
        width: (col.width - 8) / 2; height: 46
        color: on ? cc.ink : "transparent"; border.color: cc.ink; border.width: 1
        Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: cc.g(tg.glyph); font.family: cc.font; font.pixelSize: 16; color: tg.on ? "#000000" : cc.ink }
        Column { x: 40; anchors.verticalCenter: parent.verticalCenter
            Text { text: tg.label; font.family: cc.font; font.pixelSize: 12; color: tg.on ? "#000000" : cc.ink }
            Text { text: tg.detail; font.family: cc.font; font.pixelSize: 10; color: tg.on ? "#3a3a3a" : "#8a867b"; visible: text !== "" } }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: tg.tapped() }
    }

    Column {
        id: col
        x: 14; y: 14; width: parent.width - 28; spacing: 12
        Slider { glyph: 0xf057e; value: cc.sys?.volume ?? 0; onMoved: v => cc.act("volume", v) }
        Slider { glyph: 0xf00df; value: 0.8; onMoved: v => cc.act("brightness", v) }
        Flow {
            width: parent.width; spacing: 8
            Toggle { label: "Wi-Fi"; detail: cc.sys?.ssid || (cc.sys?.wired ? "Ethernet" : "Off"); glyph: 0xf0928; on: cc.sys?.wifiOn ?? false; onTapped: cc.act("wifi", null) }
            Toggle { label: "Bluetooth"; detail: cc.sys?.btOn ? "On" : "Off"; glyph: 0xf00af; on: cc.sys?.btOn ?? false; onTapped: cc.act("bt", null) }
            Toggle { label: "Do not disturb"; glyph: 0xf009b; on: cc.dnd; onTapped: { cc.dnd = !cc.dnd; cc.act("dnd", null) } }
            Toggle { label: "Night mode"; glyph: 0xf0594; on: cc.night; onTapped: { cc.night = !cc.night; cc.act("night", cc.night) } }
        }
    }
}
