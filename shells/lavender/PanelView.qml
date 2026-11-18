// Super+F1: his Spotify poster card grown into the control panel: cream card, the cover on top, the colour strip,
// the title in big condensed capitals with the time, artist, controls, then a volume bar and the quick toggles
// as lavender pills. Keyboard-only through KeyNav: arrows/hjkl, Enter, Left/Right on volume, Esc.
import QtQuick

Rectangle {
    id: p
    property var sys
    property bool night: false
    property bool showSelection: false
    signal act(string what, var arg)
    signal close()
    readonly property color ink: "#2b2735"
    readonly property color pill: "#9988cb"
    readonly property string sans: "Inter"
    readonly property string icons: "Iosevka Nerd Font"
    implicitWidth: 340; implicitHeight: col.implicitHeight + 28
    radius: 10; color: "#d4c9b6"; border.color: "#c6c1f4"; border.width: 3
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()

    function clock(s) { s = Math.max(0, Math.floor(s)); return String(Math.floor(s / 60)).padStart(2, "0") + ":" + String(s % 60).padStart(2, "0") }
    readonly property var toggles: [["wifi", "\u{F05A9}", sys?.wifiOn ?? false], ["bt", "\u{F00AF}", sys?.btOn ?? false], ["mic", "\u{F036D}", sys?.micMuted ?? false],
                                    ["night", "\u{F0594}", p.night], ["caffeine", "\u{F0176}", sys?.caffeine ?? false]]
    readonly property var apps: [["launcher", "\u{F003B}"], ["terminal", "\u{F018D}"], ["files", "\u{F024B}"], ["lock", "\u{F033E}"], ["power", "\u{F0425}"]]

    KeyNav {
        id: keys
        focus: true
        always: p.showSelection
        rows: [["prev", "play", "next"], ["volume"], p.toggles.map(t => t[0]), p.apps.map(a => a[0])]
        sliders: ["volume"]
        onPress: id => {
            if (id === "night") { p.night = !p.night; p.act("night", p.night) }
            else if (id === "volume") p.act("mute", null)
            else p.act(id, null)
            if (["launcher", "terminal", "files", "lock", "power"].indexOf(id) >= 0) p.close()
        }
        onNudge: (id, d) => p.act("volumeStep", d * 0.05)
        onClose: p.close()
    }
    component Sel: Rectangle { property string key; anchors.fill: parent; anchors.margins: -3; radius: 9; color: "transparent"
                               border.color: p.ink; border.width: 2; visible: keys.isSel(key) }

    Column {
        id: col
        x: 14; y: 14; width: parent.width - 28; spacing: 10
        Rectangle { width: parent.width; height: width * 0.78; color: "#7f9a6e"; clip: true
                    Image { anchors.fill: parent; source: p.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop }
                    Text { anchors.centerIn: parent; visible: !(p.sys?.art); text: "\u{F075A}"; font.family: p.icons; font.pixelSize: 60; color: "#d4c9b6" } }
        Row { spacing: 0
              Repeater { model: ["#3f5a35", "#5d7a4a", "#86a070", "#a9b98c", "#c4c2a8", "#9fa6b5"]
                         Rectangle { required property string modelData; width: col.width / 6; height: 10; color: modelData } } }
        Item { width: parent.width; height: 30
               Text { width: parent.width - 60; elide: Text.ElideRight; text: (p.sys?.track || "Nothing playing").toUpperCase()
                      font.family: p.sans; font.weight: Font.Bold; font.pixelSize: 22; font.letterSpacing: -0.5; color: p.ink }
               Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: p.clock(p.sys?.length ?? 0); font.family: p.sans; font.pixelSize: 12; color: p.ink } }
        Item { width: parent.width; height: 22
               Text { anchors.verticalCenter: parent.verticalCenter; text: p.sys?.artist ?? ""; font.family: p.sans; font.pixelSize: 14; color: p.ink }
               Row { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; spacing: 10
                     Repeater { model: [["prev", "\u{F04AE}"], ["play", (p.sys?.playing ?? false) ? "\u{F03E4}" : "\u{F040A}"], ["next", "\u{F04AD}"]]
                                Item { required property var modelData; width: 20; height: 20
                                       Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.icons; font.pixelSize: 15; color: p.ink }
                                       Sel { key: modelData[0] } } } } }
        Item { width: parent.width; height: 18
               Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 4; radius: 2; color: "#b9ad97"
                           Rectangle { height: 4; radius: 2; color: p.ink; width: parent.width * Math.min(1, p.sys?.volume ?? 0) } }
               Sel { key: "volume" } }
        Row { spacing: 8
              Repeater { model: p.toggles
                         Rectangle { required property var modelData; width: (col.width - 32) / 5; height: 30; radius: 7
                                     color: modelData[2] ? p.pill : "#c2b8a3"
                                     Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.icons; font.pixelSize: 15; color: modelData[2] ? "#faf2f2" : p.ink }
                                     Sel { key: modelData[0] } } } }
        Row { spacing: 8
              Repeater { model: p.apps
                         Rectangle { required property var modelData; width: (col.width - 32) / 5; height: 30; radius: 7; color: "#c2b8a3"
                                     Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.icons; font.pixelSize: 15; color: modelData[0] === "power" ? "#a8506a" : p.ink }
                                     Sel { key: modelData[0] } } } }
        Text { text: "arrows/hjkl · enter · ←→ volume · esc"; font.family: p.sans; font.pixelSize: 9; color: "#6f6656" }
    }
}
