// The notch opened up: Ax-Shell's dashboard. Big clock + calendar, the player, quick toggles and stats bars.
import QtQuick
import "Pal.js" as P

Rectangle {
    id: d
    property var sys
    signal act(string what, var arg)
    signal close()
    color: P.bg; radius: 22
    border.color: P.line; border.width: 1
    readonly property date now: sys?.now ?? new Date()
    Row {
        anchors.fill: parent; anchors.margins: 22; spacing: 22
        Column {   // clock + calendar
            width: 210; spacing: 6
            Text { text: Qt.formatDateTime(d.now, "HH:mm"); color: P.fg; font.family: P.mono; font.pixelSize: 54; font.bold: true }
            Text { text: Qt.formatDateTime(d.now, "dddd, d MMMM"); color: P.pink; font.family: P.mono; font.pixelSize: 13 }
            Grid {
                columns: 7; spacing: 2; topPadding: 8
                readonly property date first: new Date(d.now.getFullYear(), d.now.getMonth(), 1)
                readonly property int lead: (first.getDay() + 6) % 7
                readonly property int days: new Date(d.now.getFullYear(), d.now.getMonth() + 1, 0).getDate()
                Repeater { model: ["M", "T", "W", "T", "F", "S", "S"]
                           Text { required property string modelData; width: 28; horizontalAlignment: Text.AlignHCenter
                                  text: modelData; color: P.dim; font.family: P.mono; font.pixelSize: 10 } }
                Repeater {
                    model: parent.lead + parent.days
                    Rectangle {
                        required property int index
                        readonly property int day: index - parent.lead + 1
                        width: 28; height: 18; radius: 9
                        color: day === d.now.getDate() ? P.red : "transparent"
                        Text { anchors.centerIn: parent; visible: parent.day > 0; text: parent.day; color: P.fg; font.family: P.mono; font.pixelSize: 10 }
                    }
                }
            }
        }
        Rectangle { width: 1; height: parent.height; color: P.line }
        Column {   // player + toggles
            width: 270; spacing: 14
            Rectangle {
                width: parent.width; height: 116; radius: 16; color: P.pill
                Rectangle { id: art; x: 12; y: 12; width: 92; height: 92; radius: 12; color: P.red; clip: true
                            Image { anchors.fill: parent; source: d.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop; visible: status === Image.Ready }
                            Text { anchors.centerIn: parent; visible: !(d.sys?.art); text: "󰎆"; font.family: P.mono; font.pixelSize: 34; color: P.bg } }
                Column {
                    anchors { left: art.right; leftMargin: 12; right: parent.right; rightMargin: 12; top: art.top }
                    spacing: 2
                    Text { width: parent.width; elide: Text.ElideRight; text: d.sys?.hasPlayer ? d.sys.track : "Nothing playing"
                           color: P.fg; font.family: P.mono; font.pixelSize: 13; font.bold: true }
                    Text { width: parent.width; elide: Text.ElideRight; text: d.sys?.artist ?? ""; color: P.dim; font.family: P.mono; font.pixelSize: 11 }
                    Item { width: 1; height: 10 }
                    Rectangle { width: parent.width; height: 4; radius: 2; color: P.line
                                Rectangle { width: parent.width * ((d.sys?.length ?? 0) > 0 ? d.sys.position / d.sys.length : 0); height: 4; radius: 2; color: P.pink } }
                    Item { width: 1; height: 8 }
                    Row { spacing: 18
                          Repeater { model: [["󰒮", "prev"], [d.sys?.playing ? "󰏤" : "󰐊", "play"], ["󰒭", "next"]]
                                     Text { required property var modelData; text: modelData[0]; color: P.fg; font.family: P.mono; font.pixelSize: 20
                                            MouseArea { anchors.fill: parent; onClicked: d.act(parent.modelData[1], null) } } } }
                }
            }
            Row { spacing: 7
                  Tog { icon: "󰖩"; on: d.sys?.wifiOn ?? false; onClicked: d.act("wifi", !on) }
                  Tog { icon: "󰂯"; on: d.sys?.btOn ?? false; onClicked: d.act("bt", !on) }
                  Tog { icon: "󰂛"; on: false; onClicked: d.act("dnd", !on) }
                  Tog { icon: "󰅶"; on: d.sys?.caffeine ?? false; onClicked: d.act("caffeine", !on) }
                  Tog { icon: "󰖔"; on: d.sys?.night ?? false; onClicked: d.act("night", !on) } }
        }
        Rectangle { width: 1; height: parent.height; color: P.line }
        Column {   // stats
            spacing: 14; topPadding: 6
            Meter { label: "CPU"; value: d.sys?.cpu ?? 0 }
            Meter { label: "RAM"; value: d.sys?.ram ?? 0 }
            Meter { label: "DISK"; value: d.sys?.diskUsed ?? 0 }
            Meter { label: "BAT"; value: d.sys?.battery ?? 1 }
            Meter { label: "VOL"; value: d.sys?.volume ?? 0 }
        }
    }
}
