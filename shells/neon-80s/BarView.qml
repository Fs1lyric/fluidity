// His polybar: black, 22 px, Inconsolata-style mono; each module has its own neon colour, split by grey bars.
import QtQuick

Rectangle {
    id: b
    property var sys
    signal act(string what, var arg)
    implicitHeight: 22
    color: "#05050a"
    readonly property string mono: "JetBrainsMono Nerd Font"
    function gb(x) { return (x / 1073741824).toFixed(1) + "G" }
    function rate(x) { return x > 1048576 ? (x / 1048576).toFixed(1) + "M" : Math.round(x / 1024) + "K" }
    Row {
        x: 6; height: parent.height; spacing: 2
        Repeater {
            model: (b.sys?.tags ?? []).filter(t => t.count > 0 || t.state === "focused")
            Text { required property var modelData; width: 18; height: b.height; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                   text: modelData.id; font.family: b.mono; font.pixelSize: 13
                   color: modelData.state === "focused" ? "#ffffff" : modelData.state === "urgent" ? "#ff2a6d" : "#6b6f80"
                   MouseArea { anchors.fill: parent; onClicked: b.act("ws", parent.modelData.id) } }
        }
    }
    Row {
        anchors.right: parent.right; anchors.rightMargin: 6; height: parent.height; spacing: 8
        Repeater {
            model: [
                ["󰍛 " + (b.sys?.ramUsed ?? 0).toFixed(1) + "G", "#e8e8f0", ""],
                ["󰘚 " + (b.sys?.ramTotal ?? 0).toFixed(1) + "G", "#8fa8c8", "|"],
                ["󰋊 " + (b.sys?.diskFree ?? ""), "#ff4d6d", ""],
                ["# " + Math.round((b.sys?.diskUsed ?? 0) * 100) + "%", "#f9f871", "|"],
                ["󰔏 " + (b.sys?.temp ?? 0).toFixed(1) + "°C", "#e8e8f0", "|"],
                ["󰖩 " + (b.sys?.online ? (b.sys.wired ? "wired" : b.sys.ssid) : "offline"), "#b6f23a", "|"],
                ["󰛳 IN " + b.rate(b.sys?.netDown ?? 0) + " OUT " + b.rate(b.sys?.netUp ?? 0), "#2de2e6", "|"],
                ["󰃭 " + Qt.formatDateTime(b.sys?.now ?? new Date(), "dd/MM/yyyy HH:mm"), "#ffffff", ""]
            ]
            Row {
                required property var modelData
                height: b.height; spacing: 8
                Text { height: b.height; verticalAlignment: Text.AlignVCenter; text: parent.modelData[0]; color: parent.modelData[1]; font.family: b.mono; font.pixelSize: 13 }
                Text { visible: parent.modelData[2] !== ""; height: b.height; verticalAlignment: Text.AlignVCenter; text: "|"; color: "#4a4e60"; font.family: b.mono; font.pixelSize: 13 }
            }
        }
    }
    MouseArea { anchors.fill: parent; z: -1; acceptedButtons: Qt.RightButton; onClicked: b.act("power", null) }
}
