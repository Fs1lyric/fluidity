// Noctalia's bar as jeky runs it on niri: one floating pill with a lavender rim, centred over the screen.
//   left: CPU, memory, temperature, download, upload   centre-right: workspaces 1-10 (current one peach)
//   right: tray (behind a chevron), volume, microphone, brightness, clock, power
import QtQuick

Rectangle {
    id: b
    property var sys
    property var tray: []            // [{ icon, title }]
    property bool trayOpen: false
    property real brightness: 0.25
    signal act(string what, var arg)
    signal trayClicked(int index, bool right)
    implicitHeight: 30
    radius: 6
    color: "#1e1e2e"
    border.color: "#b4befe"; border.width: 2
    readonly property color fg: "#cdd6f4"
    readonly property color dim: "#6c7086"
    readonly property color peach: "#fab387"
    readonly property string font: "JetBrainsMono Nerd Font Propo"
    function g(cp) { return String.fromCodePoint(cp) }
    function bytes(x) { return x >= 1048576 ? (x / 1048576).toFixed(1) + "MB" : x >= 1024 ? (x / 1024).toFixed(1) + "KB" : Math.round(x) + "B" }

    component T: Text { color: b.fg; font.family: b.font; font.pixelSize: 13; anchors.verticalCenter: parent ? parent.verticalCenter : undefined }
    component Stat: Item { id: st; property int glyph; property string value
        width: sr.width; height: 30; anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        Row { id: sr; spacing: 5; anchors.verticalCenter: parent.verticalCenter
              T { text: b.g(st.glyph); font.pixelSize: 14 } T { text: st.value } } }

    Row {
        x: 14; height: parent.height; spacing: 16
        Stat { glyph: 0xf029a; value: Math.round((b.sys?.cpu ?? 0) * 100) + "%" }
        Stat { glyph: 0xf035b; value: (b.sys?.ramUsed ?? 0).toFixed(1) + " GiB" }
        Stat { glyph: 0xf0238; value: Math.round(b.sys?.temp ?? 0) + "°C" }
        Stat { glyph: 0xf01da; value: b.bytes(b.sys?.netDown ?? 0) }
        Stat { glyph: 0xf0552; value: b.bytes(b.sys?.netUp ?? 0) }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter; anchors.horizontalCenterOffset: 40
        height: parent.height; spacing: 12
        Repeater {
            model: b.sys?.tags ?? []
            T { required property var modelData
                text: modelData.id; font.pixelSize: 15
                color: modelData.state === "focused" ? b.peach : modelData.state === "urgent" ? "#f38ba8" : modelData.state === "occupied" ? b.fg : b.dim
                MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: b.act("ws", parent.modelData.id) } }
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 14 } height: parent.height; spacing: 16
        T { text: b.g(b.trayOpen ? 0xf0143 : 0xf0140); font.pixelSize: 15
            MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: b.trayOpen = !b.trayOpen } }
        Row { visible: b.trayOpen || b.tray.length <= 1; spacing: 10; anchors.verticalCenter: parent.verticalCenter
            Repeater { model: b.tray
                Image { required property var modelData; required property int index; width: 16; height: 16; sourceSize: Qt.size(32, 32); source: modelData.icon
                        MouseArea { anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton; onClicked: m => b.trayClicked(parent.index, m.button === Qt.RightButton) } } } }
        Stat { glyph: b.sys?.muted ? 0xf075f : 0xf057e; value: Math.round((b.sys?.volume ?? 0) * 100) + "%"
               MouseArea { anchors.fill: parent; onClicked: b.act("mute", null); onWheel: w => b.act("volumeStep", w.angleDelta.y > 0 ? 0.05 : -0.05) } }
        Stat { glyph: b.sys?.micMuted ? 0xf036d : 0xf036c; value: b.sys?.micMuted ? "0%" : "100%"
               MouseArea { anchors.fill: parent; onClicked: b.act("mic", null) } }
        Stat { glyph: 0xf00e0; value: Math.round(b.brightness * 100) + "%"
               MouseArea { anchors.fill: parent; onWheel: w => { b.brightness = Math.max(0.05, Math.min(1, b.brightness + (w.angleDelta.y > 0 ? 0.05 : -0.05))); b.act("brightness", b.brightness) } } }
        T { text: Qt.formatDateTime(b.sys?.now ?? new Date(), "HH:mm") }
        T { text: b.g(0xf0425); font.pixelSize: 15
            MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: b.act("power", null) } }
    }
}
