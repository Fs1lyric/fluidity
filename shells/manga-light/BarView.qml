// 1r0sh's sketchybar (Gruvbox-light): a dark rounded strip floating over the cream desktop. Left: the logo,
// the workspace icons (the focused one in a green box), the front app. Centre: the now-playing pill. Right:
// volume, brightness, battery, network name, the date and the time with its red dot. Pure view.
import QtQuick

Item {
    id: bar
    property var sys
    readonly property color bg: "#e03c3836"
    readonly property color fg: "#fbf1c7"
    readonly property string sans: "Inter"
    readonly property string icons: "Iosevka Nerd Font"
    implicitHeight: 34

    component Item2: Row {
        property string glyph
        property color tint: bar.fg
        property string value
        spacing: 6; height: 26
        Text { text: parent.glyph; font.family: bar.icons; font.pixelSize: 14; color: parent.tint; anchors.verticalCenter: parent.verticalCenter }
        Text { text: parent.value; font.family: bar.sans; font.pixelSize: 12; color: bar.fg; anchors.verticalCenter: parent.verticalCenter }
    }

    Rectangle {
        x: 6; y: 4; width: parent.width - 12; height: 26; radius: 13; color: bar.bg
        Row {
            x: 12; height: parent.height; spacing: 14
            Text { text: "\u{F08C7}"; font.family: bar.icons; font.pixelSize: 15; color: bar.fg; anchors.verticalCenter: parent.verticalCenter }
            Row { spacing: 6; height: 26
                  Repeater { model: (bar.sys?.tags ?? []).filter(t => t.state !== "empty").slice(0, 8)
                             Rectangle { required property var modelData; readonly property bool on: modelData.state === "focused"
                                         width: 26; height: 18; radius: 5; anchors.verticalCenter: parent.verticalCenter
                                         color: on ? "#427b58" : "transparent"
                                         Text { anchors.centerIn: parent; text: modelData.id; font.family: bar.sans; font.bold: true; font.pixelSize: 11
                                                color: parent.on ? bar.fg : "#d79921" } } } }
            Text { text: "»"; font.family: bar.sans; font.pixelSize: 14; color: bar.fg; anchors.verticalCenter: parent.verticalCenter }
            Text { text: bar.sys?.appClass ?? ""; font.family: bar.sans; font.pixelSize: 13; color: bar.fg; anchors.verticalCenter: parent.verticalCenter }
        }
        Rectangle {
            anchors.centerIn: parent; visible: bar.sys?.hasPlayer ?? false
            height: 20; radius: 10; color: "#fbf1c7"; width: np.implicitWidth + 24
            Row { id: np; anchors.centerIn: parent; spacing: 6
                  Text { text: "\u{F075A}"; font.family: bar.icons; font.pixelSize: 12; color: "#cc241d" }
                  Text { width: Math.min(implicitWidth, 300); elide: Text.ElideRight; text: (bar.sys?.artist ? bar.sys.artist + ": " : "") + (bar.sys?.track ?? "")
                         font.family: bar.sans; font.pixelSize: 11; color: "#3c3836" } }
        }
        Row {
            anchors.right: parent.right; anchors.rightMargin: 14; height: parent.height; spacing: 18
            Item2 { glyph: (bar.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}" }
            Item2 { glyph: "\u{F05A9}"; tint: "#b16286"; value: bar.sys?.wired ? "Wired" : (bar.sys?.ssid || "Offline") }
            Item2 { visible: bar.sys?.hasBattery ?? false; glyph: "\u{F0079}"; tint: "#98971a"; value: Math.round((bar.sys?.battery ?? 1) * 100) + "%" }
            Item2 { glyph: "\u{F00ED}"; tint: "#98971a"; value: Qt.formatDateTime(bar.sys?.now ?? new Date(), "ddd MMM dd") }
            Item2 { glyph: "\u{F0954}"; tint: "#cc241d"; value: Qt.formatDateTime(bar.sys?.now ?? new Date(), "hh:mm AP") }
        }
    }
}
