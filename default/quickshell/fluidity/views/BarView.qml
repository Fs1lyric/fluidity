import QtQuick

// The bar: a left pill (droplet + workspaces) and a right pill (status). The island sits between them,
// drawn by the shell on top. Pure view for tools/render.py.
Item {
    id: bar
    property var pal: ({ accent: "#d7e59b", cyan: "#c2e6d6", fg: "#e3e4da", dim: "#878880", muted: "#3a3f45" })
    property bool animate: true
    property var workspaces: []   // [{id, active, occupied}]
    property string wifi: ""
    property int volume: -1
    property bool muted: false
    property int battery: -1
    property int ai: -1           // AI usage percent, -1 hides it
    property string aiName: "claude"
    property var apps: []         // [{icon, view}]: the app row, each opens its island view
    property int appIndex: -1     // highlighted button (keyboard or hover), -1 none
    readonly property alias appsItem: appsPill  // for the window's input mask
    readonly property string mono: "JetBrainsMono Nerd Font"
    implicitHeight: 54

    signal workspaceClicked(int id)
    signal appClicked(string view)

    Glass {
        id: left
        pal: bar.pal; tint: 0.72
        x: 24; y: 14; height: 40; width: lrow.width + 18
        Row {
            id: lrow
            x: 6; anchors.verticalCenter: parent.verticalCenter; spacing: 10
            Rectangle { // the droplet
                width: 28; height: 28; radius: 14
                gradient: Gradient { GradientStop { position: 0; color: bar.pal.accent } GradientStop { position: 1; color: Qt.darker(bar.pal.accent, 1.6) } }
                Canvas {
                    anchors.centerIn: parent; width: 14; height: 14
                    onPaint: { const c = getContext("2d"); c.reset(); c.fillStyle = "#101316"; c.beginPath(); c.moveTo(7, 0.5)
                        c.bezierCurveTo(10, 4.5, 12.5, 7.4, 12.5, 9.6); c.arc(7, 9.6, 5.5, 0, Math.PI); c.bezierCurveTo(1.5, 7.4, 4, 4.5, 7, 0.5); c.fill() }
                }
            }
            Row {
                spacing: 6; anchors.verticalCenter: parent.verticalCenter
                Repeater {
                    model: bar.workspaces
                    Rectangle {
                        height: 8; radius: 4; anchors.verticalCenter: parent.verticalCenter
                        width: modelData.active ? 30 : 8
                        Behavior on width { enabled: bar.animate; SpringAnimation { spring: 5; damping: 0.3 } }
                        color: modelData.active ? bar.pal.accent : Qt.rgba(0.89, 0.89, 0.85, modelData.occupied ? 0.55 : 0.25)
                        gradient: modelData.active ? g : null
                        Gradient { id: g; orientation: Gradient.Horizontal; GradientStop { position: 0; color: bar.pal.accent } GradientStop { position: 1; color: bar.pal.cyan } }
                        MouseArea { anchors.fill: parent; anchors.margins: -6; onClicked: bar.workspaceClicked(modelData.id) }
                    }
                }
            }
        }
    }

    Glass { // the app row: the Fluid showcase apps, one click away
        id: appsPill
        visible: bar.apps.length > 0
        pal: bar.pal; tint: 0.72
        x: left.x + left.width + 10; y: 14; height: 40; width: arow.width + 12
        Row {
            id: arow
            anchors.centerIn: parent; spacing: 2
            Repeater {
                model: bar.apps
                Rectangle {
                    id: btn
                    required property var modelData
                    required property int index
                    property bool lit: bar.appIndex === index || hover.containsMouse
                    width: 32; height: 30; radius: 15
                    color: lit ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
                    Behavior on color { enabled: bar.animate; ColorAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent; text: btn.modelData.icon
                        color: btn.lit ? bar.pal.accent : bar.pal.fg
                        font.family: bar.mono; font.pixelSize: 15
                    }
                    MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; onClicked: bar.appClicked(btn.modelData.view) }
                }
            }
        }
    }

    Glass {
        id: right
        pal: bar.pal; tint: 0.72
        anchors.right: parent.right; anchors.rightMargin: 24; y: 14; height: 40; width: rrow.width + 28
        Row {
            id: rrow
            anchors.centerIn: parent; spacing: 16
            Text { visible: bar.wifi !== ""; text: bar.wifi; color: bar.pal.fg; font.family: bar.mono; font.pixelSize: 13 }
            Text { visible: bar.volume >= 0; text: (bar.muted ? "󰝟" : "󰕾") + "  " + bar.volume; color: bar.pal.fg; font.family: bar.mono; font.pixelSize: 13 }
            Text { visible: bar.battery >= 0; text: "󰁹 " + bar.battery; color: bar.battery <= 15 ? bar.pal.red : bar.pal.fg; font.family: bar.mono; font.pixelSize: 13 }
            Row {
                visible: bar.ai >= 0; spacing: 7
                Item {
                    width: 20; height: 20; anchors.verticalCenter: parent.verticalCenter
                    Canvas {
                        anchors.fill: parent
                        property real p: bar.ai / 100
                        onPChanged: requestPaint()
                        onPaint: { const c = getContext("2d"); c.reset(); c.lineWidth = 3
                            c.strokeStyle = "rgba(255,255,255,0.1)"; c.beginPath(); c.arc(10, 10, 8, 0, 2 * Math.PI); c.stroke()
                            c.strokeStyle = bar.ai >= 85 ? bar.pal.red : bar.pal.accent; c.beginPath(); c.arc(10, 10, 8, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * p); c.stroke() }
                    }
                }
                Text { text: bar.aiName + " " + bar.ai + "%"; color: bar.pal.fg; font.family: bar.mono; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
            }
        }
    }
}
