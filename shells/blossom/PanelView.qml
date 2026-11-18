// His swaync control centre (Super+F1): a dark everforest sheet with a green outline. Do Not Disturb switch,
// the eight square quick buttons, the player card, the volume and brightness sliders and the notification
// header with its clear button. Keyboard-only through KeyNav: arrows/hjkl, Enter, Left/Right on sliders, Esc.
import QtQuick

Rectangle {
    id: p
    property var sys
    property real brightness: -1
    property bool dnd: false
    property bool showSelection: false
    signal act(string what, var arg)
    signal close()
    readonly property color card: "#374145"
    readonly property color btn: "#414b50"
    readonly property color fg: "#d3c6aa"
    readonly property color dim: "#859289"
    readonly property color green: "#83c092"
    readonly property string mono: "Geist Mono"
    readonly property string icons: "Iosevka Nerd Font"
    implicitWidth: 420; implicitHeight: col.implicitHeight + 36
    radius: 14; color: "#f2272e33"; border.color: "#83c092"; border.width: 2
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()

    readonly property var quick: [
        { id: "mute", glyph: "\u{F075F}", on: sys?.muted ?? false }, { id: "mic", glyph: "\u{F036D}", on: sys?.micMuted ?? false },
        { id: "wifi", glyph: "\u{F05A9}", on: sys?.wifiOn ?? false }, { id: "bt", glyph: "\u{F00AF}", on: sys?.btOn ?? false },
        { id: "airplane", glyph: "\u{F001D}", on: !(sys?.wifiOn ?? true) && !(sys?.btOn ?? true) }, { id: "power", glyph: "\u{F0425}", on: false },
        { id: "lock", glyph: "\u{F033E}", on: false }, { id: "logout", glyph: "\u{F0343}", on: false }]

    function press(id) {
        switch (id) {
        case "dnd": p.dnd = !p.dnd; p.act("dnd", null); break
        case "airplane": { const off = !(p.sys?.wifiOn ?? true) && !(p.sys?.btOn ?? true)
                           if ((p.sys?.wifiOn ?? false) !== off) p.act("wifi", null)
                           if ((p.sys?.btOn ?? false) !== off) p.act("bt", null); break }
        case "logout": p.act("exec", ["hyprctl", "dispatch", "exit"]); break
        case "volume": p.act("mute", null); break
        case "brightness": break
        case "clear": p.act("clearNotifs", null); break
        default: p.act(id, null)
        }
        if (["power", "lock", "logout"].indexOf(id) >= 0) p.close()
    }

    KeyNav {
        id: keys
        focus: true
        always: p.showSelection
        rows: [["dnd"], p.quick.slice(0, 4).map(q => q.id), p.quick.slice(4).map(q => q.id), ["prev", "play", "next"], ["volume"]]
              .concat(p.brightness >= 0 ? [["brightness"]] : []).concat([["clear"]])
        sliders: ["volume", "brightness"]
        onPress: id => p.press(id)
        onNudge: (id, d) => id === "volume" ? p.act("volumeStep", d * 0.05) : p.act("brightness", Math.max(0.05, Math.min(1, p.brightness + d * 0.05)))
        onClose: p.close()
    }

    component Sel: Rectangle {
        property string key
        anchors.fill: parent; anchors.margins: -3; radius: parent.radius + 3; color: "transparent"
        border.color: p.green; border.width: 2; visible: keys.isSel(key)
    }
    component Slide: Rectangle {
        id: sl
        property string key
        property string glyph
        property real value
        width: col.width; height: 40; radius: 12; color: p.card
        Text { x: 14; anchors.verticalCenter: parent.verticalCenter; text: sl.glyph; font.family: p.icons; font.pixelSize: 18; color: p.fg }
        Rectangle { x: 46; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 66; height: 4; radius: 2; color: "#4f585e"
                    Rectangle { height: 4; radius: 2; color: p.green; width: parent.width * Math.max(0, Math.min(1, sl.value)) }
                    Rectangle { x: parent.width * Math.max(0, Math.min(1, sl.value)) - 8; anchors.verticalCenter: parent.verticalCenter
                                width: 16; height: 16; radius: 8; color: "#e7dcc4" } }
        Sel { key: sl.key }
    }

    Column {
        id: col
        x: 18; y: 18; width: parent.width - 36; spacing: 14
        Item { width: parent.width; height: 30
               Text { anchors.verticalCenter: parent.verticalCenter; text: "Do Not Disturb"; font.family: p.mono; font.italic: true; font.pixelSize: 15; color: p.fg }
               Rectangle { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; width: 40; height: 24; radius: 6; color: p.dnd ? p.green : p.btn
                           Rectangle { x: p.dnd ? 20 : 4; anchors.verticalCenter: parent.verticalCenter; width: 16; height: 16; radius: 8; color: "#272e33" }
                           Sel { key: "dnd" } } }
        Rectangle {
            width: parent.width; height: grid.implicitHeight + 24; radius: 12; color: p.card
            Grid { id: grid; anchors.centerIn: parent; columns: 4; spacing: 16
                   Repeater { model: p.quick
                              Rectangle { required property var modelData; width: 56; height: 40; radius: 10
                                          color: modelData.on ? p.green : p.btn
                                          Text { anchors.centerIn: parent; text: modelData.glyph; font.family: p.icons; font.pixelSize: 18
                                                 color: modelData.on ? "#272e33" : p.fg }
                                          Sel { key: modelData.id } } } }
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter; width: 220; height: 92; radius: 10; color: "#1e2326"; clip: true
            Image { anchors.fill: parent; source: p.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop; opacity: 0.35 }
            Rectangle { x: 12; y: 12; width: 40; height: 40; radius: 6; color: p.btn; clip: true
                        Image { anchors.fill: parent; source: p.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop } }
            Column { x: 62; y: 12; width: parent.width - 72
                     Text { width: parent.width; elide: Text.ElideRight; text: p.sys?.track || "Nothing playing"; font.family: p.mono; font.italic: true; font.pixelSize: 14; color: p.fg }
                     Text { width: parent.width; elide: Text.ElideRight; text: p.sys?.artist ?? ""; font.family: p.mono; font.italic: true; font.pixelSize: 12; color: p.dim } }
            Row { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 8; spacing: 22
                  Repeater { model: [["prev", "\u{F04AE}"], ["play", (p.sys?.playing ?? false) ? "\u{F03E4}" : "\u{F040A}"], ["next", "\u{F04AD}"]]
                             Item { required property var modelData; width: 22; height: 20
                                    property int radius: 6
                                    Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.icons; font.pixelSize: 14; color: p.fg }
                                    Sel { key: modelData[0] } } } }
        }
        Slide { key: "volume"; glyph: (p.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}"; value: p.sys?.volume ?? 0 }
        Slide { key: "brightness"; glyph: "\u{F00DF}"; value: p.brightness; visible: p.brightness >= 0 }
        Item { width: parent.width; height: 30
               Text { anchors.verticalCenter: parent.verticalCenter; text: "Notifications"; font.family: p.mono; font.italic: true; font.pixelSize: 17; color: p.fg }
               Rectangle { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; width: 40; height: 24; radius: 6; color: p.btn
                           Text { anchors.centerIn: parent; text: "\u{F01B4}"; font.family: p.icons; font.pixelSize: 14; color: p.fg }
                           Sel { key: "clear" } } }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "arrows/hjkl move · ⏎ press · ←→ sliders · esc"
               font.family: p.mono; font.pixelSize: 9; color: p.dim }
    }
}
