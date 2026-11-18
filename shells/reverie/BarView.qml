// Polestar's bar, slim: workspaces as dots on the left (the focused one a lilac pill), the clock in the
// middle, volume and battery on the right, on the dark plum strip. Pure view.
import QtQuick

Rectangle {
    id: bar
    property var sys
    color: "#e6141118"
    implicitHeight: 30
    readonly property color fg: "#f4f3f6"
    readonly property color muted: "#a095b2"
    Row {
        x: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 6
        Repeater { model: (bar.sys?.tags ?? []).slice(0, 9)
                   Rectangle { required property var modelData; readonly property bool on: modelData.state === "focused"
                               width: on ? 22 : 8; height: 8; radius: 4; color: on ? "#b4a0d4" : modelData.state === "occupied" ? "#4f455f" : "#27222f"
                               Behavior on width { NumberAnimation { duration: 150 } } } }
    }
    Text { anchors.centerIn: parent; text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "ddd d. MMM  hh:mm AP"); font.family: "Figtree"; font.weight: Font.Medium; font.pixelSize: 13; color: bar.fg }
    Row {
        anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 14
        Text { text: ((bar.sys?.muted ?? false) ? "\u{F075F}  " : "\u{F057E}  ") + Math.round((bar.sys?.volume ?? 0) * 100) + "%"; font.family: "Figtree"; font.pixelSize: 13; color: bar.muted }
        Text { visible: bar.sys?.hasBattery ?? false; text: "\u{F0079}  " + Math.round((bar.sys?.battery ?? 1) * 100) + "%"; font.family: "Figtree"; font.pixelSize: 13; color: bar.muted }
    }
}
