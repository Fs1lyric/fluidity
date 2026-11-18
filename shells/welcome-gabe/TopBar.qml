// Gabe's top polybar: roman-numeral bspwm desktops I-X split by violet chevrons (the focused one bright),
// and on the right powerline segments that get lighter towards the clock: network with up/down speed,
// disk, CPU, memory, temperature (red), battery (green), time. Fira Code. Pure view.
import QtQuick

Rectangle {
    id: bar
    property var sys
    color: "#10011e"
    implicitHeight: 22
    readonly property string mono: "Fira Code"
    readonly property string icons: "Iosevka Nerd Font"
    readonly property var roman: ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]
    function rate(b) { return b > 1048576 ? (b / 1048576).toFixed(0) + " MB/s" : Math.round(b / 1024) + " KB/s" }

    Row {
        x: 8; height: parent.height; spacing: 8
        Repeater {
            model: (bar.sys?.tags ?? []).slice(0, 10)
            Row { required property var modelData; required property int index; spacing: 8; height: bar.height
                  Text { visible: index > 0; text: "❯"; font.family: bar.mono; font.pixelSize: 12; color: "#6f32ba"; anchors.verticalCenter: parent.verticalCenter }
                  Text { text: bar.roman[modelData.id - 1] ?? modelData.id; font.family: bar.mono; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter
                         color: modelData.state === "focused" ? "#cfd0ff" : modelData.state === "occupied" ? "#a422c1" : "#4b4dd2" } }
        }
    }

    // segment: powerline arrow + coloured block; shades step from dark to light purple
    component Seg: Row {
        default property alias content: inner.data
        property color shade
        height: bar.height
        Text { text: "\u{E0B2}"; font.family: bar.icons; font.pixelSize: 22; color: parent.shade; anchors.verticalCenter: parent.verticalCenter }
        Rectangle { color: parent.shade; height: bar.height; width: inner.childrenRect.width + 12
                    Item { id: inner; x: 6; height: parent.height } }
    }
    component Mod: Row {
        property string glyph
        property string value
        property color tint: "#9b9cc7"
        spacing: 5; height: bar.height
        Text { text: parent.glyph; font.family: bar.icons; font.pixelSize: 12; color: parent.tint; anchors.verticalCenter: parent.verticalCenter }
        Text { text: parent.value; font.family: bar.mono; font.pixelSize: 12; color: parent.tint; anchors.verticalCenter: parent.verticalCenter }
    }

    Row {
        anchors.right: parent.right; height: parent.height
        Seg { shade: "#1b0636"; Mod { glyph: "\u{F05A9}"; value: (bar.sys?.wired ? "wired" : (bar.sys?.ssid || "offline")) + "  ↑ " + bar.rate(bar.sys?.netUp ?? 0) + "  ↓ " + bar.rate(bar.sys?.netDown ?? 0) } }
        Seg { shade: "#220842"; Mod { glyph: "\u{F02CA}"; value: bar.sys?.diskFree ?? "" } }
        Seg { shade: "#2a0b50"; Mod { glyph: "\u{F061A}"; value: Math.round((bar.sys?.cpu ?? 0) * 100) + "%" } }
        Seg { shade: "#320e5e"; Mod { glyph: "\u{F035B}"; value: Math.round((bar.sys?.ram ?? 0) * 100) + "%" } }
        Seg { shade: "#3a116c"; Mod { glyph: "\u{F050F}"; value: Math.round(bar.sys?.temp ?? 0) + "°C"; tint: "#ff3b6b" } }
        Seg { shade: "#43147a"; visible: bar.sys?.hasBattery ?? false
              Mod { glyph: "\u{F0079}"; value: Math.round((bar.sys?.battery ?? 1) * 100) + "%" + (bar.sys?.charging ? " Full" : ""); tint: "#4dff8a" } }
        Seg { shade: "#4b1788"; Mod { glyph: "\u{F0954}"; value: Qt.formatDateTime(bar.sys?.now ?? new Date(), "hh:mm AP"); tint: "#cfd0ff" } }
    }
}
