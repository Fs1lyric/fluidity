// Super+F1: the SDDM login form turned into a session panel, in the same colours: the user line with its tan
// icon, a dropdown-style list (selected row = #4d1927 highlight) of toggles and session actions, and the
// tan "Login"-shaped button that runs the selected row, with the system buttons under it.
// Keyboard-only through KeyNav: arrows/hjkl, Enter, Left/Right on volume, Esc.
import QtQuick

Rectangle {
    id: p
    property var sys
    property bool showSelection: false
    signal act(string what, var arg)
    signal close()
    readonly property color tan: "#685841"
    readonly property color light: "#bfb098"
    readonly property color field: "#33151f"
    readonly property color hi: "#4d1927"
    readonly property string sans: "Open Sans"
    readonly property string icons: "Iosevka Nerd Font"
    implicitWidth: 400; implicitHeight: col.implicitHeight + 40
    radius: 6; color: "#ee1d0b12"
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()

    readonly property var items: [
        { id: "volume", glyph: (sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}", label: "Volume  " + Math.round((sys?.volume ?? 0) * 100) + "%  ←→" },
        { id: "wifi", glyph: "\u{F05A9}", label: "Wi-Fi  " + ((sys?.wifiOn ?? false) ? "on" : "off") },
        { id: "bt", glyph: "\u{F00AF}", label: "Bluetooth  " + ((sys?.btOn ?? false) ? "on" : "off") },
        { id: "mic", glyph: "\u{F036D}", label: "Microphone  " + ((sys?.micMuted ?? false) ? "muted" : "live") },
        { id: "caffeine", glyph: "\u{F0176}", label: "Stay awake  " + ((sys?.caffeine ?? false) ? "on" : "off") },
        { id: "terminal", glyph: "\u{F018D}", label: "Terminal" }, { id: "launcher", glyph: "\u{F003B}", label: "Launcher" }]
    readonly property var system: [["lock", "\u{F033E}"], ["suspend", "\u{F04B2}"], ["reboot", "\u{F0709}"], ["poweroff", "\u{F0425}"]]
    property string picked: "volume"

    function run(id) {
        switch (id) {
        case "volume": p.act("mute", null); break
        case "suspend": p.act("exec", ["systemctl", "suspend"]); break
        case "reboot": p.act("exec", ["systemctl", "reboot"]); break
        case "poweroff": p.act("exec", ["systemctl", "poweroff"]); break
        case "go": p.run(p.picked); return
        default: p.act(id, null)
        }
        if (["terminal", "launcher", "lock", "suspend", "reboot", "poweroff"].indexOf(id) >= 0) p.close()
    }

    KeyNav {
        id: keys
        focus: true
        always: p.showSelection
        rows: p.items.map(i => [i.id]).concat([["go"], p.system.map(s => s[0])])
        sliders: ["volume"]
        onCurrentChanged: if (p.items.some(i => i.id === current)) p.picked = current
        onPress: id => p.run(id)
        onNudge: (id, d) => p.act("volumeStep", d * 0.05)
        onClose: p.close()
    }

    Column {
        id: col
        x: 28; y: 22; width: parent.width - 56; spacing: 12
        Item { width: parent.width; height: 30
               Text { anchors.verticalCenter: parent.verticalCenter; text: "\u{F0004}"; font.family: p.icons; font.pixelSize: 16; color: p.tan }
               Text { anchors.centerIn: parent; text: p.sys?.user || "user"; font.family: p.sans; font.weight: Font.DemiBold; font.pixelSize: 15; color: p.tan } }
        Rectangle {
            width: parent.width; height: list.implicitHeight + 8; radius: 4; color: "#32141f"
            Column { id: list; x: 4; y: 4; width: parent.width - 8
                     Repeater { model: p.items
                                Rectangle { required property var modelData; width: parent.width; height: 32; radius: 3
                                            color: keys.isSel(modelData.id) ? p.hi : "transparent"
                                            Text { x: 10; anchors.verticalCenter: parent.verticalCenter; text: modelData.glyph; font.family: p.icons; font.pixelSize: 15; color: p.tan }
                                            Text { x: 40; anchors.verticalCenter: parent.verticalCenter; text: modelData.label; font.family: p.sans; font.pixelSize: 14
                                                   color: keys.isSel(modelData.id) ? p.light : p.tan } } } }
        }
        Rectangle { width: parent.width; height: 40; radius: 4; color: keys.isSel("go") ? "#8f7d5c" : p.tan
                    Text { anchors.centerIn: parent; text: (p.items.find(i => i.id === p.picked)?.label ?? "").split("  ")[0] || "Run"
                           font.family: p.sans; font.weight: Font.DemiBold; font.pixelSize: 15; color: p.light } }
        Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 26
              Repeater { model: p.system
                         Rectangle { required property var modelData; width: 40; height: 36; radius: 6
                                     color: keys.isSel(modelData[0]) ? p.hi : "transparent"
                                     Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.icons; font.pixelSize: 20
                                            color: modelData[0] === "poweroff" ? "#fc2e64" : p.tan } } } }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "↑↓ pick · ⏎ run · ←→ volume · esc"; font.family: p.sans; font.pixelSize: 10; color: "#695841" }
    }
}
