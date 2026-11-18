import QtQuick

// The Fluid dock: a glass pill at the bottom, pinned apps then running ones, a dot under what is open.
// Keyboard: ❖ ; u k (or fluidity-island dock) lights it; ← → pick, ↵ opens or focuses, esc leaves.
Item {
    id: dk
    property var pal: ({ accent: "#d7e59b", cyan: "#c2e6d6", fg: "#e3e4da", dim: "#878880" })
    property bool animate: true
    property var items: []       // [{title, image, glyph, running, focused}]
    property int sel: -1
    property bool active: false  // has the keyboard
    readonly property alias pill: glass
    signal clicked(int index)
    Glass {
        id: glass
        pal: dk.pal; tint: 0.72; radius: 26
        anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; anchors.bottomMargin: 10
        height: 64; width: row.width + 20
        border.color: dk.active ? Qt.rgba(Qt.color(dk.pal.accent).r, Qt.color(dk.pal.accent).g, Qt.color(dk.pal.accent).b, 0.6) : Qt.rgba(1, 1, 1, 0.07)
        Row {
            id: row; anchors.centerIn: parent; spacing: 6
            Repeater {
                model: dk.items
                Item {
                    readonly property bool lit: index === dk.sel
                    width: 48; height: 56
                    Rectangle {
                        width: 46; height: 46; radius: 16; anchors.horizontalCenter: parent.horizontalCenter; y: parent.lit ? -6 : 0
                        Behavior on y { enabled: dk.animate; SpringAnimation { spring: 5; damping: 0.35 } }
                        color: parent.lit ? "transparent" : Qt.rgba(1, 1, 1, 0.06)
                        Grad { anchors.fill: parent; radius: 16; pal: dk.pal; visible: parent.parent.lit }
                        Image { anchors.fill: parent; anchors.margins: 7; source: modelData.image || ""; visible: !!modelData.image; sourceSize.width: 64; sourceSize.height: 64; smooth: true; asynchronous: true }
                        Text { anchors.centerIn: parent; visible: !modelData.image; text: modelData.glyph || (modelData.title || "?")[0]; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20
                            color: parent.parent.lit ? "#101316" : dk.pal.fg }
                    }
                    Rectangle { anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom; height: 4; radius: 2; visible: !!modelData.running
                        width: modelData.focused ? 14 : 4; color: modelData.focused ? dk.pal.accent : dk.pal.dim }
                    MouseArea { anchors.fill: parent; onClicked: dk.clicked(index) }
                }
            }
        }
    }
    Rectangle { // the selected app's name, above the pill
        visible: dk.sel >= 0 && dk.sel < dk.items.length
        anchors.bottom: glass.top; anchors.bottomMargin: 10
        x: glass.x + 10 + dk.sel * 54 + 24 - width / 2
        height: 28; width: nm.implicitWidth + 24; radius: 14; color: Qt.rgba(0.04, 0.05, 0.055, 0.9)
        Text { id: nm; anchors.centerIn: parent; text: (dk.items[dk.sel] || {}).title || ""; color: dk.pal.fg; font.family: "Geist"; font.pixelSize: 13 }
    }
}
