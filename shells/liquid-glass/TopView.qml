// The top of Aeuna's Plasma desktop, drawn straight on the wallpaper (no panel background):
//   left: workspace pills (the current one long)   centre: ♫ now playing   right: audio bars over a spaced-out name
import QtQuick

Item {
    id: t
    property var sys
    property var levels: []
    property string name: sys?.user ? sys.user.charAt(0).toUpperCase() + sys.user.slice(1) : "Aeuna"
    signal act(string what, var arg)
    implicitHeight: 64
    readonly property string sans: "Inter"

    Row {
        x: 14; y: 8; spacing: 6
        Repeater {
            model: (t.sys?.tags ?? []).filter(x => x.id <= 3 || x.state !== "empty")
            Rectangle {
                required property var modelData
                height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter
                width: modelData.state === "focused" ? 30 : 8
                color: modelData.state === "focused" ? "#ffffff" : Qt.rgba(1, 1, 1, modelData.state === "empty" ? 0.35 : 0.6)
                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                MouseArea { anchors.fill: parent; anchors.margins: -5; cursorShape: Qt.PointingHandCursor; onClicked: t.act("ws", parent.modelData.id) }
            }
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter; y: 4; spacing: 8
        visible: t.sys?.hasPlayer ?? false
        Text { text: "♫"; color: "#ffffff"; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter }
        Text { text: t.sys?.track ?? ""; color: "#ffffff"; font.family: t.sans; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter
               width: Math.min(implicitWidth, 320); elide: Text.ElideLeft }
        Text { text: t.sys?.artist ?? ""; color: "#ffffff"; font.family: t.sans; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter; leftPadding: 6 }
    }
    MouseArea { anchors.horizontalCenter: parent.horizontalCenter; width: 420; height: 26; y: 0; cursorShape: Qt.PointingHandCursor
                visible: t.sys?.hasPlayer ?? false; onClicked: t.act("play", null)
                onWheel: w => t.act(w.angleDelta.y > 0 ? "prev" : "next", null) }

    Column {
        anchors { right: parent.right; rightMargin: 14 } y: 6; spacing: 2
        Row {
            anchors.right: parent.right; height: 18; spacing: 3
            Repeater {
                model: t.levels.length ? t.levels : Array(24).fill(0.15)
                Rectangle { required property var modelData; width: 2; color: "#ffffff"; anchors.bottom: parent.bottom
                            height: 3 + modelData * 15; Behavior on height { NumberAnimation { duration: 60 } } }
            }
        }
        Text { anchors.right: parent.right; text: t.name.split("").join(" "); color: Qt.rgba(1, 1, 1, 0.85)
               font.family: "serif"; font.pixelSize: 19; font.letterSpacing: 6 }
    }
}
