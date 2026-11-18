// Axarva's eww sidebar (dotfiles-2.0, eww-1920): six boxes down the left at his exact geometry (x 10, 300 wide):
// date 80x80, weather 215x80, time 300x135, player 300x110, sliders 300x205, search + power 300x153.
import QtQuick
import "Pal.js" as P

Item {
    id: root
    FontLoader { id: featherLoader; source: "feather.ttf" }
    property string featherFont: featherLoader.name
    property string day: "31"
    property string month: "Dec"
    property string hours: "21"
    property string minutes: "06"
    property string weekday: "Thursday"
    property int weatherGlyph: 0xe313
    property string temp: "8°C"
    property string cond: "Mist"
    property string art: ""
    property string title: "In The..."
    property bool playing: true
    property real volume: 0.85
    property real brightness: 1
    property real ram: 0.3
    property real battery: 0.98
    signal prev()
    signal toggle()
    signal next()
    signal search()
    signal power(string action)
    signal volumeSet(real v)
    signal brightnessSet(real v)

    implicitWidth: 320; implicitHeight: 760

    Panel { x: 10; y: 45; width: 80; height: 80
        Column { anchors.centerIn: parent
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.day; color: P.red; font.family: P.sans; font.pixelSize: 35 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.month; color: P.fg; font.family: P.sans; font.pixelSize: 14 } } }

    Panel { x: 95; y: 45; width: 215; height: 80
        Text { x: 22; anchors.verticalCenter: parent.verticalCenter; text: P.g(root.weatherGlyph); color: P.blue
               font.family: P.icons; font.pixelSize: 45 }
        Column { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter } spacing: 6
            Text { anchors.right: parent.right; text: root.temp + "  " + P.g(0xf2c9); color: P.fg; font.family: P.sans; font.pixelSize: 16 }
            Text { anchors.right: parent.right; text: root.cond; color: P.red; font.family: P.sans; font.pixelSize: 16 } } }

    Panel { x: 10; y: 130; width: 300; height: 135
        Column { anchors.centerIn: parent
            Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 18
                Text { text: root.hours; color: P.fg; font.family: P.sans; font.pixelSize: 60 }
                Text { text: root.minutes; color: P.red; font.family: P.sans; font.pixelSize: 60 } }
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.weekday; color: P.green; font.family: P.sans; font.pixelSize: 16 } } }

    Panel { x: 10; y: 270; width: 300; height: 110
        Rectangle { x: 15; anchors.verticalCenter: parent.verticalCenter; width: 80; height: 80; radius: 6; color: "#1d1d1d"; clip: true
            Image { anchors.fill: parent; source: root.art; fillMode: Image.PreserveAspectCrop; visible: root.art !== "" } }
        Column { x: 110; width: 175; anchors.verticalCenter: parent.verticalCenter; spacing: 14
            Text { width: parent.width; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; text: root.title || "Nothing playing"
                   color: P.fg; font.family: P.sans; font.pixelSize: 15 }
            Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 30
                Repeater { model: [[0xf04ae, "prev"], [0, "toggle"], [0xf04ad, "next"]]
                    Text { required property var modelData
                        text: modelData[1] === "toggle" ? P.g(root.playing ? 0xf03e4 : 0xf040a) : P.g(modelData[0])
                        color: modelData[1] === "toggle" ? P.red : P.fg; font.family: P.icons; font.pixelSize: 16
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: parent.modelData[1] === "prev" ? root.prev() : parent.modelData[1] === "next" ? root.next() : root.toggle() } } } } } }

    Panel { x: 10; y: 385; width: 300; height: 205
        Column { anchors.centerIn: parent; spacing: 17
            Repeater {
                model: [[0xf7ca, P.purple, root.volume, 25, "vol"], [0xf5df, P.blue, root.brightness, 25, "bright"],
                        [0xf85a, P.red, root.ram, 30, "ram"], [0xf06a5, P.green, root.battery, 22, "bat"]]
                Row { required property var modelData; spacing: 22
                    Text { width: 30; horizontalAlignment: Text.AlignHCenter; anchors.verticalCenter: parent.verticalCenter
                           text: P.v2(parent.modelData[0]); color: parent.modelData[1]; font.family: P.icons; font.pixelSize: parent.modelData[3] }
                    Item { width: 190; height: 26; anchors.verticalCenter: parent.verticalCenter
                        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 6; radius: 3; color: P.trough }
                        Rectangle { anchors.verticalCenter: parent.verticalCenter; width: parent.width * Math.max(0, Math.min(1, parent.parent.modelData[2]))
                                    height: 6; radius: 3; color: parent.parent.modelData[1] }
                        MouseArea { anchors.fill: parent; enabled: ["vol", "bright"].indexOf(parent.parent.modelData[4]) >= 0
                            onClicked: m => { const v = m.x / width; parent.parent.modelData[4] === "vol" ? root.volumeSet(v) : root.brightnessSet(v) } } } } } } }

    Panel { x: 10; y: 595; width: 300; height: 153
        Rectangle { x: 30; y: 20; width: 240; height: 36; radius: 12; color: P.search
            Text { anchors.centerIn: parent; text: P.g(0xf422) + "  Search..."; color: sh.containsMouse ? P.red : P.fg; font.family: P.sans; font.pixelSize: 13 }
            MouseArea { id: sh; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.search() } }
        Row { anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 22 } spacing: 26
            Repeater { model: [["power", P.red], ["reboot", P.blue], ["lock", P.fg], ["suspend", P.purple], ["logout", P.green]]
                Text { required property var modelData
                    text: P.g(P.fe[modelData[0]]); color: pm.containsMouse ? (modelData[0] === "power" ? P.fg : P.red) : modelData[1]
                    font.family: root.featherFont; font.pixelSize: 30
                    MouseArea { id: pm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.power(parent.modelData[0]) } } } } }
}
