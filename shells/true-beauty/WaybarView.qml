// Waybar exactly as it ships (/etc/xdg/waybar config + style.css), which is what his `waybar &` runs:
// the left and centre modules are sway ones, so on Hyprland only the right side draws:
// idle_inhibitor, pulseaudio, network, cpu, memory, temperature, backlight, battery, clock, tray — each its own
// coloured block, on a half-transparent bar with a 3 px bottom border.
import QtQuick

Rectangle {
    id: w
    property var sys
    property bool inhibit: false
    property real backlight: 0.75
    signal act(string what, var arg)
    implicitHeight: 30
    color: Qt.rgba(43 / 255, 48 / 255, 59 / 255, 0.5)
    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 3; color: Qt.rgba(100 / 255, 114 / 255, 125 / 255, 0.5) }
    readonly property string font: "JetBrainsMono Nerd Font Propo"
    function g(cp) { return String.fromCodePoint(cp) }

    component Mod: Rectangle {
        id: m
        property string label
        property color fg: "#ffffff"
        property string what: ""
        height: 27; width: t.implicitWidth + 20
        Text { id: t; anchors.centerIn: parent; text: m.label; color: m.fg; font.family: w.font; font.pixelSize: 13 }
        MouseArea { anchors.fill: parent; enabled: m.what !== ""; cursorShape: Qt.PointingHandCursor; onClicked: w.act(m.what, null)
                    onWheel: e => { if (m.what === "mute") w.act("volumeStep", e.angleDelta.y > 0 ? 0.05 : -0.05) } }
    }

    Row {
        anchors.right: parent.right; spacing: 0
        Mod { color: w.inhibit ? "#ecf0f1" : "#2d3436"; fg: w.inhibit ? "#2d3436" : "#ffffff"; label: w.g(w.inhibit ? 0xf06e : 0xf070)
              MouseArea { anchors.fill: parent; onClicked: { w.inhibit = !w.inhibit; w.act("caffeine", null) } } }
        Mod { what: "mute"; color: w.sys?.muted ? "#90b1b1" : "#f1c40f"; fg: w.sys?.muted ? "#2a5c45" : "#000000"
              label: w.sys?.muted ? w.g(0xf026) : Math.round((w.sys?.volume ?? 0) * 100) + "% " + w.g(0xf028) }
        Mod { what: "wifi"; color: w.sys?.online ? "#2980b9" : "#f53c3c"
              label: w.sys?.wired ? "Wired " + w.g(0xf0200) : w.sys?.ssid ? w.sys.ssid + " (" + Math.round(w.sys.wifiStrength * 100) + "%) " + w.g(0xf1eb) : "Disconnected ⚠" }
        Mod { color: "#2ecc71"; fg: "#000000"; label: Math.round((w.sys?.cpu ?? 0) * 100) + "% " + w.g(0xf2db) }
        Mod { color: "#9b59b6"; label: Math.round((w.sys?.ram ?? 0) * 100) + "% " + w.g(0xf538) }
        Mod { color: (w.sys?.temp ?? 0) >= 80 ? "#eb4d4b" : "#f0932b"; label: Math.round(w.sys?.temp ?? 0) + "°C " + w.g(0xf2c9) }
        Mod { color: "#90b1b1"; label: Math.round(w.backlight * 100) + "% " + w.g(0xf0eb) }
        Mod { visible: w.sys?.hasBattery ?? false; color: w.sys?.charging ? "#26A65B" : (w.sys?.battery ?? 1) < 0.15 ? "#f53c3c" : "#ffffff"
              fg: w.sys?.charging ? "#ffffff" : "#000000"
              label: Math.round((w.sys?.battery ?? 1) * 100) + "% " + w.g(w.sys?.charging ? 0xf1e6 : 0xf240 + Math.min(4, Math.floor((1 - (w.sys?.battery ?? 1)) * 5))) }
        Mod { color: "#64727D"; label: Qt.formatDateTime(w.sys?.now ?? new Date(), "HH:mm") }
        Mod { color: "#2980b9"; label: w.g(0xf013); what: "settings" }
    }
}
