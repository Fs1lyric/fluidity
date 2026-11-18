import QtQuick

// Dark glass: Hyprland blurs what is behind the layer; this adds the tint, the 1px light rim and a soft glow.
Rectangle {
    id: g
    property var pal: ({})
    property real tint: 0.86
    property bool glow: false
    radius: height / 2
    color: Qt.rgba(0.04, 0.05, 0.055, tint)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.07)
    Rectangle { // accent glow around open popups: a soft ring just outside the shape
        visible: g.glow
        z: -1
        anchors.centerIn: parent
        width: parent.width + 48; height: parent.height + 48; radius: g.radius + 24
        color: "transparent"
        border.width: 24
        border.color: Qt.rgba(Qt.color(g.pal.accent || "#d7e59b").r, Qt.color(g.pal.accent || "#d7e59b").g, Qt.color(g.pal.accent || "#d7e59b").b, 0.045)
    }
}
