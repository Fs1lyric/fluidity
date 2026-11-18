// Gabe's bottom polybar: the mpd module on the left (♪ track, time, ⏮ ⏸ ⏭), the window title in the centre,
// and powerline segments on the right: installed packages, brightness, volume. Pure view.
import QtQuick

Rectangle {
    id: bar
    property var sys
    property real brightness: -1
    color: "#10011e"
    implicitHeight: 22
    readonly property string mono: "Fira Code"
    readonly property string icons: "Iosevka Nerd Font"
    function clock(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }

    Row {
        x: 8; height: parent.height; spacing: 8
        Text { text: "♪ " + (bar.sys?.track || "nothing playing") + "  " + bar.clock(bar.sys?.position ?? 0) + " / " + bar.clock(bar.sys?.length ?? 0)
               font.family: bar.mono; font.pixelSize: 12; color: "#4b4dd2"; anchors.verticalCenter: parent.verticalCenter }
        Text { text: "\u{F04AE}  " + ((bar.sys?.playing ?? false) ? "\u{F03E4}" : "\u{F040A}") + "  \u{F04AD}"; font.family: bar.icons; font.pixelSize: 11; color: "#9b9cc7"; anchors.verticalCenter: parent.verticalCenter }
    }
    Text { anchors.centerIn: parent; text: bar.sys?.appClass ?? ""; font.family: bar.mono; font.pixelSize: 12; color: "#9b9cc7" }

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
        spacing: 5; height: bar.height
        Text { text: parent.glyph; font.family: bar.icons; font.pixelSize: 12; color: "#9b9cc7"; anchors.verticalCenter: parent.verticalCenter }
        Text { text: parent.value; font.family: bar.mono; font.pixelSize: 12; color: "#9b9cc7"; anchors.verticalCenter: parent.verticalCenter }
    }
    Row {
        anchors.right: parent.right; height: parent.height
        Seg { shade: "#2a0b50"; Mod { glyph: "\u{F0AB3}"; value: (bar.sys?.packages ?? 0) + "" } }
        Seg { shade: "#3a116c"; visible: bar.brightness >= 0; Mod { glyph: "\u{F00DF}"; value: Math.round(bar.brightness * 100) + "%" } }
        Seg { shade: "#43147a"; Mod { glyph: (bar.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}"; value: Math.round((bar.sys?.volume ?? 0) * 100) + "%" } }
    }
}
