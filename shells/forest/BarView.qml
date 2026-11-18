// nuxshed's floating bottom bar (AwesomeWM, "forest" theme): a taglist pill bottom-left (focused tag = aqua
// square with dark text, empty tags in grey), the open windows' class letters in the middle, and on the right
// the battery pill, the orange date/time pill and the control-centre button. Pure view.
import QtQuick

Item {
    id: bar
    property var sys
    property bool panelOpen: false
    signal act(string what, var arg)
    readonly property color bg: "#1d2021"
    readonly property color fg: "#d4be98"
    readonly property color grey: "#928374"
    readonly property color aqua: "#89b482"
    readonly property string mono: "JetBrains Mono"
    readonly property string icons: "Iosevka Nerd Font"
    implicitHeight: 52

    component Pill: Rectangle {
        default property alias content: inner.data
        height: 30; radius: 6; color: bar.bg
        width: inner.childrenRect.width + 20
        Item { id: inner; x: 10; height: parent.height }
    }

    Pill {
        x: 20; anchors.bottom: parent.bottom; anchors.bottomMargin: 12
        Row { spacing: 4; height: 30
              Repeater { model: (bar.sys?.tags ?? []).slice(0, 9)
                         Rectangle { required property var modelData
                                     readonly property bool on: modelData.state === "focused"
                                     width: 18; height: 18; radius: 5; anchors.verticalCenter: parent.verticalCenter
                                     color: on ? bar.aqua : "transparent"
                                     Text { anchors.centerIn: parent; text: modelData.id; font.family: bar.mono; font.pixelSize: 11
                                            color: parent.on ? bar.bg : modelData.state === "occupied" ? bar.fg : bar.grey } } } }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 12
        width: 30; height: 30; radius: 6; color: bar.bg; visible: (bar.sys?.appClass ?? "") !== ""
        Text { anchors.centerIn: parent; text: "\u{F018D}"; font.family: bar.icons; font.pixelSize: 16; color: bar.fg }
    }

    Row {
        anchors.right: parent.right; anchors.rightMargin: 20; anchors.bottom: parent.bottom; anchors.bottomMargin: 12; spacing: 8
        Pill { visible: bar.sys?.hasBattery ?? false
               Row { spacing: 6; height: 30
                     Text { text: bar.sys?.charging ? "\u{F0084}" : "\u{F0079}"; font.family: bar.icons; font.pixelSize: 14; color: "#a9b665"; anchors.verticalCenter: parent.verticalCenter }
                     Text { text: Math.round((bar.sys?.battery ?? 1) * 100) + "%"; font.family: bar.mono; font.pixelSize: 11; color: bar.fg; anchors.verticalCenter: parent.verticalCenter } } }
        Pill { Text { anchors.verticalCenter: parent.verticalCenter; text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "ddd MMM d, hh:mm")
                      font.family: bar.mono; font.pixelSize: 11; color: "#e78a4e" } }
        Rectangle { width: 30; height: 30; radius: 6; color: bar.panelOpen ? bar.aqua : bar.bg
                    Text { anchors.centerIn: parent; text: "\u{F056E}"; font.family: bar.icons; font.pixelSize: 16; color: bar.panelOpen ? bar.bg : bar.fg } }
    }
}
