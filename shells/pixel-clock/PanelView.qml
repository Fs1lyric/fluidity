// Super+F1: a btop-style dashboard (his desktop is btop + the clock + pipes): boxed sections with titles in the
// border, the kanso-zen colours, the CPU meter, the mem/disk/net bars, then toggles and launchers.
// Keyboard-only through KeyNav: arrows/hjkl, Enter, Left/Right on volume and brightness, Esc.
import QtQuick

Rectangle {
    id: p
    property var sys
    property real brightness: -1
    property bool night: false
    property bool showSelection: false
    signal act(string what, var arg)
    signal close()
    readonly property color fg: "#c5c9c7"
    readonly property color line: "#393b44"
    readonly property color gray: "#717c7c"
    readonly property color blue: "#7fb4ca"
    readonly property color yellow: "#dca561"
    readonly property color green: "#98bb6c"
    readonly property color red: "#e46876"
    readonly property string mono: "JetBrains Mono"
    readonly property string icons: "Iosevka Nerd Font"
    implicitWidth: 560; implicitHeight: col.implicitHeight + 32
    color: "#f2090e13"; border.color: p.line; border.width: 1
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()

    function human(b) { return b > 1048576 ? (b / 1048576).toFixed(1) + " MiB/s" : b > 1024 ? (b / 1024).toFixed(0) + " KiB/s" : Math.round(b) + " Byte/s" }
    readonly property var toggles: [["wifi", "wifi", sys?.wifiOn ?? false], ["bt", "bt", sys?.btOn ?? false], ["mute", "mute", sys?.muted ?? false],
                                    ["mic", "mic off", sys?.micMuted ?? false], ["night", "night", p.night], ["caffeine", "awake", sys?.caffeine ?? false]]
    readonly property var apps: [["btop", "btop"], ["terminal", "term"], ["launcher", "run"], ["lock", "lock"], ["power", "power"]]

    KeyNav {
        id: keys
        focus: true
        always: p.showSelection
        rows: [["volume"]].concat(p.brightness >= 0 ? [["brightness"]] : []).concat([p.toggles.map(t => t[0]), p.apps.map(a => a[0])])
        sliders: ["volume", "brightness"]
        onPress: id => {
            if (id === "night") { p.night = !p.night; p.act("night", p.night) }
            else if (id === "volume") p.act("mute", null)
            else if (id === "btop") p.act("exec", ["sh", "-c", "ghostty -e btop || kitty btop || foot btop"])
            else if (id !== "brightness") p.act(id, null)
            if (["btop", "terminal", "launcher", "lock", "power"].indexOf(id) >= 0) p.close()
        }
        onNudge: (id, d) => id === "volume" ? p.act("volumeStep", d * 0.05) : p.act("brightness", Math.max(0.05, Math.min(1, p.brightness + d * 0.05)))
        onClose: p.close()
    }

    // a btop box: thin border, "¹title" cut into the top line
    component Box: Rectangle {
        default property alias content: inner.data
        property string title
        property string num
        width: col.width; height: inner.childrenRect.height + 26; color: "transparent"; border.color: p.line; border.width: 1; radius: 4
        Rectangle { x: 10; y: -8; width: tt.implicitWidth + 10; height: 16; color: "#090e13"
                    Text { id: tt; anchors.centerIn: parent; textFormat: Text.RichText; font.family: p.mono; font.pixelSize: 12; font.bold: true; color: p.fg
                           text: "<sup>" + parent.parent.num + "</sup>" + parent.parent.title } }
        Item { id: inner; x: 12; y: 14; width: parent.width - 24 }
    }
    component Meter: Item {
        property string label
        property real value
        property color tint
        property string rhs
        width: parent?.width ?? 0; height: 18
        Text { text: parent.label; font.family: p.mono; font.pixelSize: 12; color: p.fg; anchors.verticalCenter: parent.verticalCenter }
        Rectangle { x: 90; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 170; height: 6; color: "#1d2128"
                    Rectangle { height: 6; color: tint; width: parent.width * Math.max(0, Math.min(1, value)) } }
        Text { anchors.right: parent.right; text: parent.rhs; font.family: p.mono; font.pixelSize: 12; color: p.fg; anchors.verticalCenter: parent.verticalCenter }
    }
    component Sel: Rectangle { property string key; anchors.fill: parent; anchors.margins: -3; color: "transparent"; radius: 3
                               border.color: p.yellow; border.width: 2; visible: keys.isSel(key) }

    Column {
        id: col
        x: 16; y: 20; width: parent.width - 32; spacing: 18
        Box { num: "1"; title: "cpu"
              Column { width: parent.width; spacing: 6
                       Meter { label: "CPU"; value: p.sys?.cpu ?? 0; tint: p.green; rhs: Math.round((p.sys?.cpu ?? 0) * 100) + "%  " + Math.round(p.sys?.temp ?? 0) + "°C" }
                       Text { text: "up " + (p.sys?.uptime ?? ""); font.family: p.mono; font.pixelSize: 11; color: p.gray } } }
        Box { num: "2"; title: "mem"
              Column { width: parent.width; spacing: 6
                       Meter { label: "Used:"; value: p.sys?.ram ?? 0; tint: p.yellow; rhs: (p.sys?.ramUsed ?? 0).toFixed(1) + " GiB" }
                       Meter { label: "Free:"; value: 1 - (p.sys?.ram ?? 0); tint: p.blue; rhs: ((p.sys?.ramTotal ?? 0) - (p.sys?.ramUsed ?? 0)).toFixed(1) + " GiB" }
                       Meter { label: "Disk:"; value: p.sys?.diskUsed ?? 0; tint: p.red; rhs: (p.sys?.diskFree ?? "") + " free" } } }
        Box { num: "3"; title: "net"
              Row { spacing: 30
                    Text { text: "▼ " + p.human(p.sys?.netDown ?? 0); font.family: p.mono; font.pixelSize: 12; color: p.fg }
                    Text { text: "▲ " + p.human(p.sys?.netUp ?? 0); font.family: p.mono; font.pixelSize: 12; color: p.fg }
                    Text { text: p.sys?.wired ? "wired" : (p.sys?.ssid || "offline"); font.family: p.mono; font.pixelSize: 12; color: p.gray } } }
        Box { num: "4"; title: "controls"
              Column { width: parent.width; spacing: 12
                       Item { width: parent.width; height: 18
                              Meter { width: parent.width; label: "Volume"; value: p.sys?.volume ?? 0; tint: p.green; rhs: Math.round((p.sys?.volume ?? 0) * 100) + "%" }
                              Sel { key: "volume" } }
                       Item { width: parent.width; height: 18; visible: p.brightness >= 0
                              Meter { width: parent.width; label: "Bright"; value: p.brightness; tint: p.yellow; rhs: Math.round(p.brightness * 100) + "%" }
                              Sel { key: "brightness" } }
                       Row { spacing: 8
                             Repeater { model: p.toggles
                                        Rectangle { required property var modelData; width: (col.width - 24 - 40) / 6; height: 26; radius: 3
                                                    color: modelData[2] ? p.green : "#1d2128"
                                                    Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.mono; font.bold: true; font.pixelSize: 11
                                                           color: modelData[2] ? "#090e13" : p.fg }
                                                    Sel { key: modelData[0] } } } }
                       Row { spacing: 8
                             Repeater { model: p.apps
                                        Rectangle { required property var modelData; width: (col.width - 24 - 32) / 5; height: 26; radius: 3; color: "#1d2128"
                                                    Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.mono; font.bold: true; font.pixelSize: 11
                                                           color: modelData[0] === "power" ? p.red : p.blue }
                                                    Sel { key: modelData[0] } } } } } }
        Text { text: "↑ select ↓ · ← → adjust · ⏎ toggle · esc quit"; font.family: p.mono; font.pixelSize: 10; color: p.gray }
    }
}
