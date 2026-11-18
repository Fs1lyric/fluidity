// The Simple rice's bar (r/unixporn 1wik2gv): no bar at all, just small black pills floating on the wallpaper.
//   left: a load tick and memory in use   centre: round workspace dots, the current one a yellow pill
//   right: a big weather cloud, weather, CPU, battery + volume, and date + clock
import QtQuick

Item {
    id: b
    property var sys
    signal act(string what, var arg)
    implicitHeight: 36
    readonly property color pill: "#121212"
    readonly property color fg: "#f2f2f2"
    readonly property color dim: "#8c8c8c"
    readonly property color yellow: "#ece36a"
    readonly property string font: "JetBrainsMono Nerd Font"
    function g(cp) { return String.fromCodePoint(cp) }

    component Pill: Rectangle {
        default property alias content: inner.data
        height: 24; radius: 12; color: b.pill
        width: inner.childrenRect.width + 22
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        Item { id: inner; x: 11; height: parent.height }
    }
    component T: Text { color: b.fg; font.family: b.font; font.pixelSize: 12; font.weight: Font.Bold; anchors.verticalCenter: parent ? parent.verticalCenter : undefined }

    Pill {
        x: 14
        Row { height: 24; spacing: 8
            Rectangle { width: 3; height: 12; radius: 1.5; color: b.fg; anchors.verticalCenter: parent.verticalCenter
                        Rectangle { anchors.bottom: parent.bottom; width: 3; height: 12 * (b.sys?.cpu ?? 0); color: b.yellow } }
            T { text: "~ " + (b.sys?.ramUsed ?? 0).toFixed(2) + "G"; color: b.fg } }
    }

    Row {
        anchors.centerIn: parent; spacing: 6
        Repeater {
            model: (b.sys?.tags ?? []).filter(t => t.id <= 3 || t.state !== "empty")
            Rectangle {
                required property var modelData
                readonly property bool on: modelData.state === "focused"
                height: 22; width: on ? 38 : 22; radius: 11
                color: on ? b.yellow : b.pill
                Behavior on width { NumberAnimation { duration: 150 } }
                T { anchors.centerIn: parent; text: parent.modelData.id; font.pixelSize: 11; color: parent.on ? "#2a2a00" : parent.modelData.state === "empty" ? b.dim : b.fg }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.act("ws", parent.modelData.id) }
            }
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        spacing: 8
        T { text: b.g(b.sys?.night ? 0xf0f31 : 0xf0590); font.pixelSize: 26; anchors.verticalCenterOffset: -1 }
        Pill { Row { height: 24; spacing: 6
            T { text: b.g(/rain|drizzle|shower/i.test(b.sys?.weatherCond ?? "") ? 0xf0597 : /cloud|overcast/i.test(b.sys?.weatherCond ?? "") ? 0xf0590 : b.sys?.night ? 0xf0594 : 0xf0599) }
            T { text: (b.sys?.weatherTemp ? (+b.sys.weatherTemp >= 0 ? "+" : "") + b.sys.weatherTemp : "--") + "°" } } }
        Pill { T { text: Math.round((b.sys?.cpu ?? 0) * 100) + "%" } }
        Pill { Row { height: 24; spacing: 8
            T { visible: b.sys?.hasBattery ?? false; text: b.g(b.sys?.charging ? 0xf0084 : 0xf0079) }
            T { text: b.g(b.sys?.online ? 0xf05a9 : 0xf05aa) }
            T { text: b.g(b.sys?.muted ? 0xf075f : 0xf057e)
                MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: b.act("mute", null); onWheel: w => b.act("volumeStep", w.angleDelta.y > 0 ? 0.05 : -0.05) } } } }
        Pill { Row { height: 24; spacing: 8
            T { text: Qt.formatDateTime(b.sys?.now ?? new Date(), "ddd dd.MM"); color: b.dim; font.weight: Font.Normal }
            T { text: Qt.formatDateTime(b.sys?.now ?? new Date(), "HH:mm") } }
            MouseArea { anchors.fill: parent; onClicked: b.act("power", null) } }
    }
}
