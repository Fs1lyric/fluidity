// csarr's DankMaterialShell bar (dms/settings.json, amoledBlack, square corners, no outline):
//   left: power, workspaces, actions, focused window, clipboard   centre: music
//   right: pomodoro, notifications, battery, control centre (wifi, bluetooth, volume), clock (24 h)
import QtQuick

Rectangle {
    id: bar
    property var sys
    property int pomodoro: 50 * 60      // seconds left (DMS pomodoro default for him: 50 min)
    property bool pomodoroRunning: false
    signal act(string what, var arg)
    signal controlCenter()
    implicitHeight: 30
    color: "#000000"
    readonly property color ink: "#e9e4d4"
    readonly property color faint: "#8a867b"
    readonly property string font: "iMWritingQuat Nerd Font Propo"
    function g(cp) { return String.fromCodePoint(cp) }
    function mmss(t) { return Math.floor(t / 60) + " " + String(t % 60).padStart(2, "0") }

    component Glyph: Text {
        property var onTap: null
        color: bar.ink; font.family: bar.font; font.pixelSize: 14
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        MouseArea { anchors.fill: parent; anchors.margins: -4; enabled: parent.onTap !== null
                    cursorShape: Qt.PointingHandCursor; onClicked: parent.onTap() }
    }
    component Label: Text {
        color: bar.ink; font.family: bar.font; font.pixelSize: 12
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    }

    Row {
        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
        spacing: 12
        Glyph { text: bar.g(0xf0425); onTap: () => bar.act("power", null) }
        Row {
            spacing: 2
            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                model: (bar.sys?.tags ?? []).filter(t => t.id <= 3 || t.state !== "empty")
                Rectangle {
                    required property var modelData
                    width: 18; height: 18
                    color: modelData.state === "focused" ? bar.ink : "transparent"
                    Text { anchors.centerIn: parent; text: parent.modelData.id; font.family: bar.font; font.pixelSize: 11
                           color: parent.modelData.state === "focused" ? "#000000" : parent.modelData.state === "empty" ? bar.faint : bar.ink }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.act("ws", parent.modelData.id) }
                }
            }
        }
        Glyph { text: bar.g(0xf0b2a); font.pixelSize: 13; onTap: () => bar.act("launcher", null) }
        Label { text: bar.sys?.title || ""; width: Math.min(implicitWidth, 360); elide: Text.ElideRight; visible: text !== "" }
        Glyph { text: bar.g(0xf014c); font.pixelSize: 13; color: bar.faint; onTap: () => bar.act("exec", ["bash", "-c", "pkill fuzzel || cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"]) }
    }

    Row {
        anchors.centerIn: parent
        spacing: 10
        visible: bar.sys?.hasPlayer ?? false
        Glyph { text: bar.g(0xf075a); font.pixelSize: 12 }
        Label { text: [bar.sys?.artist, bar.sys?.track].filter(x => x).join(": "); width: Math.min(implicitWidth, 150); elide: Text.ElideRight }
        Glyph { text: bar.g(0xf04ae); font.pixelSize: 12; onTap: () => bar.act("prev", null) }
        Rectangle {
            width: 18; height: 18; radius: 9; color: bar.ink
            anchors.verticalCenter: parent.verticalCenter
            Text { anchors.centerIn: parent; text: bar.g(bar.sys?.playing ? 0xf03e4 : 0xf040a); color: "#000000"; font.family: bar.font; font.pixelSize: 11 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.act("play", null) }
        }
        Glyph { text: bar.g(0xf04ad); font.pixelSize: 12; onTap: () => bar.act("next", null) }
    }

    Row {
        anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
        spacing: 14
        Item {
            width: pomo.width; height: 30
            anchors.verticalCenter: parent.verticalCenter
            Row { id: pomo; spacing: 5; anchors.verticalCenter: parent.verticalCenter
                Glyph { text: bar.g(bar.pomodoroRunning ? 0xf13ab : 0xf0e17); font.pixelSize: 13 }
                Label { text: bar.mmss(bar.pomodoro) } }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: m => { if (m.button === Qt.RightButton) { bar.pomodoroRunning = false; bar.pomodoro = 3000 } else bar.pomodoroRunning = !bar.pomodoroRunning } }
        }
        Glyph { text: bar.g(0xf009a); font.pixelSize: 13; onTap: () => bar.act("dnd", null) }
        Row {
            spacing: 3
            visible: bar.sys?.hasBattery ?? false
            anchors.verticalCenter: parent.verticalCenter
            Glyph { text: bar.g(bar.sys?.charging ? 0xf0084 : 0xf007c - 1 + Math.max(1, Math.round((bar.sys?.battery ?? 1) * 10))); font.pixelSize: 13 }
            Label { text: Math.round((bar.sys?.battery ?? 1) * 100) + "%" }
        }
        Item {
            width: ccRow.width; height: 30
            anchors.verticalCenter: parent.verticalCenter
            Row { id: ccRow; spacing: 9; anchors.verticalCenter: parent.verticalCenter
                Glyph { text: bar.g(!(bar.sys?.wifiOn ?? true) ? 0xf092e : bar.sys?.wired ? 0xf0200 : 0xf0928) }
                Glyph { text: bar.g(bar.sys?.btOn ? 0xf00af : 0xf00b2) }
                Glyph { text: bar.g(bar.sys?.muted ? 0xf075f : 0xf057e) } }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: bar.controlCenter() }
        }
        Label { text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "HH:mm"); font.pixelSize: 13 }
    }

    Timer { interval: 1000; repeat: true; running: bar.pomodoroRunning
            onTriggered: { bar.pomodoro = Math.max(0, bar.pomodoro - 1); if (bar.pomodoro === 0) { bar.pomodoroRunning = false; bar.act("exec", ["notify-send", "Pomodoro", "Session done"]) } } }
}
