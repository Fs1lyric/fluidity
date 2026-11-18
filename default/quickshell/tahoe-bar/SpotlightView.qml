import QtQuick

// macOS 27 "Golden Gate" Spotlight, drawn at macOS point sizes on Liquid Glass. Three looks:
//   empty     a 520 x 86 capsule: "Search or Ask" and a mic glyph, no magnifier;
//   question  the capsule grows with the wrapped text, a grey "— Ask Claude" follows it, and a
//             small "Show Results" pill floats below (Return asks Claude, Down shows results);
//   results   the capsule morphs into one rounded card: magnifier + text with a grey inline
//             completion, a row of category chips, then a flat list (no headers, no preview).
// Plain QtQuick (no Quickshell types) so it renders offscreen: see
// ~/claude/archy-cleanup/search/render. Spotlight.qml feeds it rows and does the work.
//
// A row: { title, subtitle, iconUrl, trailing (grey text at the right), badge (boxed text) }.
Item {
    id: root

    property var rows: []
    property int selected: 0
    property alias text: input.text
    property bool question: false        // the text reads as a question (Spotlight.qml decides)
    property bool showResults: false     // the question state was asked to show its results
    property var chips: []               // category names, in order
    property string filter: ""           // the active chip, or ""
    property string appearance: "dark"   // or "light"
    property string pillIcon: ""         // Finder's icon for the Show Results pill
    property bool animate: true

    signal activated(int index, bool reveal)
    signal askRequested()
    signal webRequested()
    signal filterPicked(string name)
    signal dismissed()

    function focusInput() { input.forceActiveFocus() }
    // Back to the empty capsule without animating from whatever was showing last time.
    function reset() {
        animate = false;
        input.text = "";
        showResults = false;
        selected = 0;
        list.contentY = 0;
        animate = true;
    }

    readonly property string mode: question && !showResults && text.trim() !== "" ? "question"
                                 : rows.length ? "results" : text === "" ? "empty" : "typing"

    // ---- look -------------------------------------------------------------------------
    readonly property bool dark: appearance !== "light"
    // SF Pro when it is installed (AUR apple-fonts), else Inter. Apple switches from the Text
    // cut to the Display cut at 20 pt; Inter Display matches SF Pro Display's widths.
    function family(...names) { const have = Qt.fontFamilies(); return names.find(n => have.includes(n)) ?? names[names.length - 1]; }
    readonly property string face: family("SF Pro Text", "SF Pro", "Inter")
    readonly property string displayFace: family("SF Pro Display", "SF Pro", "Inter Display")
    readonly property color ink: dark ? "#ffffff" : Qt.rgba(0, 0, 0, 0.85)
    readonly property color secondary: dark ? Qt.rgba(1, 1, 1, 0.50) : Qt.rgba(0, 0, 0, 0.45)
    readonly property color hint: dark ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.32)
    readonly property color faint: dark ? Qt.rgba(1, 1, 1, 0.34) : Qt.rgba(0, 0, 0, 0.26)
    readonly property color hairline: dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08)
    readonly property color chipFill: dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.55)
    readonly property color chipInk: dark ? Qt.rgba(1, 1, 1, 0.60) : Qt.rgba(0, 0, 0, 0.42)
    readonly property color chipOnFill: dark ? Qt.rgba(1, 1, 1, 0.26) : Qt.rgba(0, 0, 0, 0.13)
    readonly property color selection: dark ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.07)

    // ---- geometry (pt = px on this 1x screen) -----------------------------------------
    readonly property int cardWidth: 520
    readonly property int capsuleHeight: 86
    readonly property int barHeight: 46        // the search row of the results card
    readonly property int listTop: 82
    readonly property int pitch: 45
    readonly property int maxRows: 8
    readonly property int bottomPad: 6
    readonly property real lineHeight: metrics.height
    readonly property real capsulePad: (capsuleHeight - lineHeight) / 2

    // Where the text ends, for the inline completion and the "— Ask Claude" suffix.
    readonly property rect textEnd: {
        input.text; input.width; input.contentHeight; input.wrapMode;
        return input.positionToRectangle(input.length);
    }
    readonly property bool suffixFits: textEnd.x + 7 + suffix.implicitWidth <= input.width
    readonly property int questionLines: Math.max(1, Math.round(input.contentHeight / lineHeight))
                                         + (suffixFits ? 0 : 1)
    readonly property real cardHeight: mode === "results"
        ? listTop + Math.min(rows.length, maxRows) * pitch + bottomPad
        : mode === "question" ? 2 * capsulePad + questionLines * lineHeight
        : capsuleHeight

    width: cardWidth
    height: card.height + (mode === "question" ? 12 + pill.height : 0)
    onRowsChanged: if (selected >= rows.length) selected = 0
    onQuestionChanged: if (!question) showResults = false

    FontMetrics { id: metrics; font: input.font }

    Item {
        id: card
        width: root.cardWidth
        height: root.cardHeight
        // The capsule-to-card morph settles with a small spring overshoot, as macOS does.
        Behavior on height { enabled: root.animate; NumberAnimation { duration: 340; easing.type: Easing.OutBack; easing.overshoot: 0.7 } }

        LiquidGlass {
            anchors.fill: parent
            dark: root.dark
            radius: root.mode === "results" ? 26 : Math.min(card.height / 2, root.capsuleHeight / 2)
        }
        MouseArea { anchors.fill: parent }   // clicks on the glass don't close Spotlight

        // ---- search field ---------------------------------------------------------------
        Canvas {   // SF Symbol "magnifyingglass", results only
            id: glassIcon
            x: 26 - width / 2
            y: root.barHeight / 2 - height / 2
            width: 18; height: 18
            opacity: root.mode === "results" ? 1 : 0
            Behavior on opacity { enabled: root.animate; NumberAnimation { duration: 160 } }
            onPaint: {
                const c = getContext("2d");
                c.reset();
                c.strokeStyle = root.dark ? "rgba(255,255,255,0.72)" : "rgba(0,0,0,0.62)";
                c.lineWidth = 1.8;
                c.lineCap = "round";
                c.beginPath(); c.arc(7.4, 7.4, 5.9, 0, 2 * Math.PI); c.stroke();
                c.beginPath(); c.moveTo(11.8, 11.8); c.lineTo(16.6, 16.6); c.stroke();
            }
            Connections { target: root; function onDarkChanged() { glassIcon.requestPaint() } }
        }

        TextInput {
            id: input
            x: root.mode === "results" ? 48 : 38
            y: root.mode === "results" ? (root.barHeight - root.lineHeight) / 2 : root.capsulePad
            width: root.mode === "results" ? root.cardWidth - x - 20 : root.cardWidth - 2 * 38
            Behavior on x { enabled: root.animate; NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            Behavior on y { enabled: root.animate; NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            wrapMode: root.mode === "question" ? TextInput.Wrap : TextInput.NoWrap
            clip: root.mode !== "question"
            font { family: root.displayFace; pixelSize: 22 }
            color: root.ink
            selectionColor: root.dark ? Qt.rgba(1, 1, 1, 0.28) : Qt.rgba(0, 0.35, 0.9, 0.25)
            selectedTextColor: root.ink
            cursorDelegate: Rectangle {
                width: 2
                color: root.dark ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(0, 0, 0, 0.8)
                SequentialAnimation on opacity {
                    running: input.activeFocus
                    loops: Animation.Infinite
                    PropertyAction { value: 1 }
                    PauseAnimation { duration: 520 }
                    PropertyAction { value: 0 }
                    PauseAnimation { duration: 520 }
                }
            }
            onTextChanged: root.selected = 0

            Keys.onPressed: event => {
                const n = root.rows.length;
                const ctrl = event.modifiers & Qt.ControlModifier;
                const k = event.key;
                const enter = k === Qt.Key_Return || k === Qt.Key_Enter;
                if (k === Qt.Key_Escape) {
                    if (input.text !== "") input.text = "";
                    else if (root.filter !== "") root.filterPicked("");
                    else root.dismissed();
                } else if (root.mode === "question" && enter) root.askRequested();
                else if (root.mode === "question" && k === Qt.Key_Down) root.showResults = true;
                else if (k === Qt.Key_Down) root.selected = n ? Math.min(n - 1, root.selected + 1) : 0;
                else if (k === Qt.Key_Up && root.selected === 0 && root.question && root.showResults)
                    root.showResults = false;
                else if (k === Qt.Key_Up) root.selected = Math.max(0, root.selected - 1);
                else if (enter) root.activated(root.selected, ctrl);
                else if (ctrl && k === Qt.Key_R) root.activated(root.selected, true);
                else if (ctrl && k === Qt.Key_B) root.webRequested();
                else if (ctrl && (k === Qt.Key_1 || k === Qt.Key_2 || k === Qt.Key_4)) {
                    const name = k === Qt.Key_1 ? "Applications" : k === Qt.Key_2 ? "Files" : "Clipboard";
                    root.filterPicked(root.filter === name ? "" : name);
                } else if (k === Qt.Key_Tab || k === Qt.Key_Backtab) {
                    if (!root.chips.length) return;
                    const all = [""].concat(root.chips);
                    const step = k === Qt.Key_Tab ? 1 : -1;
                    root.filterPicked(all[(all.indexOf(root.filter) + step + all.length) % all.length]);
                } else return;
                event.accepted = true;
            }
        }

        Text {   // placeholder: no magnifier, the cursor sits before it
            visible: input.text === "" && root.mode !== "results"
            x: 38
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: root.capsuleHeight / 2
            text: "Search or Ask"
            font { family: root.displayFace; pixelSize: 24 }
            color: root.hint
        }
        Text {   // a chip with no text yet ("Ctrl+4" with nothing typed): what it searches
            visible: input.text === "" && root.mode === "results" && root.filter !== ""
            x: input.x
            y: input.y
            text: "Search " + root.filter
            font: input.font
            color: root.hint
        }

        Canvas {   // SF Symbol "mic", empty capsule only
            id: mic
            x: root.cardWidth - 36 - width / 2
            y: root.capsuleHeight / 2 - height / 2
            width: 20; height: 20
            opacity: root.mode === "empty" ? 1 : 0
            Behavior on opacity { enabled: root.animate; NumberAnimation { duration: 140 } }
            onPaint: {
                const c = getContext("2d");
                c.reset();
                c.strokeStyle = root.dark ? "rgba(255,255,255,0.5)" : "rgba(0,0,0,0.45)";
                c.lineWidth = 1.6;
                c.lineCap = "round";
                c.beginPath(); c.roundedRect(6.6, 1.2, 6.8, 11.2, 3.4, 3.4); c.stroke();
                c.beginPath(); c.arc(10, 8.6, 6.1, 0.05 * Math.PI, 0.95 * Math.PI); c.stroke();
                c.beginPath(); c.moveTo(10, 14.7); c.lineTo(10, 18.6); c.stroke();
            }
            Connections { target: root; function onDarkChanged() { mic.requestPaint() } }
        }

        Text {   // question: "— Ask Claude" follows the text like inline text
            id: suffix
            visible: root.mode === "question"
            x: input.x + (root.suffixFits ? root.textEnd.x + 7 : 0)
            y: input.y + root.textEnd.y + (root.suffixFits ? 0 : root.lineHeight)
            text: "— Ask Claude"
            font: input.font
            color: root.hint
        }

        Text {   // results: grey inline completion " – <selected title>"
            readonly property string title: root.rows[root.selected]?.title ?? ""
            readonly property real room: input.width - root.textEnd.x - 6
            visible: root.mode === "results" && input.text.trim() !== "" && title !== ""
                     && title.toLowerCase() !== input.text.trim().toLowerCase() && room > 40
            x: input.x + root.textEnd.x + 6
            y: input.y
            width: room
            elide: Text.ElideRight
            textFormat: Text.PlainText
            text: "– " + title
            font: input.font
            color: root.faint
        }

        // ---- results: hairline, chips, rows ---------------------------------------------
        Item {
            id: body
            anchors.fill: parent
            opacity: root.mode === "results" ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { enabled: root.animate; NumberAnimation { duration: 180 } }
            clip: true

            Rectangle {
                x: 14
                y: root.barHeight - 1
                width: parent.width - 28
                height: 1
                color: root.hairline
            }

            ListView {
                id: chipRow
                y: 64 - 17 / 2
                width: parent.width
                height: 17
                orientation: ListView.Horizontal
                leftMargin: 16
                rightMargin: 16
                spacing: 8.5
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.chips
                delegate: Rectangle {
                    id: chip
                    required property string modelData
                    readonly property bool on: modelData === root.filter
                    width: label.implicitWidth + 11
                    height: 17
                    radius: 8.5
                    color: on ? root.chipOnFill : root.chipFill
                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: chip.modelData
                        font { family: root.face; pixelSize: 11; weight: chip.on ? Font.Medium : Font.Normal }
                        color: chip.on ? root.ink : root.chipInk
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.filterPicked(chip.on ? "" : chip.modelData)
                    }
                }
            }

            ListView {
                id: list
                y: root.listTop
                width: parent.width
                height: Math.min(root.rows.length, root.maxRows) * root.pitch
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.rows
                currentIndex: root.selected
                highlightFollowsCurrentItem: false
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Item {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool chosen: index === root.selected
                    readonly property string sub: modelData.subtitle ?? ""
                    width: list.width
                    height: root.pitch

                    Rectangle {
                        x: 9
                        width: parent.width - 18
                        height: 44
                        radius: 12
                        color: row.chosen ? root.selection : "transparent"
                    }
                    Image {
                        id: icon
                        x: 16
                        y: (44 - height) / 2
                        width: 26; height: 26
                        sourceSize { width: 52; height: 52 }
                        source: row.modelData.iconUrl ?? ""
                        smooth: true
                        asynchronous: true
                    }
                    Column {
                        x: 58
                        width: (right.visible ? right.x - 10 : parent.width - 16) - x
                        anchors.verticalCenter: parent.top
                        anchors.verticalCenterOffset: 22
                        Text {
                            width: parent.width
                            text: row.modelData.title ?? ""
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font { family: root.face; pixelSize: 15; weight: Font.Medium }
                            color: root.ink
                        }
                        Text {
                            visible: row.sub !== ""
                            width: parent.width
                            text: row.sub
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font { family: root.face; pixelSize: 12 }
                            color: root.secondary
                        }
                    }
                    Item {   // a small rounded badge, or grey text such as a date
                        id: right
                        readonly property string badge: row.modelData.badge ?? ""
                        readonly property string trailing: row.modelData.trailing ?? ""
                        visible: badge !== "" || trailing !== ""
                        x: parent.width - 16 - width
                        y: 22 - height / 2
                        width: badge !== "" ? badgeText.implicitWidth + 10 : trail.implicitWidth
                        height: 18
                        Rectangle {
                            visible: right.badge !== ""
                            anchors.fill: parent
                            radius: 5
                            color: root.chipFill
                            border { width: 1; color: root.hairline }
                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: right.badge
                                font { family: root.face; pixelSize: 11 }
                                color: root.secondary
                            }
                        }
                        Text {
                            id: trail
                            visible: right.badge === ""
                            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                            text: right.trailing
                            font { family: root.face; pixelSize: 12 }
                            color: root.secondary
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.selected = row.index
                        onDoubleClicked: root.activated(row.index, false)
                    }
                }
            }
        }
    }

    // ---- question: the Show Results pill --------------------------------------------------
    Item {
        id: pill
        x: (root.cardWidth - width) / 2
        y: card.height + 12
        width: 16 + 24 + 9 + pillLabel.implicitWidth + 17
        height: 42
        opacity: root.mode === "question" ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { enabled: root.animate; NumberAnimation { duration: 160 } }

        LiquidGlass { anchors.fill: parent; dark: root.dark; radius: 21; strength: 0.72 }
        Image {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 24; height: 24
            sourceSize { width: 48; height: 48 }
            source: root.pillIcon
            smooth: true
        }
        Text {
            id: pillLabel
            x: 16 + 24 + 9
            anchors.verticalCenter: parent.verticalCenter
            text: "Show Results"
            font { family: root.face; pixelSize: 15; weight: Font.Medium }
            color: root.ink
        }
        MouseArea {
            anchors.fill: parent
            onClicked: { root.showResults = true; root.focusInput(); }
        }
    }
}
