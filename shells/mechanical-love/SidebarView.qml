// elenapan's "Mechanical Love" sidebar (AwesomeWM, Dec 2018) rebuilt as a pure view: no Quickshell types,
// all data comes in as properties so render/render.py can draw it off-screen.
// Original: github.com/elenapan/dotfiles @6934953 config/awesome/sidebar.lua
import QtQuick

Rectangle {
    id: root
    property string iconDir: "icons/"
    property string weatherDir: "weather/"
    property string font: "Google Sans"
    property string hours: "01"
    property string minutes: "36"
    property string dateText: "Monday, December 24"
    property int dayOfYear: 358
    property string weatherIcon: "mist"
    property string weatherText: "mist 4°C"
    property string title: "Sacred Worlds"
    property string artist: "Blind Guardian"
    property real volume: 0.5
    property bool muted: false
    property real ram: 0.35
    property real temp: 0.65
    property real cpu: 0.45
    property real battery: 0.8
    property bool charging: false
    property bool hasBattery: true
    property string diskFree: "11GB free"
    signal prev()
    signal toggle()
    signal next()
    signal muteClicked()
    signal volumeStep(int dir)
    signal search()
    signal exit()

    // lovelace (elenapan/dotfiles .xfiles/lovelace)
    readonly property color fg: "#fdfdfd"
    readonly property color fgDim: "#bebec1"

    implicitWidth: 300
    implicitHeight: 768
    color: "#1d1f28"

    Column {
        anchors.fill: parent
        anchors.topMargin: Math.max(30, (root.height - 768) / 2 + 30)
        spacing: 0

        Text { color: root.fg; font.family: root.font; horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter; text: root.hours + " " + root.minutes; font.pointSize: 50 }
        Text { color: root.fg; font.family: root.font; horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter; text: root.dateText; font.pointSize: 15; font.weight: Font.Medium; topPadding: 4 }
        Text { color: root.fg; font.family: root.font; horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter; text: root.dayOfYear + " days around the sun"; font.pointSize: 11; topPadding: 2 }

        Item { width: 1; height: 26 }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            Image { sourceSize: Qt.size(80, 80); smooth: true; mipmap: true; source: root.weatherDir + root.weatherIcon + ".png"; width: 28; height: 28; anchors.verticalCenter: parent.verticalCenter }
            Text { text: root.weatherText; color: root.fg; font.family: root.font; font.pointSize: 13; anchors.verticalCenter: parent.verticalCenter }
        }

        Item { width: 1; height: 34 }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 18
            Image { sourceSize: Qt.size(80, 80); smooth: true; mipmap: true; source: root.iconDir + "playerctl_prev.png"; width: 36; height: 36
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.prev() } }
            Image { sourceSize: Qt.size(80, 80); smooth: true; mipmap: true; source: root.iconDir + "playerctl_toggle.png"; width: 36; height: 36
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggle() } }
            Image { sourceSize: Qt.size(80, 80); smooth: true; mipmap: true; source: root.iconDir + "playerctl_next.png"; width: 36; height: 36
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.next() } }
        }
        Text { color: root.fg; font.family: root.font; horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter; text: root.title || "—"; font.pointSize: 13; font.weight: Font.Medium; topPadding: 6
               width: 260; elide: Text.ElideRight }
        Text { color: root.fg; font.family: root.font; horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter; text: root.artist; font.pointSize: 11; width: 260; elide: Text.ElideRight }

        Item { width: 1; height: 30 }
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            Item {
                width: vol.width; height: vol.height
                anchors.horizontalCenter: parent.horizontalCenter
                StatBar { id: vol; iconSource: root.iconDir + (root.muted ? "muted" : "volume") + ".png"; value: root.muted ? 0 : root.volume; barColor: "#79e6f3" }
                MouseArea { anchors.fill: parent; onClicked: root.muteClicked()
                    onWheel: w => root.volumeStep(w.angleDelta.y > 0 ? 1 : -1) }
            }
            // her icon files are named the other way round: cpu.png is the heart, ram.png the chip
            StatBar { iconSource: root.iconDir + ("cpu") + ".png"; value: root.cpu; barColor: "#5adecd" }
            StatBar { iconSource: root.iconDir + ("temperature") + ".png"; value: root.temp; barColor: "#f37f97" }
            StatBar { iconSource: root.iconDir + ("ram") + ".png"; value: root.ram; barColor: "#556fff" }
            StatBar { visible: root.hasBattery; iconSource: root.iconDir + (root.charging ? "battery_charging" : "battery") + ".png"; value: root.battery; barColor: "#c574dd" }
        }

        Item { width: 1; height: 28 }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Image { sourceSize: Qt.size(80, 80); smooth: true; mipmap: true; source: root.iconDir + "files.png"; width: 26; height: 26; anchors.verticalCenter: parent.verticalCenter }
            Text { text: root.diskFree; color: root.fg; font.family: root.font; font.pointSize: 13; anchors.verticalCenter: parent.verticalCenter }
        }

        Item { width: 1; height: 40 }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 44
            Item {
                width: rsearch.width; height: rsearch.height
                Row {
                    id: rsearch
                    spacing: 8
                    Image { sourceSize: Qt.size(80, 80); smooth: true; mipmap: true; source: root.iconDir + "search.png"; width: 30; height: 30; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Search"; color: root.fg; font.family: root.font; font.pointSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.search() }
            }
            Item {
                width: rexit.width; height: rexit.height
                Row {
                    id: rexit
                    spacing: 8
                    Image { sourceSize: Qt.size(80, 80); smooth: true; mipmap: true; source: root.iconDir + "poweroff.png"; width: 30; height: 30; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "Exit"; color: root.fg; font.family: root.font; font.pointSize: 13; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.exit() }
            }
        }
    }
}
