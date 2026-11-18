import QtQuick
import Quickshell
import Quickshell.Wayland

// One slot in the dock: an app, a separator, a minimized window or the Trash.
Item {
    id: root

    required property var modelData
    required property int index
    property var host

    readonly property string kind: modelData.kind
    readonly property real size: host.sizeAt(index)
    readonly property bool bouncing: kind === "app" && host.isBouncing(modelData.key, modelData.windows.length)

    width: size
    height: host.maxSize

    // ---- separator ----
    Rectangle {
        visible: root.kind === "sep"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: host.baseSize * 0.12
        width: 1
        height: host.baseSize * 0.76
        color: Qt.rgba(1, 1, 1, 0.28)
    }

    // ---- app / trash icon ----
    property real bounceY: 0
    SequentialAnimation {
        running: root.bouncing
        loops: Animation.Infinite
        NumberAnimation { target: root; property: "bounceY"; to: -host.baseSize * 0.5; duration: 300; easing.type: Easing.OutQuad }
        NumberAnimation { target: root; property: "bounceY"; to: 0; duration: 300; easing.type: Easing.InQuad }
        PauseAnimation { duration: 80 }
    }
    onBouncingChanged: if (!bouncing) settle.start()
    NumberAnimation { id: settle; target: root; property: "bounceY"; to: 0; duration: 180; easing.type: Easing.OutQuad }

    Image {
        id: icon
        visible: root.kind === "app" || root.kind === "trash" || root.kind === "downloads" || (root.kind === "min" && !shot.hasContent)
        width: root.size
        height: root.size
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        transform: [
            Scale { origin.x: icon.width / 2; origin.y: icon.height / 2; xScale: host.position === "right" ? -1 : 1 },
            Rotation { origin.x: icon.width / 2; origin.y: icon.height / 2; angle: host.vertical ? -90 : 0 },
            Translate { y: root.bounceY }
        ]
        source: root.kind === "trash" ? Quickshell.iconPath(host.trashFull ? "user-trash-full" : "user-trash", "user-trash")
              : root.kind === "downloads" ? Quickshell.iconPath("folder-download", "folder")
              : root.kind === "min" ? host.iconFor(root.modelData.appKey)
              : root.kind === "app" ? host.iconFor(root.modelData.key) : ""
        sourceSize: Qt.size(host.maxSize * 2, host.maxSize * 2)
        opacity: root.kind === "app" && host.dragKey === root.modelData.key ? 0.25 : 1
        smooth: true
        mipmap: true
        asynchronous: true
    }

    // Running indicator dot.
    Rectangle {
        visible: host.indicators && root.kind === "app" && root.modelData.windows.length > 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: (host.padV - height) / 2
        width: 4
        height: 4
        radius: 2
        color: Qt.rgba(1, 1, 1, 0.8)
    }

    // ---- minimized window: a snapshot of the window with its app icon in the corner ----
    ScreencopyView {
        id: shot
        visible: root.kind === "min" && hasContent
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.size * 0.92
        height: Math.min(root.size * 0.92, width / Math.max(0.5, sourceSize.width / Math.max(1, sourceSize.height)))
        anchors.bottomMargin: (root.size - height) / 2
        captureSource: root.kind === "min" ? root.modelData.window.top.wayland : null
        // Undo the dock's turn on a side edge so the snapshot stays upright.
        transform: [
            Scale { origin.x: shot.width / 2; origin.y: shot.height / 2; xScale: host.position === "right" ? -1 : 1 },
            Rotation { origin.x: shot.width / 2; origin.y: shot.height / 2; angle: host.vertical ? -90 : 0 }
        ]
        live: false

        Image {
            width: root.size * 0.4
            height: width
            anchors { right: parent.right; bottom: parent.bottom; rightMargin: -width * 0.15; bottomMargin: -width * 0.15 }
            source: root.kind === "min" ? host.iconFor(root.modelData.appKey) : ""
            sourceSize: Qt.size(host.maxSize, host.maxSize)
            smooth: true
            mipmap: true
        }
    }
}
