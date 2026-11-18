import QtQuick

// Shared by the live dock and the offscreen visual check.
// Dark Liquid Glass (Tahoe / Golden Gate dark appearance): smoked tint over the blur, a faint
// rim all round, a brighter specular rim along the top edge, and a soft sheen under it.
Rectangle {
    id: shelf
    radius: 21
    gradient: Gradient {
        GradientStop { position: 0; color: Qt.rgba(0.07, 0.07, 0.08, 0.50) }
        GradientStop { position: 1; color: Qt.rgba(0.03, 0.03, 0.04, 0.62) }
    }
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.09)

    // Specular rim: the same rounded outline, brighter, clipped to the top part.
    Item {
        width: parent.width
        height: shelf.radius
        clip: true
        Rectangle {
            width: shelf.width
            height: shelf.height
            radius: shelf.radius
            color: "transparent"
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.28)
        }
    }

    // Sheen across the top, like light catching the glass.
    Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
        height: parent.height * 0.45
        radius: parent.radius - 1
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.07) }
            GradientStop { position: 1; color: Qt.rgba(1, 1, 1, 0.0) }
        }
    }
}
