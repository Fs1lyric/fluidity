// Super+F1: an ncmpcpp-shaped window with a cyan edge: the "Music visualizer" header with Volume on the right,
// the controls as a list (the selected row is the purple ncmpcpp cursor), the green "====>" progress line,
// "Playing: …" and the time, and his cava strip in cyan/violet/yellow. j/k or arrows move, Enter presses,
// h/l or Left/Right change volume on its row, Esc closes.
import QtQuick

Rectangle {
    id: p
    property var sys
    property var levels: []
    property bool night: false
    property bool showSelection: false
    signal act(string what, var arg)
    signal close()
    readonly property color fg: "#9b9cc7"
    readonly property color hi: "#cfd0ff"
    readonly property string mono: "Fira Code"
    implicitWidth: 760; implicitHeight: 560
    color: "#f2181530"; border.color: "#00ffff"; border.width: 1
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()

    function clock(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }
    readonly property var items: [
        { id: "play", label: (sys?.playing ?? false) ? "Pause" : "Play", state: sys?.hasPlayer ? (sys.playing ? "playing" : "paused") : "no player" },
        { id: "next", label: "Next track", state: "" }, { id: "prev", label: "Previous track", state: "" },
        { id: "volume", label: "Volume", state: Math.round((sys?.volume ?? 0) * 100) + "%  [h/l]" },
        { id: "mute", label: "Mute", state: (sys?.muted ?? false) ? "on" : "off" },
        { id: "wifi", label: "Wi-Fi", state: (sys?.wifiOn ?? false) ? "on" : "off" },
        { id: "bt", label: "Bluetooth", state: (sys?.btOn ?? false) ? "on" : "off" },
        { id: "night", label: "Night light", state: p.night ? "on" : "off" },
        { id: "caffeine", label: "Stay awake", state: (sys?.caffeine ?? false) ? "on" : "off" },
        { id: "splash", label: "Welcome back", state: "" },
        { id: "terminal", label: "Terminal", state: "" }, { id: "launcher", label: "Launcher", state: "" },
        { id: "power", label: "Power…", state: "" }]
    signal splash()

    KeyNav {
        id: keys
        focus: true
        always: p.showSelection
        rows: p.items.map(i => [i.id])
        sliders: ["volume"]
        onPress: id => {
            if (id === "night") { p.night = !p.night; p.act("night", p.night) }
            else if (id === "volume") p.act("mute", null)
            else if (id === "splash") p.splash()
            else p.act(id, null)
            if (["terminal", "launcher", "power", "splash"].indexOf(id) >= 0) p.close()
        }
        onNudge: (id, d) => p.act("volumeStep", d * 0.05)
        onClose: p.close()
    }

    Column {
        x: 26; y: 24; width: parent.width - 52; spacing: 6
        Item { width: parent.width; height: 20
               Text { text: "Music visualizer"; font.family: p.mono; font.bold: true; font.pixelSize: 14; color: p.hi }
               Text { anchors.right: parent.right; text: "Volume: " + Math.round((p.sys?.volume ?? 0) * 100) + "%"; font.family: p.mono; font.pixelSize: 14; color: p.hi } }
        Rectangle { width: parent.width; height: 2; color: p.hi }
        Repeater {
            model: p.items
            Rectangle { required property var modelData
                        readonly property bool sel: keys.isSel(modelData.id)
                        width: parent.width; height: 22; color: sel ? "#571968" : "transparent"
                        Text { x: 6; anchors.verticalCenter: parent.verticalCenter; text: modelData.label; font.family: p.mono; font.pixelSize: 13
                               color: parent.sel ? p.hi : p.fg }
                        Text { anchors.right: parent.right; anchors.rightMargin: 6; anchors.verticalCenter: parent.verticalCenter
                               text: modelData.state; font.family: p.mono; font.pixelSize: 13; color: modelData.state === "on" ? "#00ffff" : "#6f32ba" } }
        }
        Item { width: 1; height: 4 }
        // the cava strip, mirrored like his (cyan over violet, yellow edge)
        Row {
            height: 70; spacing: 0
            Repeater { model: p.levels.length
                       Item { required property int index; width: (p.width - 52) / Math.max(1, p.levels.length); height: 70
                              readonly property real v: Math.max(0.04, p.levels[index] ?? 0)
                              Rectangle { anchors.centerIn: parent; width: parent.width; height: 70 * parent.v + 8; color: "#7fe7ff" }
                              Rectangle { anchors.centerIn: parent; width: parent.width; height: 70 * parent.v; color: "#c08cf0" }
                              Rectangle { anchors.horizontalCenter: parent.horizontalCenter; y: 35 + 35 * parent.v; width: parent.width; height: 3; color: "#f0e68c" } } }
        }
        Text { width: parent.width; elide: Text.ElideRight; font.family: p.mono; font.pixelSize: 13; color: "#4dff8a"
               text: "=".repeat(Math.round(50 * Math.min(1, (p.sys?.position ?? 0) / Math.max(1, p.sys?.length ?? 1)))) + ">" }
        Item { width: parent.width; height: 18
               Text { width: parent.width - 110; elide: Text.ElideRight; font.family: p.mono; font.pixelSize: 13; color: p.hi; textFormat: Text.RichText
                      text: "<b>Playing:</b> " + (p.sys?.artist ? p.sys.artist + " \"" : "\"") + (p.sys?.track || "—") + "\"" }
               Text { anchors.right: parent.right; font.family: p.mono; font.bold: true; font.pixelSize: 13; color: p.hi
                      text: "[" + p.clock(p.sys?.position ?? 0) + "/" + p.clock(p.sys?.length ?? 0) + "]" } }
    }
}
