// The floating pill bar of the "liquid ass + Material You" post: logo + audio wave | media | date, time,
// workspace dots | cpu / ram / disk rings | tools | tray | power. Every pill is dark glass with a faint rim.
import QtQuick

Item {
    id: b
    property var sys
    property var levels: []
    signal act(string what, var arg)
    signal controlCenter()
    implicitHeight: 34
    readonly property color glass: Qt.rgba(0.10, 0.07, 0.11, 0.72)
    readonly property color rim: Qt.rgba(1, 1, 1, 0.10)
    readonly property color accent: "#e3b5f5"
    readonly property color inkAccent: "#3a1d47"
    readonly property color fg: "#ece0f2"
    readonly property string sans: "Inter"
    readonly property string icons: "JetBrainsMono Nerd Font"
    function g(cp) { return String.fromCodePoint(cp) }

    component Pill: Rectangle {
        default property alias content: inner.data
        property real pad: 8
        height: 26; radius: 13; color: b.glass; border.color: b.rim; border.width: 1
        width: inner.childrenRect.width + pad * 2
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        Item { id: inner; x: parent.pad; height: parent.height }
    }
    component Ic: Text {
        property string what: ""
        color: b.fg; font.family: b.icons; font.pixelSize: 13; anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        MouseArea { anchors.fill: parent; anchors.margins: -4; enabled: parent.what !== ""; cursorShape: Qt.PointingHandCursor; onClicked: b.act(parent.what, null) }
    }
    component Ring: Item {
        property real value: 0
        property int glyph: 0
        width: 18; height: 18; anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        Canvas { anchors.fill: parent; property real v: parent.value; onVChanged: requestPaint()
            onPaint: { const c = getContext("2d"); c.reset(); c.lineWidth = 2.5;
                c.strokeStyle = "#4a3a55"; c.beginPath(); c.arc(9, 9, 7, 0, Math.PI * 2); c.stroke();
                c.strokeStyle = b.accent; c.beginPath(); c.arc(9, 9, 7, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * v); c.stroke() } }
    }

    Row {
        x: 6; height: parent.height; spacing: 6
        Pill { pad: 4; Row { height: 26; spacing: 6
            Rectangle { width: 20; height: 20; radius: 10; color: b.accent; anchors.verticalCenter: parent.verticalCenter
                Text { anchors.centerIn: parent; text: b.g(0xf08c7); color: b.inkAccent; font.family: b.icons; font.pixelSize: 12 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.act("launcher", null) } }
            Text { text: b.sys?.workspace ?? 0; color: b.fg; font.family: b.sans; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter; rightPadding: 4 } } }
        Pill { Row { height: 26; spacing: 2
            Repeater { model: b.levels.length ? b.levels : Array(28).fill(0.1)
                Rectangle { required property var modelData; required property int index; width: 2; radius: 1; anchors.verticalCenter: parent.verticalCenter
                            height: Math.max(2, modelData * 16); color: index % 7 === 3 ? b.fg : Qt.rgba(1, 1, 1, 0.55) } } } }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter; anchors.horizontalCenterOffset: -60
        height: parent.height; spacing: 6
        Pill {
            visible: b.sys?.hasPlayer ?? false; pad: 4
            Row { height: 26; spacing: 7
                Rectangle { width: 20; height: 20; radius: 10; clip: true; color: "#4a3a55"; anchors.verticalCenter: parent.verticalCenter
                    Image { anchors.fill: parent; source: b.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop } }
                Column { anchors.verticalCenter: parent.verticalCenter; width: Math.min(110, Math.max(t1.implicitWidth, t2.implicitWidth))
                    Text { id: t1; width: parent.width; text: b.sys?.artist ?? ""; color: b.fg; font.family: b.sans; font.pixelSize: 9; elide: Text.ElideRight }
                    Text { id: t2; width: parent.width; text: b.sys?.track ?? ""; color: Qt.rgba(1, 1, 1, 0.65); font.family: b.sans; font.pixelSize: 9; elide: Text.ElideRight } }
                Rectangle { width: 30; height: 18; radius: 9; color: b.accent; anchors.verticalCenter: parent.verticalCenter
                    Text { anchors.centerIn: parent; text: b.g(b.sys?.playing ? 0xf03e4 : 0xf040a); color: b.inkAccent; font.family: b.icons; font.pixelSize: 11 }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.act("play", null) } }
                Ic { text: b.g(0xf04ad); what: "next"; rightPadding: 4 } }
        }
        Pill { pad: 3; Row { height: 26; spacing: 4
            Text { text: Qt.formatDateTime(b.sys?.now ?? new Date(), "ddd, dd/MM"); color: b.fg; font.family: b.sans; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter; leftPadding: 6 }
            Rectangle { width: tm.implicitWidth + 12; height: 20; radius: 10; color: Qt.rgba(0.89, 0.71, 0.96, 0.25); anchors.verticalCenter: parent.verticalCenter
                Text { id: tm; anchors.centerIn: parent; text: Qt.formatDateTime(b.sys?.now ?? new Date(), "h:mm AP"); color: b.fg; font.family: b.sans; font.pixelSize: 11; font.weight: Font.DemiBold } } } }
        Pill { Row { height: 26; spacing: 5
            Repeater { model: b.sys?.tags ?? []
                Rectangle { required property var modelData
                    anchors.verticalCenter: parent.verticalCenter
                    width: modelData.state === "focused" ? 22 : 7; height: 7; radius: 4
                    color: modelData.state === "focused" ? b.accent : modelData.state === "empty" ? Qt.rgba(1, 1, 1, 0.3) : Qt.rgba(1, 1, 1, 0.75)
                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                    MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor; onClicked: b.act("ws", parent.modelData.id) } } } } }
        Pill { Row { height: 26; spacing: 6
            Ring { value: b.sys?.cpu ?? 0 } Text { text: Math.round((b.sys?.cpu ?? 0) * 100); color: b.fg; font.family: b.sans; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            Ring { value: b.sys?.ram ?? 0 } Text { text: Math.round((b.sys?.ram ?? 0) * 100); color: b.fg; font.family: b.sans; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
            Ring { value: b.sys?.diskUsed ?? 0 } Text { text: Math.round((b.sys?.diskUsed ?? 0) * 100); color: b.fg; font.family: b.sans; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter } } }
        Pill { Row { height: 26; spacing: 12
            Ic { text: b.g(0xf0293); what: "shot" }
            Ic { text: b.g(0xf0d50); what: "launcher" }
            Ic { text: b.g(0xf0e08); what: "settings" } } }
        Pill { pad: 3; Rectangle { width: 26; height: 18; radius: 9; color: b.fg; anchors.verticalCenter: parent.verticalCenter
            Text { anchors.centerIn: parent; text: b.sys?.hasBattery ? Math.round(b.sys.battery * 100) : b.g(0xf06a5); color: "#141016"; font.family: b.sys?.hasBattery ? b.sans : b.icons; font.pixelSize: 10; font.weight: Font.Bold } } }
    }

    Row {
        anchors { right: parent.right; rightMargin: 6 }
        height: parent.height; spacing: 6
        Pill { Ic { text: b.g(0xf0140); what: "launcher" } }
        Pill { Row { height: 26; spacing: 10
            Ic { text: b.g(b.sys?.muted ? 0xf075f : 0xf057e); what: "mute" }
            Ic { text: b.g(b.sys?.wired ? 0xf0200 : b.sys?.online ? 0xf0928 : 0xf092e) }
            Ic { text: b.g(b.sys?.btOn ? 0xf00af : 0xf00b2) } }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.controlCenter() } }
        Rectangle { width: 26; height: 26; radius: 13; color: b.accent; anchors.verticalCenter: parent.verticalCenter
            Text { anchors.centerIn: parent; text: b.g(0xf0425); color: b.inkAccent; font.family: b.icons; font.pixelSize: 13 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: b.act("power", null) } }
    }
}
