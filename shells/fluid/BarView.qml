// ilyamiro's top bar as it looks in the post: a row of near-black rounded pills over the wallpaper.
// Left: launcher + notifications, workspaces 1-8 (the focused one is a lime pill), the playing track with its
// controls. Centre: clock with the date under it and the weather. Right: Wi-Fi (lime), Bluetooth and volume
// (pale pastel pills) and the battery. Pure view: takes `sys`, says what was pressed through act().
import QtQuick

Item {
    id: bar
    property var sys
    signal act(string what, var arg)
    readonly property color pill: "#ec111417"
    readonly property color fg: "#e3e4da"
    readonly property color dim: "#878880"
    readonly property color lime: "#d7e59b"
    readonly property color ink: "#1d2110"
    readonly property string mono: "JetBrains Mono"
    readonly property string icons: "Iosevka Nerd Font"
    implicitHeight: 34

    function clock(s) { s = Math.max(0, Math.floor(s)); return String(Math.floor(s / 60)).padStart(2, "0") + ":" + String(s % 60).padStart(2, "0") }
    function weatherGlyph(c) {
        c = (c || "").toLowerCase()
        return c.includes("rain") || c.includes("drizzle") ? "\u{F0597}" : c.includes("snow") ? "\u{F0598}" : c.includes("thunder") ? "\u{F0593}"
             : c.includes("clear") || c.includes("sun") ? (bar.sys?.night ? "\u{F0594}" : "\u{F0599}") : "\u{F0590}"
    }

    component Pill: Rectangle {
        default property alias content: inner.data
        property int pad: 10
        height: 30; radius: 10; color: bar.pill
        width: inner.childrenRect.width + pad * 2
        Item { id: inner; x: parent.pad; height: parent.height }
    }
    component Glyph: Text { font.family: bar.icons; font.pixelSize: 15; color: bar.fg; anchors.verticalCenter: parent?.verticalCenter }
    component Label: Text { font.family: bar.mono; font.pixelSize: 12; font.bold: true; color: bar.fg; anchors.verticalCenter: parent?.verticalCenter }

    Row {
        x: 6; y: 2; spacing: 6
        Pill { Row { spacing: 18; height: 30
                     Glyph { text: "\u{F0349}" } Glyph { text: "\u{F009A}" } } }
        Pill { pad: 6
               Row { spacing: 4; height: 30
                     Repeater { model: (bar.sys?.tags ?? []).slice(0, 8)
                                Rectangle { required property var modelData
                                            readonly property bool on: modelData.state === "focused"
                                            width: 26; height: 22; radius: 7; anchors.verticalCenter: parent.verticalCenter
                                            color: on ? bar.lime : "transparent"
                                            Label { anchors.centerIn: parent; text: modelData.id
                                                    color: parent.on ? bar.ink : modelData.state === "occupied" ? bar.fg : bar.dim } } } } }
        Pill { visible: bar.sys?.hasPlayer ?? false; pad: 6
               Row { spacing: 10; height: 30
                     Rectangle { width: 24; height: 24; radius: 6; color: "#2a2e33"; clip: true; anchors.verticalCenter: parent.verticalCenter
                                 Image { anchors.fill: parent; source: bar.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop } }
                     Column { anchors.verticalCenter: parent.verticalCenter; width: 200
                              Text { width: parent.width; elide: Text.ElideRight; text: bar.sys?.track ?? ""
                                     font.family: bar.mono; font.pixelSize: 12; font.bold: true; color: bar.fg }
                              Text { text: bar.clock(bar.sys?.position ?? 0) + " / " + bar.clock(bar.sys?.length ?? 0)
                                     font.family: bar.mono; font.pixelSize: 9; color: bar.dim } }
                     Glyph { text: "󰒮" } Glyph { text: bar.sys?.playing ? "󰏤" : "󰐊"; font.pixelSize: 18 } Glyph { text: "󰒭" } } }
    }

    Pill {
        anchors.horizontalCenter: parent.horizontalCenter; y: 2; pad: 14
        Row { spacing: 14; height: 30
              Column { anchors.verticalCenter: parent.verticalCenter
                       Text { text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "hh:mm:ss AP"); font.family: bar.mono; font.pixelSize: 13; font.bold: true; color: bar.fg }
                       Text { text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "dddd, MMMM d"); font.family: bar.mono; font.pixelSize: 8; color: bar.dim } }
              Glyph { text: bar.weatherGlyph(bar.sys?.weatherCond); font.pixelSize: 17; visible: (bar.sys?.weatherTemp ?? "") !== "" }
              Label { text: (bar.sys?.weatherTemp ?? "") + "°C"; font.pixelSize: 14; visible: (bar.sys?.weatherTemp ?? "") !== "" } }
    }

    Row {
        anchors.right: parent.right; anchors.rightMargin: 6; y: 2; spacing: 6
        Pill { color: bar.lime; pad: 10
               Row { spacing: 8; height: 30
                     Glyph { color: bar.ink; text: bar.sys?.online ? (bar.sys?.wired ? "󰈀" : "\u{F05A9}") : "󰖪" }
                     Label { color: bar.ink; width: Math.min(implicitWidth, 110); elide: Text.ElideRight
                             text: bar.sys?.wired ? "Wired" : (bar.sys?.ssid || "Offline") } } }
        Pill { color: "#cfe3a8"; pad: 10
               Row { spacing: 8; height: 30
                     Glyph { color: bar.ink; text: bar.sys?.btOn ? "󰂯" : "󰂲" }
                     Label { color: bar.ink; text: !(bar.sys?.btOn) ? "Off" : (bar.sys?.btConnected ?? 0) > 0 ? bar.sys.btConnected + " on" : "On" } } }
        Pill { color: "#c2e6d6"; pad: 10
               Row { spacing: 8; height: 30
                     Glyph { color: bar.ink; text: bar.sys?.muted ? "󰝟" : "󰕾" }
                     Label { color: bar.ink; text: Math.round((bar.sys?.volume ?? 0) * 100) } } }
        Pill { visible: bar.sys?.hasBattery ?? false
               Row { spacing: 6; height: 30
                     Glyph { text: bar.sys?.charging ? "󰂄" : "󰁹" }
                     Label { text: Math.round((bar.sys?.battery ?? 1) * 100) } } }
    }
}
