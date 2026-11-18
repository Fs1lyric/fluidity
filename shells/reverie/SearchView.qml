// chocycat's Polestar search (Super+F1), rebuilt: a dark card with three tabs (Quick Search, Windows,
// Clipboard), the search field, then the results grouped under small grey headers. A calculator answer
// shows as a big number card. Keyboard-only: type to search, Up/Down (or Ctrl+J/K) move, Enter runs,
// Tab / Shift+Tab switch tabs, Esc closes. Pure view: the shell fills `results` from what is typed.
import QtQuick

Rectangle {
    id: s
    property int tab: 0                       // 0 quick, 1 windows, 2 clipboard
    property alias query: input.text
    property var results: []                  // [{ group, title, sub, glyph, run }]
    property int sel: 0
    property string answer: ""                // calculator result, "" when the query is not maths
    signal run(var item)
    signal close()
    readonly property color card: "#1e1a24"
    readonly property color line: "#27222f"
    readonly property color fg: "#f4f3f6"
    readonly property color muted: "#a095b2"
    readonly property color accent: "#9e70d7"
    readonly property string sans: "Figtree"
    readonly property string icons: "Iosevka Nerd Font"
    implicitWidth: 620; implicitHeight: Math.min(560, col.implicitHeight + 24)
    radius: 14; color: "#f2141118"; border.color: s.line; border.width: 1
    onResultsChanged: sel = Math.min(sel, Math.max(0, results.length - 1))
    onTabChanged: sel = 0
    onQueryChanged: sel = 0
    function focusInput() { input.forceActiveFocus() }

    Column {
        id: col
        x: 12; y: 12; width: parent.width - 24; spacing: 10
        Row {
            spacing: 4
            Repeater { model: [["\u{F0349}", "Quick Search"], ["\u{F05B6}", "Windows"], ["\u{F014C}", "Clipboard"]]
                       Rectangle { required property var modelData; required property int index
                                   width: tl.implicitWidth + 24; height: 28; radius: 8; color: s.tab === index ? s.line : "transparent"
                                   Row { id: tl; anchors.centerIn: parent; spacing: 6
                                         Text { text: modelData[0]; font.family: s.icons; font.pixelSize: 12; color: s.tab === index ? s.fg : s.muted; anchors.verticalCenter: parent.verticalCenter }
                                         Text { text: modelData[1]; font.family: s.sans; font.pixelSize: 13; color: s.tab === index ? s.fg : s.muted; anchors.verticalCenter: parent.verticalCenter } } } }
        }
        Rectangle {
            width: parent.width; height: 42; radius: 10; color: s.card
            Text { x: 14; anchors.verticalCenter: parent.verticalCenter; text: "\u{F0349}"; font.family: s.icons; font.pixelSize: 15; color: s.muted }
            TextInput {
                id: input
                x: 40; width: parent.width - 54; anchors.verticalCenter: parent.verticalCenter
                font.family: s.sans; font.pixelSize: 16; color: s.fg; selectionColor: s.accent; clip: true
                focus: true
                Text { visible: !parent.text; text: ["Search apps, maths, commands…", "Search windows…", "Search clipboard…"][s.tab]
                       font: parent.font; color: "#4f455f" }
                Keys.onPressed: e => {
                    const ctrl = e.modifiers & Qt.ControlModifier
                    if (e.key === Qt.Key_Down || (ctrl && e.key === Qt.Key_J)) s.sel = Math.min(s.results.length - 1, s.sel + 1)
                    else if (e.key === Qt.Key_Up || (ctrl && e.key === Qt.Key_K)) s.sel = Math.max(0, s.sel - 1)
                    else if (e.key === Qt.Key_Tab) s.tab = (s.tab + 1) % 3
                    else if (e.key === Qt.Key_Backtab) s.tab = (s.tab + 2) % 3
                    else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { if (s.results[s.sel]) s.run(s.results[s.sel]) }
                    else if (e.key === Qt.Key_Escape) s.close()
                    else return
                    e.accepted = true
                }
            }
        }
        Rectangle {
            visible: s.answer !== ""; width: parent.width; height: 74; radius: 10; color: s.card
            Text { x: 14; y: 10; text: "Calculator"; font.family: s.sans; font.pixelSize: 11; color: s.muted }
            Text { x: 14; y: 28; text: s.answer; font.family: s.sans; font.weight: Font.DemiBold; font.pixelSize: 28; color: s.fg }
        }
        Column {
            width: parent.width; spacing: 2
            Repeater {
                model: s.results.slice(0, 9)
                Column {
                    required property var modelData; required property int index
                    width: parent.width
                    Text { visible: index === 0 || s.results[index - 1].group !== modelData.group; text: modelData.group
                           font.family: s.sans; font.pixelSize: 11; color: s.muted; topPadding: 6; bottomPadding: 4; leftPadding: 4 }
                    Rectangle {
                        width: parent.width; height: 36; radius: 8; color: s.sel === index ? s.line : "transparent"
                        Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: modelData.glyph; font.family: s.icons; font.pixelSize: 15
                               color: s.sel === index ? s.accent : s.muted }
                        Text { x: 40; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 150; elide: Text.ElideRight
                               text: modelData.title; font.family: s.sans; font.pixelSize: 14; color: s.fg }
                        Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; width: 100
                               horizontalAlignment: Text.AlignRight; elide: Text.ElideLeft; text: s.sel === index ? "⏎" : modelData.sub
                               font.family: s.sans; font.pixelSize: 12; color: s.muted }
                    }
                }
            }
        }
        Text { text: "type · ↑↓ move · ⏎ run · tab switch · esc"; font.family: s.sans; font.pixelSize: 10; color: "#4f455f"; leftPadding: 4 }
    }
}
