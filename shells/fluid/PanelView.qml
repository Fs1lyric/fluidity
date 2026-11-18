// The control panel (Super+F1), after the player and quick-actions cards in ilyamiro's shell: the track with a
// big cover and seek bar, the quick toggles, the volume slider and the app/power row. Keyboard-only: KeyNav
// moves a lime ring over the controls (arrows/hjkl, Enter, Left/Right on the slider, Esc closes).
import QtQuick

Rectangle {
    id: p
    property var sys
    signal act(string what, var arg)
    signal close()
    readonly property color fg: "#e3e4da"
    readonly property color dim: "#878880"
    readonly property color lime: "#d7e59b"
    readonly property color ink: "#1d2110"
    readonly property color card: "#1b1f23"
    readonly property string mono: "JetBrains Mono"
    readonly property string icons: "Iosevka Nerd Font"
    property bool showSelection: false   // previews
    implicitWidth: 420; implicitHeight: col.implicitHeight + 32
    radius: 16; color: "#f2111417"; border.color: "#2a2f35"; border.width: 1
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()

    readonly property var toggles: [
        { id: "wifi", glyph: "\u{F05A9}", label: "Wi-Fi", on: sys?.wifiOn ?? false },
        { id: "bt", glyph: "󰂯", label: "Bluetooth", on: sys?.btOn ?? false },
        { id: "mute", glyph: "󰝟", label: "Mute", on: sys?.muted ?? false },
        { id: "mic", glyph: "󰍭", label: "Mic off", on: sys?.micMuted ?? false },
        { id: "night", glyph: "󰖔", label: "Night", on: false },
        { id: "caffeine", glyph: "󰅶", label: "Awake", on: sys?.caffeine ?? false }]
    readonly property var apps: [
        { id: "launcher", glyph: "\u{F003B}", label: "Apps" }, { id: "terminal", glyph: "\u{F018D}", label: "Term" },
        { id: "files", glyph: "\u{F024B}", label: "Files" }, { id: "settings", glyph: "\u{F0493}", label: "Settings" },
        { id: "lock", glyph: "\u{F033E}", label: "Lock" }, { id: "power", glyph: "⏻", label: "Power" }]
    property bool night: false

    function clock(s) { s = Math.max(0, Math.floor(s)); return String(Math.floor(s / 60)).padStart(2, "0") + ":" + String(s % 60).padStart(2, "0") }
    function press(id) {
        switch (id) {
        case "prev": case "play": case "next": case "wifi": case "bt": case "mic": case "caffeine":
        case "launcher": case "terminal": case "files": case "settings": case "lock": case "power":
            p.act(id, null); break
        case "mute": p.act("mute", null); break
        case "night": p.night = !p.night; p.act("night", p.night); break
        }
        if (["launcher", "terminal", "files", "settings", "lock", "power"].indexOf(id) >= 0) p.close()
    }

    KeyNav {
        id: keys
        focus: true
        rows: [(p.sys?.hasPlayer ?? false) ? ["prev", "play", "next"] : ["play"],
               p.toggles.slice(0, 3).map(t => t.id), p.toggles.slice(3).map(t => t.id),
               ["volume"], p.apps.slice(0, 3).map(a => a.id), p.apps.slice(3).map(a => a.id)]
        sliders: ["volume"]
        always: p.showSelection
        onPress: id => p.press(id)
        onNudge: (id, d) => p.act("volumeStep", d * 0.05)
        onClose: p.close()
    }

    component Ring: Rectangle {
        property string key
        color: "transparent"; radius: 12; anchors.fill: parent; anchors.margins: -3
        border.color: p.lime; border.width: 2; visible: keys.isSel(key)
    }

    Column {
        id: col
        x: 16; y: 16; width: parent.width - 32; spacing: 14

        Rectangle {
            width: parent.width; height: 132; radius: 14; color: p.card
            Rectangle { id: cover; x: 12; y: 12; width: 108; height: 108; radius: 54; color: "#2a2e33"; clip: true
                        Image { anchors.fill: parent; source: p.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop }
                        Rectangle { anchors.centerIn: parent; width: 18; height: 18; radius: 9; color: "#111417"; border.color: p.lime; border.width: 2 } }
            Column {
                x: cover.width + 26; y: 14; width: parent.width - x - 14; spacing: 4
                Text { width: parent.width; elide: Text.ElideRight; text: (p.sys?.hasPlayer ?? false) ? p.sys.track : "Nothing playing"
                       font.family: p.mono; font.pixelSize: 16; font.bold: true; color: p.fg }
                Text { width: parent.width; elide: Text.ElideRight; text: (p.sys?.artist ?? "") ? "By " + p.sys.artist : ""
                       font.family: p.mono; font.pixelSize: 11; color: p.dim }
                Item { width: 1; height: 6 }
                Rectangle { width: parent.width; height: 6; radius: 3; color: "#33372e"
                            Rectangle { height: parent.height; radius: 3; color: p.lime
                                        width: parent.width * Math.min(1, (p.sys?.position ?? 0) / Math.max(1, p.sys?.length ?? 1)) } }
                Item { width: parent.width; height: 14
                       Text { text: p.clock(p.sys?.position ?? 0); font.family: p.mono; font.pixelSize: 9; color: p.dim }
                       Text { anchors.right: parent.right; text: p.clock(p.sys?.length ?? 0); font.family: p.mono; font.pixelSize: 9; color: p.dim } }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter; spacing: 14
                    Repeater {
                        model: [["prev", "󰒮"], ["play", (p.sys?.playing ?? false) ? "󰏤" : "󰐊"], ["next", "󰒭"]]
                        Rectangle { required property var modelData
                                    width: 34; height: 30; radius: 9; color: modelData[0] === "play" ? p.lime : "transparent"
                                    Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.icons; font.pixelSize: 17
                                           color: modelData[0] === "play" ? p.ink : p.fg }
                                    Ring { key: modelData[0] } } }
                }
            }
        }

        Grid {
            columns: 3; spacing: 8; width: parent.width
            Repeater {
                model: p.toggles
                Rectangle { required property var modelData
                            readonly property bool lit: modelData.id === "night" ? p.night : modelData.on
                            width: (col.width - 16) / 3; height: 44; radius: 12; color: lit ? p.lime : p.card
                            Row { anchors.centerIn: parent; spacing: 8
                                  Text { text: modelData.glyph; font.family: p.icons; font.pixelSize: 16; color: parent.parent.lit ? p.ink : p.fg; anchors.verticalCenter: parent.verticalCenter }
                                  Text { text: modelData.label; font.family: p.mono; font.pixelSize: 11; font.bold: true; color: parent.parent.lit ? p.ink : p.fg; anchors.verticalCenter: parent.verticalCenter } }
                            Ring { key: modelData.id } }
            }
        }

        Rectangle {
            width: parent.width; height: 40; radius: 12; color: p.card
            Text { x: 14; anchors.verticalCenter: parent.verticalCenter; text: (p.sys?.muted ?? false) ? "󰝟" : "󰕾"; font.family: p.icons; font.pixelSize: 16; color: p.fg }
            Rectangle { x: 44; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 98; height: 8; radius: 4; color: "#33372e"
                        Rectangle { height: parent.height; radius: 4; color: p.lime; width: parent.width * Math.min(1, p.sys?.volume ?? 0) } }
            Text { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter
                   text: Math.round((p.sys?.volume ?? 0) * 100); font.family: p.mono; font.pixelSize: 12; font.bold: true; color: p.fg }
            Ring { key: "volume" }
        }

        Grid {
            columns: 3; spacing: 8; width: parent.width
            Repeater {
                model: p.apps
                Rectangle { required property var modelData
                            width: (col.width - 16) / 3; height: 38; radius: 12; color: p.card
                            Row { anchors.centerIn: parent; spacing: 8
                                  Text { text: modelData.glyph; font.family: p.icons; font.pixelSize: 15; color: modelData.id === "power" ? "#f2a7a7" : p.fg; anchors.verticalCenter: parent.verticalCenter }
                                  Text { text: modelData.label; font.family: p.mono; font.pixelSize: 11; color: p.fg; anchors.verticalCenter: parent.verticalCenter } }
                            Ring { key: modelData.id } }
            }
        }

        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "←↑↓→ / hjkl move · ⏎ press · ←→ volume · esc close"
               font.family: p.mono; font.pixelSize: 9; color: p.dim }
    }
}
