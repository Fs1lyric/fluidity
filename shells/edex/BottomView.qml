// eDEX-UI's bottom row: FILESYSTEM (43 % wide, folder grid + mount bar) and the on-screen keyboard.
import QtQuick
import "Pal.js" as P
import "Data.js" as Dt

Item {
    id: root
    property string cwd: "/home/squared"
    property var entries: [".AndroidStudio", ".adobe", ".android", ".anydesk", ".atom", ".audacity-data", ".cache", ".cargo",
                           ".com.privateinternetaccess", ".config", ".cups", ".electron", ".electron-gyp", ".gconf", ".gem"]
    property string mount: "/home"
    property real used: 0.44
    property bool shift: false
    property string pressed: "none"
    signal open(string name)
    signal up()
    signal key(string name)
    implicitWidth: 1920; implicitHeight: 330
    Rectangle { anchors.fill: parent; color: P.black }

    Item {
        id: fs
        x: 10; width: root.width * 0.43; height: parent.height
        Hdr { width: parent.width; leftText: "FILESYSTEM"; rightText: root.cwd }
        Rectangle { x: parent.width - 2; y: 26; width: 2; height: 250; color: P.a(0.3) }
        Flickable {
            x: 0; y: 28; width: parent.width - 10; height: 248; clip: true
            contentHeight: grid.height
            Grid {
                id: grid; columns: Math.floor((fs.width - 10) / 66); rowSpacing: 10
                Item { width: 66; height: 70
                    Image { anchors.horizontalCenter: parent.horizontalCenter; y: 4; width: 34; height: 34; source: "dir.svg"; sourceSize: Qt.size(68, 68); opacity: 0.85 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; y: 44; text: "~"; color: P.c; font.family: P.main; font.pixelSize: 11 }
                    MouseArea { anchors.fill: parent; onClicked: root.up() } }
                Repeater { model: root.entries
                    Item { required property var modelData; width: 66; height: 70
                        Image { anchors.horizontalCenter: parent.horizontalCenter; y: 4; width: 34; height: 34; source: "dir.svg"; sourceSize: Qt.size(68, 68)
                                opacity: (fm.containsMouse ? 1 : 0.7) * (parent.modelData.endsWith("/") || !root.entries.some(e => e.endsWith("/")) ? 1 : 0.45) }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 44; width: 64; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight
                               text: parent.modelData.replace(/\/$/, ""); color: P.c; font.family: P.main; font.pixelSize: 11 }
                        MouseArea { id: fm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onDoubleClicked: root.open(parent.modelData) } } }
            }
        }
        Row {
            y: 288; spacing: 12
            Text { text: "Mount " + root.mount + " used " + Math.round(root.used * 100) + "%"; color: P.c; font.family: P.main; font.pixelSize: 12 }
            Rectangle { width: 260; height: 6; color: P.a(0.2); anchors.verticalCenter: parent.verticalCenter
                Rectangle { width: parent.width * root.used; height: parent.height; color: P.c } }
        }
    }

    // keyboard: eDEX keys are outlined boxes; widths follow the special keys.
    Column {
        x: fs.width + 40; y: 8; spacing: 10
        readonly property real unit: (root.width - fs.width - 80) / 16.4
        Repeater {
            model: Dt.rows
            Row {
                id: krow
                required property var modelData
                required property int index
                spacing: 6
                Repeater {
                    model: krow.modelData
                    Rectangle {
                        required property var modelData
                        required property int index
                        readonly property real u: krow.parent.unit
                        readonly property var arrows: ({ "ESCAPED|-- ICON: ARROW_UP": "▲", "ESCAPED|-- ICON: ARROW_DOWN": "▼",
                                                         "ESCAPED|-- ICON: ARROW_LEFT": "◀", "ESCAPED|-- ICON: ARROW_RIGHT": "▶" })
                        readonly property string label: arrows[modelData] ?? (root.shift && Dt.shifted[krow.index][index] ? Dt.shifted[krow.index][index] : modelData)
                        // row 3's blank key is the bottom half of ENTER; the bottom row's blank key is the space bar
                        readonly property real w: modelData === "" ? (krow.index === 4 ? 6.5 : 1.6)
                            : ({ "ESC": 1.3, "BACK": 1.6, "TAB": 1.5, "ENTER": 1.6, "CAPS": 1.8, "SHIFT": 2.2, "CTRL": 1.4, "FN": 1.1, "ALT GR": 1.4 })[modelData] ?? 1
                        width: u * w - 6; height: 44
                        color: root.pressed === modelData || km.pressed ? P.a(0.35) : "transparent"
                        border.color: P.a(0.45); border.width: 1; radius: 2
                        Text { anchors.centerIn: parent; text: parent.label; color: P.c; font.family: P.main
                               font.pixelSize: parent.label.length > 1 ? 13 : 17 }
                        MouseArea { id: km; anchors.fill: parent
                            onClicked: { if (parent.modelData === "SHIFT") root.shift = !root.shift; else root.key(parent.label) } }
                    }
                }
            }
        }
    }
}
