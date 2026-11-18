// dwm's bar as on the T420 post: black, monospace, one line.
//   tags 1-9 (occupied ones get dwm's little square, the viewed one is inverted), the layout symbol, the focused
//   window's title on the green "selected" colour, and a dwmblocks-style status with emoji on the right.
import QtQuick

Rectangle {
    id: b
    property var sys
    property string layout: "[]="
    signal act(string what, var arg)
    implicitHeight: 22
    color: "#0b0809"
    readonly property color norm: "#bbbbbb"
    readonly property color sel: "#7fc98f"
    readonly property color selFg: "#0b0809"
    readonly property string font: "DejaVu Sans Mono"
    readonly property int px: 13
    function rate(x) { return x > 1048576 ? (x / 1048576).toFixed(1) + "M" : Math.round(x / 1024) + "K" }

    Row {
        id: left
        height: parent.height
        Repeater {
            model: (b.sys?.tags ?? []).slice(0, 9)
            Rectangle {
                required property var modelData
                readonly property bool on: modelData.state === "focused"
                width: 22; height: b.height
                color: on ? b.sel : "transparent"
                Text { anchors.centerIn: parent; text: parent.modelData.id; font.family: b.font; font.pixelSize: b.px
                       color: parent.on ? b.selFg : parent.modelData.state === "urgent" ? "#ff5555" : b.norm }
                Rectangle { x: 2; y: 2; width: 4; height: 4; visible: parent.modelData.count > 0
                            color: "transparent"; border.color: parent.on ? b.selFg : b.norm; border.width: 1
                            Rectangle { anchors.fill: parent; visible: parent.parent.on; color: b.selFg } }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.act("ws", parent.modelData.id) }
            }
        }
        Text { width: implicitWidth + 16; height: b.height; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
               text: b.layout; font.family: b.font; font.pixelSize: b.px; color: b.norm
               MouseArea { anchors.fill: parent; onClicked: { b.layout = b.layout === "[]=" ? "[M]" : "[]="; b.act("monocle", null) } } }
    }
    Rectangle {
        anchors { left: left.right; right: status.left; top: parent.top; bottom: parent.bottom }
        color: (b.sys?.title ?? "") !== "" ? b.sel : "transparent"
        Text { x: 8; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 16; elide: Text.ElideRight
               text: b.sys?.title ?? ""; font.family: b.font; font.pixelSize: b.px; color: b.selFg }
    }
    Text {
        id: status
        anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
        leftPadding: 8
        font.family: b.font; font.pixelSize: b.px; color: b.norm
        text: [
            "🎵 " + (b.sys?.hasPlayer ? (b.sys.track || "").slice(0, 24) : "-"),
            (b.sys?.muted ? "🔇 " : "🔊 ") + Math.round((b.sys?.volume ?? 0) * 100) + "%",
            (b.sys?.online ? "📶 " + (b.sys?.wired ? "eth" : b.sys?.ssid ?? "") : "❎ offline"),
            "⬇" + b.rate(b.sys?.netDown ?? 0) + " ⬆" + b.rate(b.sys?.netUp ?? 0),
            "🧠 " + (b.sys?.ramUsed ?? 0).toFixed(1) + "G",
            "🌡 " + Math.round(b.sys?.temp ?? 0) + "°C",
            ...(b.sys?.hasBattery ? [(b.sys.charging ? "🔌 " : "🔋 ") + Math.round(b.sys.battery * 100) + "%"] : []),
            Qt.formatDateTime(b.sys?.now ?? new Date(), "yyyy MMM dd (ddd) HH:mm")
        ].join(" | ")
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: m => b.act(m.button === Qt.RightButton ? "power" : "launcher", null)
                    onWheel: w => b.act("volumeStep", w.angleDelta.y > 0 ? 0.05 : -0.05) }
    }
}
