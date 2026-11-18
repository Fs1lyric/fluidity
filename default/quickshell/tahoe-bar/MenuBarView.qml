import QtQuick

// The macOS Tahoe menu bar, drawn as plain QtQuick so it renders offscreen too
// (~/claude/archy-cleanup/tahoe/render-claude). Bar.qml feeds it and owns the menus.
//
// Tahoe: no bar background, only a faint dark gradient for legibility on light wallpapers;
// white 13 px text with 10 px of padding per title; Apple menu, bold app name, then the app's
// menus. Right side: Spotlight, Control Center and the clock. The open item sits on a light
// glass capsule 20 px tall that reaches 15 px past the title on each side.
Item {
    id: bar

    // Index 0 is the Apple menu (drawn as the logo), 1 the app name (bold), then the app's menus.
    property var titles: []
    property int openIndex: -1
    // "spotlight", "control" or "clock" while its panel is open.
    property string openStatus: ""
    property string clockText: ""
    // Extra status items from System Settings > Menu Bar, left of Spotlight, in order:
    //   { id, icon (image url) or glyph: "robot", text?, eye? (robot eye colour), dim? }
    property var extras: []
    property string openExtra: ""

    signal titlePressed(int index)
    signal titleEntered(int index)
    signal statusPressed(string name)
    // x and width of the pressed item in bar coordinates, so its menu can line up under it.
    signal extraPressed(string id, real x, real width)

    implicitHeight: 24

    readonly property color ink: "white"
    readonly property color capsule: Qt.rgba(1, 1, 1, 0.17)

    // Where title i's text (or the logo) starts, in bar coordinates: menus line up under it.
    function titleTextX(i) {
        const c = titleCells.itemAt(i);
        return c ? menus.x + c.x + 10 : 0;
    }

    // Left edge of extra item ID in bar coordinates (-1 when it isn't shown).
    function extraX(id) {
        for (let i = 0; i < extraCells.count; i++) {
            const c = extraCells.itemAt(i);
            if (c && c.modelData.id === id) return c.mapToItem(bar, 0, 0).x;
        }
        return -1;
    }

    Rectangle {   // solid bar (was a see-through gradient; backup MenuBarView.qml.before-solid)
        anchors.fill: parent
        color: "#000000"
    }

    // ---- left: Apple menu, app name, menus -----------------------------------------------

    Row {
        id: menus
        x: 8
        height: bar.height

        Repeater {
            id: titleCells
            model: bar.titles

            Item {
                id: cell
                required property string modelData
                required property int index
                readonly property bool isLogo: index === 0
                readonly property real contentWidth: isLogo ? 15 : label.implicitWidth

                width: contentWidth + 20
                height: bar.height

                Rectangle {
                    visible: bar.openIndex === cell.index
                    anchors.centerIn: parent
                    width: cell.contentWidth + (cell.isLogo ? 26 : 30)
                    height: 20
                    radius: 10
                    color: bar.capsule
                }

                Image {
                    visible: cell.isLogo
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -1
                    width: 15
                    height: 17
                    fillMode: Image.PreserveAspectFit
                    source: cell.isLogo ? "apple-logo.svg" : ""
                    sourceSize: Qt.size(60, 68)
                    smooth: true
                }

                Text {
                    id: label
                    visible: !cell.isLogo
                    anchors.centerIn: parent
                    text: cell.isLogo ? "" : cell.modelData
                    color: bar.ink
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: cell.index === 1 ? Font.Bold : Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onPressed: bar.titlePressed(cell.index)
                    onEntered: bar.titleEntered(cell.index)
                }
            }
        }
    }

    // ---- right: Spotlight, Control Center, clock -----------------------------------------

    Row {
        id: statusRow
        anchors.right: parent.right
        anchors.rightMargin: 4
        height: bar.height

        Repeater {
            id: extraCells
            model: bar.extras

            Item {
                id: extra
                required property var modelData
                readonly property bool robot: modelData.glyph === "robot"
                readonly property bool hasText: !!modelData.text
                readonly property real contentWidth: (robot ? 17 : 15) + (hasText ? 5 + extraText.implicitWidth : 0)

                width: contentWidth + 20
                height: bar.height
                opacity: modelData.dim ? 0.5 : 1

                Rectangle {
                    visible: bar.openExtra === extra.modelData.id
                    anchors.centerIn: parent
                    width: extra.contentWidth + 24
                    height: 20
                    radius: 10
                    color: bar.capsule
                }

                Row {
                    anchors.centerIn: parent
                    spacing: 5

                    // Robot: antenna, rounded head, two eyes tinted by the worst AI limit.
                    Canvas {
                        visible: extra.robot
                        width: 17
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        property color eye: extra.modelData.eye ?? bar.ink
                        onEyeChanged: requestPaint()
                        onPaint: {
                            const c = getContext("2d");
                            c.reset();
                            c.strokeStyle = bar.ink;
                            c.fillStyle = bar.ink;
                            c.lineWidth = 1.4;
                            c.lineCap = "round";
                            c.beginPath();                       // antenna
                            c.moveTo(8.5, 4.2);
                            c.lineTo(8.5, 2.2);
                            c.stroke();
                            c.beginPath();
                            c.arc(8.5, 1.6, 1.3, 0, Math.PI * 2);
                            c.fill();
                            c.beginPath();                       // head
                            c.roundedRect(2.2, 4.7, 12.6, 10.1, 3.4, 3.4);
                            c.stroke();
                            c.fillRect(0, 8.2, 1.4, 3.6);         // ears
                            c.fillRect(15.6, 8.2, 1.4, 3.6);
                            c.fillStyle = eye;                   // eyes
                            c.beginPath();
                            c.arc(6.2, 9.3, 1.65, 0, Math.PI * 2);
                            c.arc(10.8, 9.3, 1.65, 0, Math.PI * 2);
                            c.fill();
                            c.fillStyle = bar.ink;               // mouth
                            c.fillRect(6.4, 12.1, 4.2, 1.1);
                        }
                    }

                    Image {
                        visible: !extra.robot
                        width: 15
                        height: 15
                        anchors.verticalCenter: parent.verticalCenter
                        source: extra.robot ? "" : (extra.modelData.icon ?? "")
                        sourceSize: Qt.size(30, 30)
                        smooth: true
                    }

                    Text {
                        id: extraText
                        visible: extra.hasText
                        anchors.verticalCenter: parent.verticalCenter
                        text: extra.modelData.text ?? ""
                        color: bar.ink
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.features: { "tnum": 1 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: {
                        const p = extra.mapToItem(bar, 0, 0);
                        bar.extraPressed(extra.modelData.id, p.x, extra.width);
                    }
                }
            }
        }

        Repeater {
            model: ["spotlight", "control", "clock"]

            Item {
                id: status
                required property string modelData
                readonly property real contentWidth: modelData === "clock" ? clock.implicitWidth
                                                   : modelData === "control" ? 17 : 15

                width: contentWidth + 20
                height: bar.height

                Rectangle {
                    visible: bar.openStatus === status.modelData
                    anchors.centerIn: parent
                    width: status.contentWidth + (status.modelData === "clock" ? 20 : 24)
                    height: 20
                    radius: 10
                    color: bar.capsule
                }

                // Magnifying glass.
                Canvas {
                    visible: status.modelData === "spotlight"
                    anchors.centerIn: parent
                    width: 15
                    height: 15
                    onPaint: {
                        const c = getContext("2d");
                        c.reset();
                        c.strokeStyle = bar.ink;
                        c.lineCap = "round";
                        c.lineWidth = 1.6;
                        c.beginPath();
                        c.arc(6.2, 6.2, 5.1, 0, Math.PI * 2);
                        c.stroke();
                        c.lineWidth = 1.8;
                        c.beginPath();
                        c.moveTo(10.0, 10.0);
                        c.lineTo(13.9, 13.9);
                        c.stroke();
                    }
                }

                // Control Center: two toggles, the top one off, the bottom one on.
                Canvas {
                    visible: status.modelData === "control"
                    anchors.centerIn: parent
                    width: 17
                    height: 15
                    onPaint: {
                        const c = getContext("2d");
                        c.reset();
                        c.fillStyle = bar.ink;
                        c.strokeStyle = bar.ink;
                        c.lineWidth = 1.3;
                        c.beginPath();
                        c.roundedRect(0.65, 0.65, 15.7, 5.9, 2.95, 2.95);
                        c.stroke();
                        c.beginPath();
                        c.arc(3.7, 3.6, 1.75, 0, Math.PI * 2);
                        c.fill();
                        c.beginPath();
                        c.roundedRect(0, 8.4, 17, 6.6, 3.3, 3.3);
                        c.fill();
                        c.globalCompositeOperation = "destination-out";
                        c.beginPath();
                        c.arc(13.3, 11.7, 1.85, 0, Math.PI * 2);
                        c.fill();
                    }
                }

                Text {
                    id: clock
                    visible: status.modelData === "clock"
                    anchors.centerIn: parent
                    text: bar.clockText
                    color: bar.ink
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: bar.statusPressed(status.modelData)
                }
            }
        }
    }
}
