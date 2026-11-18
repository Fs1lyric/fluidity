// The HyprPanel bar from the post (matugen lavender): a pale lavender strip with deeper lavender pills and white
// text. Left: the launcher mark, the focused app, the playing track. Centre: workspaces as white dots, the
// active one a long pill. Right: volume, the date and time, notifications. Pure view.
import QtQuick

Rectangle {
    id: bar
    property var sys
    color: "#e6c6c1f4"
    implicitHeight: 40
    readonly property color pill: "#9988cb"
    readonly property color fg: "#faf2f2"
    readonly property string sans: "Inter"
    readonly property string icons: "Iosevka Nerd Font"

    component Pill: Rectangle {
        default property alias content: inner.data
        height: 28; radius: 7; color: bar.pill; anchors.verticalCenter: parent?.verticalCenter
        width: inner.childrenRect.width + 20
        Item { id: inner; x: 10; height: parent.height }
    }
    component Lbl: Row {
        property string glyph
        property string value
        spacing: 8; height: 28
        Text { visible: parent.glyph !== ""; text: parent.glyph; font.family: bar.icons; font.pixelSize: 14; color: bar.fg; anchors.verticalCenter: parent.verticalCenter }
        Text { visible: parent.value !== ""; text: parent.value; font.family: bar.sans; font.weight: Font.Medium; font.pixelSize: 13; color: bar.fg; anchors.verticalCenter: parent.verticalCenter
               width: Math.min(implicitWidth, 240); elide: Text.ElideRight }
    }

    Row {
        x: 6; height: parent.height; spacing: 6
        Pill { Lbl { glyph: "\u{F0E7C}" } }
        Pill { visible: (bar.sys?.appClass ?? "") !== ""
               Lbl { glyph: "\u{F05B6}"; value: { const c = bar.sys?.appClass ?? ""; const n = c.split(".").pop(); return n.charAt(0).toUpperCase() + n.slice(1) } } }
        Pill { visible: bar.sys?.hasPlayer ?? false
               Lbl { glyph: "\u{F04C7}"; value: (bar.sys?.artist ? bar.sys.artist + " - " : "") + (bar.sys?.track ?? "") } }
    }
    Pill {
        anchors.centerIn: parent
        Row { spacing: 7; height: 28
              Repeater { model: (bar.sys?.tags ?? []).slice(0, 10)
                         Rectangle { required property var modelData; readonly property bool on: modelData.state === "focused"
                                     width: on ? 30 : 10; height: 10; radius: 5; anchors.verticalCenter: parent.verticalCenter
                                     color: bar.fg; opacity: on || modelData.state === "occupied" ? 1 : 0.55
                                     Behavior on width { NumberAnimation { duration: 180 } } } } }
    }
    Row {
        anchors.right: parent.right; anchors.rightMargin: 6; height: parent.height; spacing: 6
        Pill { Lbl { glyph: (bar.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}"; value: Math.round((bar.sys?.volume ?? 0) * 100) + "%" } }
        Pill { Lbl { glyph: "\u{F00ED}"; value: Qt.formatDateTime(bar.sys?.now ?? new Date(), "ddd MMM d  hh:mm AP") } }
        Pill { Lbl { glyph: "\u{F009A}" } }
    }
}
