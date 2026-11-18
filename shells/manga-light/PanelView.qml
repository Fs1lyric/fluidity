// Super+F1: a panel in the shape of his cmus window: a cream terminal card, a red-outlined list on the left
// (the controls) and the status lines at the bottom (track, volume bar, time). The selected row is the orange
// cmus cursor; j/k or arrows move it, Enter presses, h/l or Left/Right change volume on its row, Esc closes.
import QtQuick

Rectangle {
    id: p
    property var sys
    property bool night: false
    property bool showSelection: false
    signal act(string what, var arg)
    signal close()
    readonly property color ink: "#3c3836"
    readonly property color teal: "#076678"
    readonly property color red: "#cc241d"
    readonly property color orange: "#d79921"
    readonly property color green: "#79740e"
    readonly property string mono: "JetBrains Mono"
    implicitWidth: 520; implicitHeight: 470
    radius: 10; color: "#fbf1c7"; border.color: p.ink; border.width: 3
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()

    function clock(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0") }
    readonly property var items: [
        { id: "play", label: (sys?.playing ?? false) ? "pause" : "play", state: sys?.hasPlayer ? (sys.playing ? "playing" : "paused") : "no player" },
        { id: "next", label: "next track", state: "" }, { id: "prev", label: "previous track", state: "" },
        { id: "volume", label: "volume", state: Math.round((sys?.volume ?? 0) * 100) + "%  ←→" },
        { id: "mute", label: "mute", state: (sys?.muted ?? false) ? "on" : "off" },
        { id: "mic", label: "mic mute", state: (sys?.micMuted ?? false) ? "on" : "off" },
        { id: "wifi", label: "wi-fi", state: (sys?.wifiOn ?? false) ? "on" : "off" },
        { id: "bt", label: "bluetooth", state: (sys?.btOn ?? false) ? "on" : "off" },
        { id: "night", label: "night light", state: p.night ? "on" : "off" },
        { id: "caffeine", label: "stay awake", state: (sys?.caffeine ?? false) ? "on" : "off" },
        { id: "terminal", label: "terminal", state: "" }, { id: "launcher", label: "launcher", state: "" },
        { id: "lock", label: "lock", state: "" }, { id: "power", label: "power…", state: "" }]

    KeyNav {
        id: keys
        focus: true
        always: p.showSelection
        rows: p.items.map(i => [i.id])
        sliders: ["volume"]
        onPress: id => {
            if (id === "night") { p.night = !p.night; p.act("night", p.night) }
            else if (id === "volume") p.act("mute", null)
            else p.act(id, null)
            if (["terminal", "launcher", "lock", "power"].indexOf(id) >= 0) p.close()
        }
        onNudge: (id, d) => p.act("volumeStep", d * 0.05)
        onClose: p.close()
    }

    // the left box: red outline with "controls" cut into it, like cmus' artists pane
    Rectangle {
        x: 14; y: 20; width: parent.width - 28; height: 330; color: "transparent"; border.color: p.red; border.width: 2
        Rectangle { x: 12; y: -9; width: hd.implicitWidth + 8; height: 16; color: "#fbf1c7"
                    Text { id: hd; anchors.centerIn: parent; text: "controls"; font.family: p.mono; font.pixelSize: 13; color: p.red } }
        Column {
            x: 4; y: 10; width: parent.width - 8
            Repeater {
                model: p.items
                Rectangle { required property var modelData
                            readonly property bool sel: keys.isSel(modelData.id)
                            width: parent.width; height: 22; color: sel ? p.orange : "transparent"
                            Text { x: 6; anchors.verticalCenter: parent.verticalCenter; text: modelData.label; font.family: p.mono; font.pixelSize: 13; color: p.ink }
                            Text { anchors.right: parent.right; anchors.rightMargin: 6; anchors.verticalCenter: parent.verticalCenter
                                   text: modelData.state; font.family: p.mono; font.pixelSize: 13
                                   color: modelData.state === "on" ? p.green : p.sel ? p.ink : p.teal } }
            }
        }
    }

    Column {
        x: 14; y: 366; width: parent.width - 28; spacing: 4
        Text { width: parent.width; elide: Text.ElideRight; font.family: p.mono; font.pixelSize: 13; color: p.ink; textFormat: Text.RichText
               text: ((p.sys?.playing ?? false) ? "playing " : "paused ") + "<span style='color:#076678'>" + (p.sys?.track || "—") + "</span> by <span style='color:#076678'>" + (p.sys?.artist || "—") + "</span>" }
        Item { width: parent.width; height: 18
               Text { text: "vol"; font.family: p.mono; font.pixelSize: 13; color: p.ink; anchors.verticalCenter: parent.verticalCenter }
               Rectangle { x: 40; anchors.verticalCenter: parent.verticalCenter; width: 140; height: 2; color: p.ink
                           Rectangle { x: parent.width * Math.min(1, p.sys?.volume ?? 0) - 4; anchors.verticalCenter: parent.verticalCenter; width: 8; height: 12; color: p.ink } }
               Text { x: 196; text: Math.round((p.sys?.volume ?? 0) * 100) + "%  " + p.clock(p.sys?.position ?? 0) + " / " + p.clock(p.sys?.length ?? 0)
                      font.family: p.mono; font.pixelSize: 13; color: p.ink; anchors.verticalCenter: parent.verticalCenter } }
        Row { spacing: 10; topPadding: 10
              Repeater { model: [["j/k", "move"], ["⏎", "press"], ["h/l", "volume"], ["esc", "close"]]
                         Row { required property var modelData; spacing: 6
                               Rectangle { width: kk.implicitWidth + 10; height: 18; color: p.ink
                                           Text { id: kk; anchors.centerIn: parent; text: modelData[0]; font.family: p.mono; font.pixelSize: 12; color: "#fbf1c7" } }
                               Text { text: modelData[1]; font.family: p.mono; font.pixelSize: 12; color: "#7c6f64"; anchors.verticalCenter: parent.verticalCenter } } } }
    }
}
