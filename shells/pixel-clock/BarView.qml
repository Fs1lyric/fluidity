// Bahaaio's polybar (i3, Nov 2025): one flat near-black strip in bold JetBrains Mono with "|" separators.
// Left: workspaces (the active one boxed and underlined in mauve), weather, brightness, volume. Centre: the
// date "Sun 16th | 02:05 AM". Right: memory, CPU, temperature, battery, network. Icons in mauve. Pure view.
import QtQuick

Rectangle {
    id: bar
    property var sys
    property real brightness: -1
    color: "#090e13"
    implicitHeight: 28
    readonly property color fg: "#cdd6f4"
    readonly property color off: "#585b70"
    readonly property color mauve: "#cba6f7"
    readonly property string mono: "JetBrains Mono"
    readonly property string icons: "Iosevka Nerd Font"

    function ord(d) { const n = d.getDate(); const s = (n % 100 >= 11 && n % 100 <= 13) ? "th" : ["th", "st", "nd", "rd"][n % 10] ?? "th"; return n + s }

    component Mod: Row {
        property string glyph
        property string value
        spacing: 6; height: bar.height
        Text { text: parent.glyph; font.family: bar.icons; font.pixelSize: 14; color: bar.mauve; anchors.verticalCenter: parent.verticalCenter }
        Text { text: parent.value; font.family: bar.mono; font.bold: true; font.pixelSize: 13; color: bar.fg; anchors.verticalCenter: parent.verticalCenter }
    }
    component Sep: Text { text: "|"; font.family: bar.mono; font.pixelSize: 13; color: bar.off; anchors.verticalCenter: parent?.verticalCenter }

    Row {
        x: 6; height: parent.height; spacing: 10
        Row { height: parent.height
              Repeater { model: (bar.sys?.tags ?? []).filter(t => t.state !== "empty" || t.id <= 3).slice(0, 9)
                         Rectangle { required property var modelData; readonly property bool on: modelData.state === "focused"
                                     width: 24; height: bar.height; color: on ? "#1e1e2e" : "transparent"
                                     Text { anchors.centerIn: parent; text: modelData.id; font.family: bar.mono; font.bold: true; font.pixelSize: 13
                                            color: modelData.state === "empty" ? bar.off : bar.fg }
                                     Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: bar.mauve; visible: parent.on } } } }
        Sep {}
        Mod { visible: (bar.sys?.weatherTemp ?? "") !== ""; glyph: "\u{F0599}"; value: (bar.sys?.weatherTemp ?? "") + "°C" }
        Sep { visible: bar.brightness >= 0 }
        Mod { visible: bar.brightness >= 0; glyph: "\u{F00DF}"; value: Math.round(bar.brightness * 100) + "%" }
        Sep {}
        Mod { glyph: (bar.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}"; value: (bar.sys?.muted ?? false) ? "muted" : Math.round((bar.sys?.volume ?? 0) * 100) + "%" }
        Sep {}
    }

    Text { anchors.centerIn: parent; font.family: bar.mono; font.bold: true; font.pixelSize: 13; color: bar.fg
           text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "ddd") + " " + bar.ord(bar.sys?.now ?? new Date()) + " | " + Qt.formatDateTime(bar.sys?.now ?? new Date(), "hh:mm AP") }

    Row {
        anchors.right: parent.right; anchors.rightMargin: 10; height: parent.height; spacing: 10
        Mod { glyph: "\u{F035B}"; value: Math.round((bar.sys?.ram ?? 0) * 100) + "%" }
        Sep {}
        Mod { glyph: "\u{F061A}"; value: Math.round((bar.sys?.cpu ?? 0) * 100) + "%" }
        Sep {}
        Mod { glyph: "\u{F050F}"; value: Math.round(bar.sys?.temp ?? 0) + "°C" }
        Sep { visible: bar.sys?.hasBattery ?? false }
        Mod { visible: bar.sys?.hasBattery ?? false; glyph: bar.sys?.charging ? "\u{F0084}" : "\u{F0079}"; value: Math.round((bar.sys?.battery ?? 1) * 100) + "%" }
        Sep {}
        Text { text: bar.sys?.online ? (bar.sys?.wired ? "\u{F0200}" : "\u{F05A9}") : "\u{F05AA}"; font.family: bar.icons; font.pixelSize: 14; color: bar.mauve; anchors.verticalCenter: parent.verticalCenter }
    }
}
