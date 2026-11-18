// The Material You control centre down the right edge: profile banner, quick toggles, sliders,
// notifications and a calendar with To Do and Timer tabs. Cards are dark plum glass, the accent is lavender.
import QtQuick

Rectangle {
    id: cc
    property var sys
    property string banner: ""           // the current wallpaper
    property bool dnd: false
    property int tab: 0                  // 0 calendar, 1 to do, 2 timer
    property date shown: new Date()      // month on the calendar
    property int timerLeft: 0
    property int timerSet: 300
    property bool timerRunning: false
    signal act(string what, var arg)
    implicitWidth: 248
    radius: 18
    color: Qt.rgba(0.11, 0.08, 0.12, 0.80); border.color: Qt.rgba(1, 1, 1, 0.10); border.width: 1
    readonly property color card: Qt.rgba(1, 1, 1, 0.05)
    readonly property color accent: "#e3b5f5"
    readonly property color inkAccent: "#3a1d47"
    readonly property color fg: "#ece0f2"
    readonly property color dim: "#a998b4"
    readonly property string sans: "Inter"
    readonly property string icons: "JetBrainsMono Nerd Font"
    function g(cp) { return String.fromCodePoint(cp) }

    component Card: Rectangle { width: col.width; radius: 14; color: cc.card; border.color: Qt.rgba(1, 1, 1, 0.06); border.width: 1 }
    component Ic: Text {
        property string what: ""
        color: cc.fg; font.family: cc.icons; font.pixelSize: 14
        MouseArea { anchors.fill: parent; anchors.margins: -5; enabled: parent.what !== ""; cursorShape: Qt.PointingHandCursor; onClicked: cc.act(parent.what, null) }
    }
    component Tile: Rectangle {
        id: tile
        property int glyph
        property string label: ""
        property string detail: ""
        property bool on: false
        property bool wide: label !== ""
        signal tapped()
        height: 32; radius: 16
        width: wide ? (col.width - 26) * 0.58 : (col.width - 26) * 0.42 - 6
        color: on ? cc.accent : Qt.rgba(1, 1, 1, 0.07)
        Row { anchors { left: parent.left; leftMargin: tile.wide ? 4 : 0; verticalCenter: parent.verticalCenter } spacing: 6
              anchors.horizontalCenter: tile.wide ? undefined : parent.horizontalCenter
            Rectangle { width: 24; height: 24; radius: 12; color: tile.wide && !tile.on ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                Text { anchors.centerIn: parent; text: cc.g(tile.glyph); font.family: cc.icons; font.pixelSize: 13; color: tile.on ? cc.inkAccent : cc.fg } }
            Column { visible: tile.wide; anchors.verticalCenter: parent.verticalCenter
                Text { text: tile.label; font.family: cc.sans; font.pixelSize: 9; color: tile.on ? cc.inkAccent : cc.fg }
                Text { text: tile.detail; font.family: cc.sans; font.pixelSize: 8; color: tile.on ? cc.inkAccent : cc.dim; width: tile.width - 40; elide: Text.ElideRight } } }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: tile.tapped() }
    }
    component Slider: Rectangle {
        id: sl
        property real value: 0
        property int glyph
        signal moved(real v)
        width: col.width - 20; height: 22; radius: 6; color: Qt.rgba(1, 1, 1, 0.08)
        Rectangle { width: Math.max(26, parent.width * sl.value); height: parent.height; radius: 6; color: Qt.rgba(0.89, 0.71, 0.96, 0.85) }
        Text { x: 6; anchors.verticalCenter: parent.verticalCenter; text: cc.g(sl.glyph); font.family: cc.icons; font.pixelSize: 12; color: cc.inkAccent }
        MouseArea { anchors.fill: parent; onPressed: m => sl.moved(m.x / width); onPositionChanged: m => sl.moved(Math.max(0, Math.min(1, m.x / width)))
                    onWheel: w => sl.moved(Math.max(0, Math.min(1, sl.value + (w.angleDelta.y > 0 ? 0.05 : -0.05)))) }
    }

    Column {
        id: col
        x: 8; y: 8; width: parent.width - 16; spacing: 8

        Card {
            height: 116
            Rectangle { x: 6; y: 6; width: parent.width - 12; height: 66; radius: 10; clip: true; color: "#2a2230"
                Image { anchors.fill: parent; source: cc.banner; fillMode: Image.PreserveAspectCrop; asynchronous: true }
                Rectangle { x: 6; y: parent.height - 22; width: 16; height: 16; radius: 8; color: cc.accent
                    Text { anchors.centerIn: parent; text: cc.g(0xf08c7); color: cc.inkAccent; font.family: cc.icons; font.pixelSize: 9 } } }
            Column { x: 10; y: 78
                Text { text: (cc.sys?.user ?? "") + "@" + (cc.sys?.host ?? ""); color: cc.fg; font.family: cc.sans; font.pixelSize: 10 }
                Text { text: "Up - " + (cc.sys?.uptime ?? "").replace(/ hours?,/, "h,").replace(/ minutes?/, "m").replace(/ days?,/, "d,"); color: cc.dim; font.family: cc.sans; font.pixelSize: 8 } }
            Row { anchors { right: parent.right; rightMargin: 10 } y: 84; spacing: 12
                Ic { text: cc.g(0xf03eb); what: "settings" } Ic { text: cc.g(0xf0450); what: "power" }
                Ic { text: cc.g(0xf0493); what: "settings" } Ic { text: cc.g(0xf0425); what: "power" } }
        }

        Card {
            height: tiles.height + 16
            Flow { id: tiles; x: 8; y: 8; width: parent.width - 16; spacing: 6
                Tile { glyph: cc.sys?.wired ? 0xf0200 : 0xf0928; label: "Internet"; detail: cc.sys?.wired ? "Wired connection 1" : cc.sys?.ssid || "Not connected"; onTapped: cc.act("wifi", null) }
                Tile { glyph: cc.sys?.btOn ? 0xf00af : 0xf00b2; label: ""; on: cc.sys?.btOn ?? false; onTapped: cc.act("bt", null) }
                Tile { glyph: 0xf0176; on: cc.sys?.caffeine ?? false; onTapped: cc.act("caffeine", null) }
                Tile { glyph: cc.sys?.micMuted ? 0xf036d : 0xf036c; on: !(cc.sys?.micMuted ?? true); onTapped: cc.act("mic", null) }
                Tile { glyph: cc.sys?.muted ? 0xf075f : 0xf057e; label: "Audio output"; detail: cc.sys?.muted ? "Muted" : "Unmuted"; onTapped: cc.act("mute", null) }
                Tile { glyph: 0xf1120; on: true; onTapped: cc.act("exec", ["pavucontrol"]) }
                Tile { glyph: 0xf0306; onTapped: cc.act("exec", ["bash", "-c", "protonvpn-app || proton-vpn-gtk-app"]) }
            }
        }

        Card {
            height: 64
            Column { anchors.centerIn: parent; spacing: 8
                Slider { glyph: 0xf00df; value: 0.8; onMoved: v => cc.act("brightness", v) }
                Slider { glyph: cc.sys?.muted ? 0xf075f : 0xf057e; value: cc.sys?.volume ?? 0; onMoved: v => cc.act("volume", v) } }
        }

        Card {
            height: 92
            Text { x: 10; y: 8; text: "Notifications"; color: cc.fg; font.family: cc.sans; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { x: 10; y: 28; width: parent.width - 20; wrapMode: Text.WordWrap; color: cc.dim; font.family: cc.sans; font.pixelSize: 9
                   text: cc.dnd ? "Do not disturb is on: new notifications stay quiet." : "New notifications pop up in the corner." }
            Row { anchors { bottom: parent.bottom; bottomMargin: 8; horizontalCenter: parent.horizontalCenter } spacing: 50
                Ic { text: cc.g(cc.dnd ? 0xf009b : 0xf009a); MouseArea { anchors.fill: parent; onClicked: { cc.dnd = !cc.dnd; cc.act("dnd", null) } } }
                Text { text: "clear all"; color: cc.fg; font.family: cc.sans; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter
                       MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cc.act("clearNotifs", null) } }
                Ic { text: cc.g(0xf0f55); what: "clearNotifs" } }
        }

        Card {
            height: 240
            // tabs down the left side
            Column { x: 6; y: 50; spacing: 14
                Repeater { model: [[0xf00f0, "Calendar"], [0xf012c, "To Do"], [0xf13ab, "Timer"]]
                    Item { id: tabItem; required property var modelData; required property int index; width: 44; height: 36
                        Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 30; height: 22; radius: 11
                                    color: cc.tab === tabItem.index ? Qt.rgba(0.89, 0.71, 0.96, 0.3) : "transparent"
                            Text { anchors.centerIn: parent; text: cc.g(tabItem.modelData[0]); color: cc.fg; font.family: cc.icons; font.pixelSize: 13 } }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 24; text: tabItem.modelData[1]; color: cc.fg; font.family: cc.sans; font.pixelSize: 8 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cc.tab = tabItem.index } } } }

            Item {
                x: 52; y: 6; width: parent.width - 58; height: parent.height - 12
                // calendar
                Item {
                    anchors.fill: parent; visible: cc.tab === 0
                    Text { y: 4; anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(cc.shown, "MMMM yyyy"); color: cc.fg; font.family: cc.sans; font.pixelSize: 11 }
                    Row { anchors.right: parent.right; y: 4; spacing: 8
                        Ic { text: "‹"; font.pixelSize: 14; MouseArea { anchors.fill: parent; onClicked: cc.shown = new Date(cc.shown.getFullYear(), cc.shown.getMonth() - 1, 1) } }
                        Ic { text: "›"; font.pixelSize: 14; MouseArea { anchors.fill: parent; onClicked: cc.shown = new Date(cc.shown.getFullYear(), cc.shown.getMonth() + 1, 1) } } }
                    Grid {
                        y: 28; columns: 7; columnSpacing: 1; rowSpacing: 2
                        Repeater { model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                            Text { required property string modelData; width: 23; height: 16; horizontalAlignment: Text.AlignHCenter; text: modelData; color: cc.dim; font.family: cc.sans; font.pixelSize: 8 } }
                        Repeater {
                            model: 42
                            Rectangle {
                                required property int index
                                readonly property date first: new Date(cc.shown.getFullYear(), cc.shown.getMonth(), 1)
                                readonly property date day: new Date(first.getFullYear(), first.getMonth(), 1 - ((first.getDay() + 6) % 7) + index)
                                readonly property bool today: day.toDateString() === (cc.sys?.now ?? new Date()).toDateString()
                                width: 23; height: 26; radius: 13
                                color: today ? cc.accent : "transparent"
                                Text { anchors.centerIn: parent; text: parent.day.getDate(); font.family: cc.sans; font.pixelSize: 10
                                       color: parent.today ? cc.inkAccent : parent.day.getMonth() === cc.shown.getMonth() ? cc.fg : Qt.rgba(1, 1, 1, 0.3) }
                            }
                        }
                    }
                }
                // to do
                Item {
                    anchors.fill: parent; visible: cc.tab === 1
                    Rectangle { width: parent.width; height: 24; radius: 12; color: Qt.rgba(1, 1, 1, 0.07)
                        TextInput { id: todoIn; anchors { fill: parent; leftMargin: 10; rightMargin: 10 } verticalAlignment: Text.AlignVCenter
                                    color: cc.fg; font.family: cc.sans; font.pixelSize: 10; clip: true
                                    onAccepted: { cc.act("todoAdd", text); text = "" }
                            Text { anchors.verticalCenter: parent.verticalCenter; text: "Add a task"; color: cc.dim; font: parent.font; visible: !parent.text } } }
                    Column { y: 32; width: parent.width; spacing: 4
                        Repeater { model: cc.sys?.todos ?? []
                            Row { required property var modelData; required property int index; spacing: 6; width: parent.width
                                Rectangle { width: 14; height: 14; radius: 4; color: modelData.done ? cc.accent : "transparent"; border.color: cc.accent; border.width: 1.5
                                    MouseArea { anchors.fill: parent; onClicked: cc.act("todoToggle", parent.parent.index) } }
                                Text { width: parent.width - 40; text: parent.modelData.text; color: cc.fg; font.family: cc.sans; font.pixelSize: 10; elide: Text.ElideRight
                                       font.strikeout: parent.modelData.done; opacity: parent.modelData.done ? 0.5 : 1 }
                                Text { text: "×"; color: cc.dim; font.pixelSize: 12; MouseArea { anchors.fill: parent; onClicked: cc.act("todoRemove", parent.parent.index) } } } } }
                }
                // timer
                Column {
                    anchors.centerIn: parent; visible: cc.tab === 2; spacing: 12
                    Text { anchors.horizontalCenter: parent.horizontalCenter; color: cc.accent; font.family: cc.sans; font.pixelSize: 40; font.weight: Font.Medium
                           text: { const t = cc.timerRunning || cc.timerLeft ? cc.timerLeft : cc.timerSet; return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0") } }
                    Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 8
                        Repeater { model: [["-1", -60], ["+1", 60], ["+5", 300]]
                            Rectangle { required property var modelData; width: 34; height: 22; radius: 11; color: Qt.rgba(1, 1, 1, 0.08)
                                Text { anchors.centerIn: parent; text: parent.modelData[0]; color: cc.fg; font.family: cc.sans; font.pixelSize: 10 }
                                MouseArea { anchors.fill: parent; onClicked: cc.timerSet = Math.max(60, cc.timerSet + parent.modelData[1]) } } } }
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: 70; height: 26; radius: 13; color: cc.accent
                        Text { anchors.centerIn: parent; text: cc.timerRunning ? "Pause" : cc.timerLeft ? "Resume" : "Start"; color: cc.inkAccent; font.family: cc.sans; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; onClicked: { if (!cc.timerRunning && !cc.timerLeft) cc.timerLeft = cc.timerSet; cc.timerRunning = !cc.timerRunning } } }
                }
            }
        }
    }
    implicitHeight: col.implicitHeight + 16
    Timer { interval: 1000; repeat: true; running: cc.timerRunning
            onTriggered: { cc.timerLeft--; if (cc.timerLeft <= 0) { cc.timerRunning = false; cc.timerLeft = 0; cc.act("exec", ["notify-send", "Timer", "Time is up"]) } } }
}
