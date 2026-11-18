// Axarva's eww dashboard at his exact 1920x1080 geometry (centred on bigger screens), over a blurred, dimmed desktop.
import QtQuick
import "Pal.js" as P

Rectangle {
    id: root
    FontLoader { id: featherLoader; source: "feather.ttf" }
    property string featherFont: featherLoader.name
    property string profile: "profile.png"
    property string name: "Axarva"
    property string subtitle: "That Cat"
    property int weatherGlyph: 0xe37e
    property string temp: "12°C"
    property string cond: "Few Clouds"
    property string line1: "It's a cloudy night"
    property string line2: "How about some hot chocolate and a warm bed?"
    property string quote: "Wisdom begins in wonder."
    property string author: "Socrates"
    property var dirs: [["Desktop", P.blue], ["Documents", P.fg], ["Downloads", P.purple], ["Bin", P.red], ["Dwm", P.fg], ["Repos", P.blue]]
    signal closed()
    signal power(string action)
    signal openDir(string name)
    signal search()
    signal screenshot()
    signal vpn()
    signal incognito()

    implicitWidth: 1920; implicitHeight: 1080
    color: "#80121212"
    focus: true
    Keys.onPressed: e => { if (e.key === Qt.Key_Escape || e.text === "q") { root.closed(); e.accepted = true } }
    MouseArea { anchors.fill: parent; onClicked: root.closed() }

    Item {
        width: 1920; height: 1080; anchors.centerIn: parent
        Panel { x: 390; y: 220; width: 340; height: 520
            Rectangle { x: 70; y: 80; width: 200; height: 200; radius: 100; clip: true; color: "#1d1d1d"
                Image { anchors.fill: parent; source: root.profile; fillMode: Image.PreserveAspectCrop; sourceSize: Qt.size(400, 400) } }
            Text { anchors.horizontalCenter: parent.horizontalCenter; y: 380; text: root.name; color: P.red; font.family: P.sans; font.pixelSize: 36 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; y: 430; text: root.subtitle; color: P.fg; font.family: P.sans; font.pixelSize: 24 } }
        Panel { x: 740; y: 220; width: 410; height: 400
            Text { x: 40; y: 30; text: P.g(root.weatherGlyph); color: P.lav; font.family: P.icons; font.pixelSize: 120 }
            Text { anchors { right: parent.right; rightMargin: 40 } y: 70; text: root.temp + "  " + P.g(0xf2c9); color: P.fg; font.family: P.sans; font.pixelSize: 48 }
            Column { anchors.horizontalCenter: parent.horizontalCenter; y: 225; spacing: 4
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.cond; color: P.red; font.family: P.sans; font.pixelSize: 30 }
                Item { width: 1; height: 14 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.line1; color: P.fg; font.family: P.sans; font.pixelSize: 18 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; width: 390; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
                       text: root.line2; color: P.fg; font.family: P.sans; font.pixelSize: 18 } } }
        Panel { x: 740; y: 630; width: 200; height: 110
            Text { anchors.centerIn: parent; text: P.g(0xf0582); color: P.red; font.family: P.icons; font.pixelSize: 50 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.vpn() } }
        Panel { x: 950; y: 630; width: 200; height: 110
            Text { anchors.centerIn: parent; text: P.v2(0xfaf8); color: P.purple; font.family: P.icons; font.pixelSize: 50 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.incognito() } }
        Panel { x: 1160; y: 220; width: 240; height: 120
            Text { anchors.centerIn: parent; text: P.g(0xf03e); color: P.fg; font.family: P.icons; font.pixelSize: 54 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.screenshot() } }
        Panel { x: 1160; y: 350; width: 240; height: 520
            Column { anchors.centerIn: parent; spacing: 30
                Repeater { model: root.dirs
                    Text { required property var modelData; anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData[0]; color: dm.containsMouse ? P.red : modelData[1]; font.family: P.sans; font.pixelSize: 26
                        MouseArea { id: dm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.openDir(parent.modelData[0]) } } } } }
        Repeater {
            model: [["power", P.red, 220], ["reboot", P.blue, 350], ["lock", P.fg, 482], ["suspend", P.purple, 614], ["logout", P.green, 748]]
            Panel { required property var modelData; x: 1410; y: modelData[2]; width: 120; height: 120
                Text { anchors.centerIn: parent; text: P.g(P.fe[parent.modelData[0]]); font.family: root.featherFont; font.pixelSize: 60
                       color: pw.containsMouse ? (parent.modelData[0] === "power" ? P.fg : P.red) : parent.modelData[1] }
                MouseArea { id: pw; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.power(parent.modelData[0]) } } }
        Panel { x: 390; y: 750; width: 120; height: 122
            Text { anchors.centerIn: parent; text: P.g(0xf422); color: sm.containsMouse ? P.red : P.fg; font.family: P.icons; font.pixelSize: 50 }
            MouseArea { id: sm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.search() } }
        Panel { x: 520; y: 750; width: 630; height: 120
            Text { x: 20; y: 22; width: 590; wrapMode: Text.WordWrap; text: root.quote; color: P.quote; font.family: P.sans; font.pixelSize: 18 }
            Text { anchors { right: parent.right; rightMargin: 20; bottom: parent.bottom; bottomMargin: 18 } text: "- " + root.author
                   color: P.blue; font.family: P.sans; font.pixelSize: 16 } }
    }
}
