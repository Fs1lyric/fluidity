// The Sekai top bar: three groups of outlined pills. Left: workspace name, now playing, quick apps.
// Middle: network/bluetooth/volume, weather, workspaces 1-5, time, date. Right: tools, battery, the red
// notification dot and the profile pill, settings.
import QtQuick
import "Pal.js" as P

Item {
    id: b
    property var sys
    signal act(string what, var arg)
    implicitHeight: 34
    readonly property date now: sys?.now ?? new Date()
    Row {
        x: 8; y: 4; spacing: 6
        Pill { Label { text: "Workspace " + (b.sys?.workspace ?? 1) } onClicked: b.act("launcher", null) }
        Pill {
            fill: P.light
            Rectangle { width: 30; height: 16; radius: 8; color: P.mid; anchors.verticalCenter: parent.verticalCenter; clip: true
                        Image { anchors.fill: parent; source: b.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop } }
            Label { width: 120; elide: Text.ElideRight; text: b.sys?.hasPlayer ? b.sys.track : "nothing playing" }
            onClicked: b.act("play", null)
        }
        Pill { Label { glyph: true; text: "󰈹" } Label { glyph: true; text: "" } Label { glyph: true; text: "󰉋" } onClicked: b.act("browser", null) }
    }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter; y: 4; spacing: 6
        Pill { Label { glyph: true; text: b.sys?.online ? "󰖩" : "󰖪" } Label { glyph: true; text: b.sys?.btOn ? "󰂯" : "󰂲" }
               Label { glyph: true; text: b.sys?.muted ? "󰖁" : "󰕾" } onClicked: b.act("mute", null) }
        Pill { Label { glyph: true; text: b.sys?.night ? "󰼱" : "󰖐" } Label { text: (b.sys?.weatherTemp || "--") + "°C" } }
        Repeater {
            model: [1, 2, 3, 4, 5]
            Rectangle {
                required property int modelData
                readonly property bool on: (b.sys?.workspace ?? 1) === modelData
                width: 26; height: 26; radius: 13; border.color: P.ink; border.width: 2
                color: on ? P.lilac : P.pill
                Label { anchors.centerIn: parent; text: parent.modelData }
                MouseArea { anchors.fill: parent; onClicked: b.act("ws", parent.modelData) }
            }
        }
        Pill { Label { text: Qt.formatDateTime(b.now, "hh:mm AP") } }
        Pill { Label { glyph: true; text: "󰃭" } Label { text: Qt.formatDateTime(b.now, "ddd, MMM d") } }
    }
    Row {
        anchors.right: parent.right; anchors.rightMargin: 8; y: 4; spacing: 6
        Pill { Label { glyph: true; text: "󰹑" } Label { glyph: true; text: "󰏫" } Label { glyph: true; text: "󰖔" }
               Label { glyph: true; text: b.sys?.caffeine ? "󰅶" : "󰛊" } onClicked: b.act("shot", null) }
        Pill { Label { glyph: true; text: b.sys?.charging ? "󰂄" : "󰁹" } Label { text: Math.round((b.sys?.battery ?? 1) * 100) + "%" } }
        Pill { fill: P.red; Label { text: "!" } onClicked: b.act("clearNotifs", null) }
        Pill { fill: P.lilac
               Rectangle { width: 16; height: 16; radius: 8; color: P.paper; border.color: P.ink; anchors.verticalCenter: parent.verticalCenter }
               Label { text: (b.sys?.user ?? "") + " ♥ " + (b.sys?.tags ?? []).filter(t => t.count > 0).length }
               onClicked: b.act("power", null) }
        Rectangle { width: 26; height: 26; radius: 13; color: P.pill; border.color: P.ink; border.width: 2
                    Label { anchors.centerIn: parent; glyph: true; text: "󰒓" }
                    MouseArea { anchors.fill: parent; onClicked: b.act("settings", null) } }
    }
}
