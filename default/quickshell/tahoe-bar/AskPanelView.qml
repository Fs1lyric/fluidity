import QtQuick
import "AskMarkdown.js" as Markdown

// The Golden Gate answer window (Siri's, from the macOS 27 keynote), answering with Claude:
// dark Liquid Glass, a round X at the top left, expand arrows at the top right (opens the
// conversation in Claude Code), the question as a right-aligned grey bubble, the answer as
// Markdown, and an "Ask Claude" capsule at the bottom for follow-ups.
// Plain QtQuick so it renders offscreen; Spotlight.qml runs the asks and moves the window.
//
// A message: { role: "user" | "claude" | "error", text }.
Item {
    id: root

    property var messages: []
    property bool busy: false
    property bool canExpand: true

    signal closeRequested()
    signal expandRequested()
    signal followUp(string text)
    signal dragBy(real dx, real dy)

    function focusInput() { input.forceActiveFocus() }

    function family(...names) { const have = Qt.fontFamilies(); return names.find(n => have.includes(n)) ?? names[names.length - 1]; }
    readonly property string face: family("SF Pro Text", "SF Pro", "Inter")   // SF Pro if installed
    readonly property color ink: "#ffffff"
    readonly property color secondary: Qt.rgba(1, 1, 1, 0.5)

    width: 340
    height: 500

    LiquidGlass { anchors.fill: parent; radius: 26 }

    MouseArea {   // drag the window by any bare glass
        anchors.fill: parent
        property real px
        property real py
        onPressed: m => { px = m.x; py = m.y; }
        onPositionChanged: m => root.dragBy(m.x - px, m.y - py)
    }

    component RoundButton: Item {
        id: btn
        property string glyph: "close"
        signal clicked()
        width: 30; height: 30
        opacity: enabled ? 1 : 0.4
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: hover.containsMouse ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(1, 1, 1, 0.12)
            border { width: 1; color: Qt.rgba(1, 1, 1, 0.10) }
        }
        Canvas {
            anchors.fill: parent
            onPaint: {
                const c = getContext("2d");
                c.reset();
                c.strokeStyle = "rgba(255,255,255,0.88)";
                c.lineWidth = 1.7;
                c.lineCap = "round";
                c.lineJoin = "round";
                c.beginPath();
                if (btn.glyph === "close") {   // SF "xmark"
                    c.moveTo(10.5, 10.5); c.lineTo(19.5, 19.5);
                    c.moveTo(19.5, 10.5); c.lineTo(10.5, 19.5);
                } else {                        // SF "arrow.up.left.and.arrow.down.right"
                    c.moveTo(16.5, 13.5); c.lineTo(20.5, 9.5);
                    c.moveTo(16.8, 9.5); c.lineTo(20.5, 9.5); c.lineTo(20.5, 13.2);
                    c.moveTo(13.5, 16.5); c.lineTo(9.5, 20.5);
                    c.moveTo(9.5, 16.8); c.lineTo(9.5, 20.5); c.lineTo(13.2, 20.5);
                }
                c.stroke();
            }
        }
        MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.clicked()
        }
    }

    RoundButton { x: 12; y: 12; glyph: "close"; onClicked: root.closeRequested() }
    RoundButton {
        x: root.width - 12 - width; y: 12
        glyph: "expand"
        enabled: root.canExpand
        onClicked: root.expandRequested()
    }

    Flickable {
        id: flick
        y: 52
        width: parent.width
        height: parent.height - y - 58
        contentHeight: column.height + 12
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: column
            x: 20
            width: flick.width - 40
            spacing: 14

            Repeater {
                model: root.messages
                delegate: Item {
                    id: msg
                    required property var modelData
                    readonly property bool mine: modelData.role === "user"
                    width: column.width
                    height: mine ? bubble.height : answer.height

                    Rectangle {   // the question: a right-aligned grey bubble
                        id: bubble
                        visible: msg.mine
                        anchors.right: parent.right
                        width: Math.min(asked.implicitWidth, column.width * 0.78 - 24) + 24
                        height: asked.height + 14
                        radius: 16
                        color: Qt.rgba(1, 1, 1, 0.16)
                        Text {
                            id: asked
                            x: 12; y: 7
                            width: Math.min(implicitWidth, column.width * 0.78 - 24)
                            text: msg.mine ? msg.modelData.text : ""
                            textFormat: Text.PlainText
                            wrapMode: Text.Wrap
                            font { family: root.face; pixelSize: 13; weight: Font.Medium }
                            color: Qt.rgba(1, 1, 1, 0.88)
                        }
                    }
                    TextEdit {   // the answer, as Markdown (selectable, so it can be copied)
                        id: answer
                        visible: !msg.mine
                        width: parent.width
                        readOnly: true
                        selectByMouse: true
                        textFormat: msg.modelData.role === "claude" ? TextEdit.RichText : TextEdit.PlainText
                        text: msg.mine ? "" : msg.modelData.role === "claude" ? Markdown.toHtml(msg.modelData.text)
                                                                              : msg.modelData.text
                        wrapMode: TextEdit.Wrap
                        font { family: root.face; pixelSize: 15 }
                        color: msg.modelData.role === "error" ? Qt.rgba(1, 0.55, 0.5, 0.95) : root.ink
                        selectionColor: Qt.rgba(1, 1, 1, 0.28)
                        selectedTextColor: root.ink
                        onLinkActivated: link => Qt.openUrlExternally(link)
                    }
                }
            }

            Text {
                visible: root.busy
                text: "Thinking…"
                font { family: root.face; pixelSize: 15 }
                color: root.secondary
                SequentialAnimation on opacity {
                    running: root.busy
                    loops: Animation.Infinite
                    NumberAnimation { from: 1; to: 0.35; duration: 700; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.35; to: 1; duration: 700; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // New question in: scroll so the bubble and "Thinking…" show; answers then read down.
    onMessagesChanged: if (messages.length && messages[messages.length - 1].role === "user")
        Qt.callLater(() => flick.contentY = Math.max(0, flick.contentHeight - flick.height))

    Rectangle {   // follow-ups
        x: 14
        y: root.height - 14 - height
        width: root.width - 28
        height: 34
        radius: 17
        color: Qt.rgba(1, 1, 1, 0.10)
        border { width: 1; color: Qt.rgba(1, 1, 1, 0.08) }

        TextInput {
            id: input
            anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 14
                      verticalCenter: parent.verticalCenter }
            clip: true
            font { family: root.face; pixelSize: 13 }
            color: root.ink
            selectionColor: Qt.rgba(1, 1, 1, 0.28)
            cursorDelegate: Rectangle { width: 1.5; color: Qt.rgba(1, 1, 1, 0.85) }
            Text {
                visible: input.text === ""
                text: "Ask Claude"
                font: input.font
                color: Qt.rgba(1, 1, 1, 0.40)
            }
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) root.closeRequested();
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (!root.busy && input.text.trim() !== "") {
                        root.followUp(input.text.trim());
                        input.text = "";
                    }
                } else return;
                event.accepted = true;
            }
        }
    }
}
