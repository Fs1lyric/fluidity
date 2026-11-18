import QtQuick

// A Nerd Font glyph with an optional label, clickable and scrollable.
Item {
    id: status

    property string icon
    property string label: ""
    property color tint: Theme.foreground
    signal clicked()
    signal rightClicked()
    signal scrolled(bool up)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 5

        Text {
            text: status.icon
            font { family: Theme.font; pixelSize: 15 }
            color: area.containsMouse ? Theme.foreground : status.tint
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            visible: status.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            text: status.label
            font { family: Theme.font; pixelSize: Theme.fontSize - 1 }
            color: Theme.dim
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => mouse.button === Qt.RightButton ? status.rightClicked() : status.clicked()
        onWheel: wheel => status.scrolled(wheel.angleDelta.y > 0)
    }
}
