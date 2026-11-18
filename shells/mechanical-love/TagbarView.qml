// elenapan's bottom taglist (lovelace theme): one icon per workspace, its PNG changes with the state
// (empty / occupied / focused / urgent). Transparent, 620 wide, 45 high, centred at the bottom.
// Original: config/awesome/bars.lua + themes/lovelace/taglist/*.png
import QtQuick

Item {
    id: root
    property string tagDir: "taglist/"
    property string iconDir: "icons/"
    // [{ id, state: "empty" | "occupied" | "focused" | "urgent" }] for workspaces 1..10
    property var tags: []
    signal clicked(int id)
    signal layoutClicked()
    signal menuClicked()

    implicitWidth: 620
    implicitHeight: 45

    Row {
        anchors.centerIn: parent
        spacing: 5
        Item {
            width: 40; height: 45
            Image { anchors.centerIn: parent; width: 30; height: 30; sourceSize: Qt.size(60, 60); smooth: true; mipmap: true
                    source: root.iconDir + "sidebar.png" }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.menuClicked() }
        }
        Text { text: "|"; color: "#414458"; font.pointSize: 14; anchors.verticalCenter: parent.verticalCenter }
        Repeater {
            model: root.tags
            Item {
                required property var modelData
                width: 40; height: 45
                Image {
                    anchors.centerIn: parent
                    width: 33; height: 33
                    sourceSize: Qt.size(66, 66)
                    smooth: true; mipmap: true
                    source: root.tagDir + parent.modelData.id + "_" + parent.modelData.state + ".png"
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.clicked(parent.modelData.id) }
            }
        }
        Text { text: "|"; color: "#414458"; font.pointSize: 14; anchors.verticalCenter: parent.verticalCenter }
        Item {
            width: 40; height: 45
            Image { anchors.centerIn: parent; width: 26; height: 26; sourceSize: Qt.size(52, 52); smooth: true
                    source: root.iconDir + "layout.png" }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.layoutClicked() }
        }
    }
}
