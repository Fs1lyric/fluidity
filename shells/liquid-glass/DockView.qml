// Aeuna's bottom panel: one long sheet of liquid glass. Launcher on the left, pinned apps in the middle,
// tray (volume, bluetooth, brightness, wi-fi, battery, more) and a two-line clock on the right.
import QtQuick

Item {
    id: d
    property var sys
    property string iconDir: ""
    property var apps: []        // [{ icon, cmd: [...] }]
    signal act(string what, var arg)
    signal launch(var cmd)
    implicitHeight: 52
    readonly property string sans: "Inter"
    function g(cp) { return String.fromCodePoint(cp) }

    Rectangle {
        id: glass
        anchors.fill: parent; radius: 12
        color: Qt.rgba(0.80, 0.90, 1.0, 0.16)
        border.color: Qt.rgba(1, 1, 1, 0.38); border.width: 1
        // the bright rim along the top edge, like Tahoe glass
        Rectangle { anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 } height: parent.height / 2; radius: 11
                    gradient: Gradient { GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.16) } GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0) } } }
    }

    Text {
        x: 14; anchors.verticalCenter: parent.verticalCenter
        text: d.g(0xf1a0c); color: "#ffffff"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20
        MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor; onClicked: d.act("launcher", null) }
    }

    Row {
        anchors.centerIn: parent; spacing: 12
        Repeater {
            model: d.apps
            Image {
                required property var modelData
                width: 32; height: 32; sourceSize: Qt.size(64, 64); smooth: true
                source: d.iconDir + modelData.icon + ".svg"
                scale: hov.containsMouse ? 1.15 : 1
                Behavior on scale { NumberAnimation { duration: 120 } }
                MouseArea { id: hov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: d.launch(parent.modelData.cmd) }
            }
        }
    }

    Row {
        anchors { right: parent.right; rightMargin: 16; verticalCenter: parent.verticalCenter }
        spacing: 14
        Repeater {
            model: [[d.sys?.muted ? 0xf0581 : 0xf057e, "mute"], [d.sys?.btOn ? 0xf00af : 0xf00b2, "bt"], [0xf00e0, "brightness"],
                    [d.sys?.online ? 0xf0928 : 0xf092e, "wifi"], [d.sys?.charging ? 0xf0084 : 0xf0079, "power"], [0xf0143, "settings"]]
            Text {
                required property var modelData
                anchors.verticalCenter: parent.verticalCenter
                text: d.g(modelData[0]); color: "#ffffff"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14
                MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor
                            onClicked: parent.modelData[1] === "brightness" ? d.act("brightness", 1) : d.act(parent.modelData[1], null)
                            onWheel: w => { if (parent.modelData[1] === "mute") d.act("volumeStep", w.angleDelta.y > 0 ? 0.05 : -0.05) } }
            }
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter; leftPadding: 6
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(d.sys?.now ?? new Date(), "HH:mm")
                   color: "#ffffff"; font.family: d.sans; font.pixelSize: 15 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(d.sys?.now ?? new Date(), "yyyy. MM. dd.")
                   color: "#ffffff"; font.family: d.sans; font.pixelSize: 10 }
        }
    }
}
