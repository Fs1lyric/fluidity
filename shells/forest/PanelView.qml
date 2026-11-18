// nuxshed's control centre (Super+F1): the big tan clock and his quote, the volume (green) and brightness
// (pink) sliders, CPU (yellow) and memory (red) rings, and the round toggle buttons (aqua when on).
// Keyboard-only through KeyNav: Up/Down between rows, Left/Right on a slider changes it, Enter toggles, Esc.
import QtQuick

Rectangle {
    id: p
    property var sys
    property real brightness: -1        // 0..1, or -1 when there is no backlight (the row hides)
    property bool night: false
    property bool showSelection: false
    signal act(string what, var arg)
    signal close()
    readonly property color card: "#1d2021"
    readonly property color fg: "#d4be98"
    readonly property color grey: "#928374"
    readonly property color aqua: "#89b482"
    readonly property string mono: "JetBrains Mono"
    readonly property string icons: "Iosevka Nerd Font"
    implicitWidth: 376; implicitHeight: col.implicitHeight + 50
    radius: 8; color: "#161819"
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()

    readonly property var buttons: [
        { id: "wifi", glyph: "\u{F05A9}", on: sys?.wifiOn ?? false },
        { id: "bt", glyph: "\u{F00AF}", on: sys?.btOn ?? false },
        { id: "night", glyph: "\u{F0594}", on: p.night },
        { id: "caffeine", glyph: "\u{F0176}", on: sys?.caffeine ?? false }]

    KeyNav {
        id: keys
        focus: true
        always: p.showSelection
        rows: p.brightness >= 0 ? [["volume"], ["brightness"], p.buttons.map(b => b.id)] : [["volume"], p.buttons.map(b => b.id)]
        sliders: ["volume", "brightness"]
        onPress: id => { if (id === "night") { p.night = !p.night; p.act("night", p.night) }
                         else if (id === "volume") p.act("mute", null)
                         else if (id !== "brightness") p.act(id, null) }
        onNudge: (id, d) => id === "volume" ? p.act("volumeStep", d * 0.05) : p.act("brightness", Math.max(0.05, Math.min(1, p.brightness + d * 0.05)))
        onClose: p.close()
    }

    component Ring: Rectangle {
        property string key
        anchors.fill: parent; anchors.margins: -3; radius: parent.radius + 3; color: "transparent"
        border.color: p.fg; border.width: 2; visible: keys.isSel(key)
    }
    component Dial: Rectangle {
        id: dial
        property real value: 0
        property color tint
        property string glyph
        width: (col.width - 20) / 2; height: 148; radius: 6; color: p.card
        Canvas {
            anchors.centerIn: parent; width: 112; height: 112
            property real v: dial.value
            onVChanged: requestPaint()
            onPaint: { const c = getContext("2d"); c.reset(); c.lineWidth = 8; c.lineCap = "round"
                       c.strokeStyle = "#282828"; c.beginPath(); c.arc(56, 56, 50, 0, 2 * Math.PI); c.stroke()
                       c.strokeStyle = dial.tint; c.beginPath(); c.arc(56, 56, 50, Math.PI / 2, Math.PI / 2 + 2 * Math.PI * Math.max(0.01, v)); c.stroke() }
        }
        Text { anchors.centerIn: parent; text: dial.glyph; font.family: p.icons; font.pixelSize: 26; color: p.fg }
        Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 6
               text: Math.round(dial.value * 100) + "%"; font.family: p.mono; font.pixelSize: 9; color: p.grey }
    }
    component Slider: Item {
        property string key
        property string glyph
        property real value: 0
        property color tint
        width: parent.width; height: 26
        Text { anchors.verticalCenter: parent.verticalCenter; text: parent.glyph; font.family: p.icons; font.pixelSize: 18; color: p.fg }
        Rectangle { x: 36; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 36; height: 8; radius: 4; color: "#282828"
                    Rectangle { height: parent.height; radius: 4; color: tint; width: parent.width * Math.max(0, Math.min(1, value)) } }
        Rectangle { anchors.fill: parent; anchors.margins: -6; radius: 6; color: "transparent"; border.color: p.fg; border.width: 1.5; visible: keys.isSel(parent.key) }
    }

    Column {
        id: col
        x: 25; y: 25; width: parent.width - 50; spacing: 20
        Item { width: parent.width; height: 116
               Text { anchors.horizontalCenter: parent.horizontalCenter; y: 0; text: Qt.formatDateTime(p.sys?.now ?? new Date(), "hh:mm")
                      font.family: p.mono; font.weight: Font.Light; font.pixelSize: 66; font.letterSpacing: 4; color: "#d8c3a0" }
               Text { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; text: "Don't believe everything you hear or anything you say."
                      font.family: p.mono; font.pixelSize: 10; color: p.grey } }
        Rectangle {
            width: parent.width; height: sliders.implicitHeight + 40; radius: 6; color: p.card
            Column { id: sliders; x: 20; y: 20; width: parent.width - 40; spacing: 22
                     Slider { key: "volume"; glyph: (p.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}"; value: p.sys?.volume ?? 0; tint: "#a9b665" }
                     Slider { key: "brightness"; glyph: "\u{F00DF}"; value: p.brightness; tint: "#d3869b"; visible: p.brightness >= 0 } }
        }
        Row { spacing: 20
              Dial { value: p.sys?.cpu ?? 0; tint: "#d8a657"; glyph: "\u{F061A}" }
              Dial { value: p.sys?.ram ?? 0; tint: "#ea6962"; glyph: "\u{F035B}" } }
        Rectangle {
            width: parent.width; height: 84; radius: 6; color: p.card
            Row { anchors.centerIn: parent; spacing: 16
                  Repeater { model: p.buttons
                             Rectangle { required property var modelData
                                         width: 52; height: 48; radius: 10; color: modelData.on ? p.aqua : "#3f3f3f"
                                         Text { anchors.centerIn: parent; text: modelData.glyph; font.family: p.icons; font.pixelSize: 22
                                                color: modelData.on ? p.card : p.fg }
                                         Ring { key: modelData.id } } } }
        }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "↑↓ row · ←→ slide/move · ⏎ toggle · esc"
               font.family: p.mono; font.pixelSize: 9; color: p.grey }
    }
}
