import QtQuick

// The Apple menu's windows, macOS Tahoe dark appearance, drawn as plain QtQuick so they render
// offscreen too (~/claude/archy-cleanup/tahoe/render-claude). MacDialogs.qml feeds and shows them.
//
//   about      About This Mac: device picture, big name, spec rows, More Info… capsule
//   forcequit  Force Quit Applications: app list, hint, blue Force Quit capsule
//   restart / shutdown / logout   the confirmation alert with its 60 s countdown
//
// Tahoe windows: 26 px corners, 12 px traffic lights 20 px apart; alerts: 22 px corners, title
// in 13 px bold, side-by-side capsule buttons with the default one in accent blue.
FocusScope {
    id: view

    property string mode: "about"
    property var about: ({})          // { name, model, chip, graphics, memory, disk, kernel }
    property url deviceIcon
    property var apps: []             // [{ name, iconUrl }]
    property int selected: 0
    property int seconds: 60
    property string userName: ""

    signal closeRequested()
    signal confirmed()
    signal forceQuit(int index)
    signal moreInfo()

    readonly property bool isAlert: mode === "restart" || mode === "shutdown" || mode === "logout"
    readonly property color ink: Qt.rgba(1, 1, 1, 0.88)
    readonly property color dim: Qt.rgba(1, 1, 1, 0.5)
    readonly property color accent: "#0a84ff"

    implicitWidth: isAlert ? 260 : mode === "forcequit" ? 380 : 280
    implicitHeight: isAlert ? alert.implicitHeight : mode === "forcequit" ? 372 : 452

    Keys.onEscapePressed: closeRequested()
    Keys.onReturnPressed: isAlert ? confirmed() : mode === "forcequit" && apps.length ? forceQuit(selected) : closeRequested()
    Keys.onUpPressed: selected = Math.max(0, selected - 1)
    Keys.onDownPressed: selected = Math.min(apps.length - 1, selected + 1)

    // ---- shared pieces -----------------------------------------------------------------

    component Capsule: Rectangle {
        id: cap
        property string label
        property bool primary: false
        property bool active: true
        signal clicked()
        height: 28
        radius: 14
        color: !active ? Qt.rgba(1, 1, 1, 0.06)
             : primary ? (press.pressed ? Qt.darker(view.accent, 1.2) : view.accent)
             : (press.pressed ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.13))
        Text {
            anchors.centerIn: parent
            text: cap.label
            color: cap.active ? "white" : Qt.rgba(1, 1, 1, 0.3)
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: Font.Medium
        }
        MouseArea { id: press; anchors.fill: parent; enabled: cap.active; onClicked: cap.clicked() }
    }

    component Lights: Row {
        spacing: 8
        Repeater {
            model: ["#ff5f57", "#febc2e", "#28c840"]
            Rectangle {
                required property string modelData
                required property int index
                width: 12
                height: 12
                radius: 6
                // Only close works on these panels; macOS greys the others out.
                color: index === 0 ? modelData : Qt.rgba(1, 1, 1, 0.16)
                border.width: 0.5
                border.color: Qt.rgba(0, 0, 0, 0.25)
                MouseArea { anchors.fill: parent; enabled: index === 0; onClicked: view.closeRequested() }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: view.isAlert ? 22 : 26
        color: Qt.rgba(0.125, 0.125, 0.133, 0.90)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.13)
    }

    // ---- About This Mac ----------------------------------------------------------------

    Item {
        visible: view.mode === "about"
        anchors.fill: parent

        Lights { x: 16; y: 16 }

        Image {
            id: device
            anchors.horizontalCenter: parent.horizontalCenter
            y: 46
            width: 132
            height: 132
            source: view.deviceIcon
            sourceSize: Qt.size(264, 264)
            smooth: true
        }
        Text {
            id: title
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: device.bottom
            anchors.topMargin: 10
            text: view.about.name ?? ""
            color: "white"
            font.family: "Inter"
            font.pixelSize: 24
            font.weight: Font.Bold
        }
        Text {
            id: subtitle
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: title.bottom
            anchors.topMargin: 2
            text: view.about.model ?? ""
            color: view.dim
            font.family: "Inter"
            font.pixelSize: 11
        }

        // Spec rows: labels right-aligned against the centre line, values left-aligned after it.
        Column {
            id: specs
            anchors.top: subtitle.bottom
            anchors.topMargin: 22
            width: parent.width
            spacing: 5
            Repeater {
                model: [
                    ["Chip", view.about.chip], ["Graphics", view.about.graphics], ["Memory", view.about.memory],
                    ["Startup disk", view.about.disk], ["Linux", view.about.kernel]
                ]
                Item {
                    required property var modelData
                    width: specs.width
                    height: 15
                    Text {
                        anchors.right: parent.left
                        anchors.rightMargin: -104
                        text: modelData[0]
                        color: view.ink
                        font.family: "Inter"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                    Text {
                        x: 112
                        width: parent.width - 112 - 16
                        elide: Text.ElideRight
                        text: modelData[1] ?? ""
                        color: view.dim
                        font.family: "Inter"
                        font.pixelSize: 11
                    }
                }
            }
        }

        Capsule {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 26
            width: 108
            label: "More Info…"
            onClicked: view.moreInfo()
        }
    }

    // ---- Force Quit Applications -------------------------------------------------------

    Item {
        visible: view.mode === "forcequit"
        anchors.fill: parent

        Lights { x: 16; y: 16 }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 14
            text: "Force Quit Applications"
            color: view.ink
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: Font.Bold
        }
        Text {
            id: hint
            x: 20
            y: 46
            width: parent.width - 40
            wrapMode: Text.WordWrap
            text: "If an app doesn’t respond for a while, select its name and click Force Quit."
            color: view.ink
            font.family: "Inter"
            font.pixelSize: 12
        }
        Rectangle {
            id: box
            x: 20
            anchors.top: hint.bottom
            anchors.topMargin: 12
            width: parent.width - 40
            height: 200
            radius: 10
            color: Qt.rgba(0, 0, 0, 0.22)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.08)
            clip: true

            ListView {
                anchors.fill: parent
                anchors.margins: 5
                model: view.apps
                boundsBehavior: Flickable.StopAtBounds
                delegate: Item {
                    id: app
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 26
                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        visible: view.selected === app.index
                        color: view.accent
                    }
                    Image {
                        x: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18
                        height: 18
                        source: app.modelData.iconUrl ?? ""
                        sourceSize: Qt.size(36, 36)
                        smooth: true
                    }
                    Text {
                        x: 34
                        anchors.verticalCenter: parent.verticalCenter
                        text: app.modelData.name
                        color: view.selected === app.index ? "white" : view.ink
                        font.family: "Inter"
                        font.pixelSize: 13
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: view.selected = app.index
                        onDoubleClicked: view.forceQuit(app.index)
                    }
                }
            }
        }
        Text {
            x: 20
            anchors.top: box.bottom
            anchors.topMargin: 14
            width: parent.width - 150
            wrapMode: Text.WordWrap
            text: "You can open this window by pressing Command + Option + Escape."
            color: view.dim
            font.family: "Inter"
            font.pixelSize: 11
        }
        Capsule {
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: box.bottom
            anchors.topMargin: 14
            width: 100
            primary: true
            active: view.apps.length > 0
            label: "Force Quit"
            onClicked: view.forceQuit(view.selected)
        }
    }

    // ---- Restart / Shut Down / Log Out alert -------------------------------------------

    Column {
        id: alert
        visible: view.isAlert
        width: parent.width
        topPadding: 22
        bottomPadding: 16
        spacing: 0

        readonly property var copy: ({
            restart: ["Are you sure you want to restart your computer now?", "the computer will restart", "Restart"],
            shutdown: ["Are you sure you want to shut down your computer now?", "the computer will shut down", "Shut Down"],
            logout: ["Are you sure you want to quit all applications and log out now?", "you will be logged out", "Log Out"]
        })
        readonly property var words: copy[view.mode] ?? copy.shutdown

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 64
            height: 64
            source: view.deviceIcon
            sourceSize: Qt.size(128, 128)
            smooth: true
        }
        Item { width: 1; height: 12 }
        Text {
            x: 20
            width: parent.width - 40
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: alert.words[0]
            color: "white"
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: Font.Bold
        }
        Item { width: 1; height: 6 }
        Text {
            x: 20
            width: parent.width - 40
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: `If you do nothing, ${alert.words[1]} automatically in ${view.seconds} second${view.seconds === 1 ? "" : "s"}.`
            color: view.ink
            font.family: "Inter"
            font.pixelSize: 11
        }
        Item { width: 1; height: 16 }
        Row {
            x: 16
            spacing: 8
            Capsule { width: (alert.width - 40) / 2; label: "Cancel"; onClicked: view.closeRequested() }
            Capsule { width: (alert.width - 40) / 2; label: alert.words[2]; primary: true; onClicked: view.confirmed() }
        }
    }
}
