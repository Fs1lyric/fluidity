// elenapan's amarena sidebar (AwesomeWM, Jul 2020) as a pure view.
// Original: github.com/elenapan/dotfiles @d5b72a0 config/awesome/elemental/sidebar/amarena.lua
import QtQuick
import "Pal.js" as P

Item {
    id: root
    property string hours: "16"
    property string minutes: "51"
    property int weekday: 5            // 0 = Monday
    property real battery: 0.8
    property bool charging: true
    property string weatherText: "Clear sky"
    property string weatherTemp: "24"
    property string weatherGlyph: "sun"
    property string title: "Date Rape"
    property string artist: "Sublime"
    property real volume: 0.6
    property bool muted: false
    property real cpu: 0.9
    property real temp: 0.5
    property real ram: 0.3
    property real brightness: 0.75
    signal prev()
    signal toggle()
    signal next()
    signal search()
    signal volumeStep(int d)
    signal muteClicked()
    signal brightnessStep(int d)
    signal batteryClicked()

    implicitWidth: 300
    implicitHeight: 1080
    property string hint: ""

    // whole sidebar: background, top-right corner rounded 40
    Rectangle { anchors.fill: parent; color: P.bg; topRightRadius: 40 }

    Column {
        id: top
        width: parent.width
        topPadding: 30
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20
            Text { text: root.hours; color: P.fg; font.family: P.sans; font.pointSize: 44; font.weight: Font.ExtraBold }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Repeater { model: [P.c1, P.c4, P.c5]
                    Rectangle { required property var modelData; width: 10; height: 10; radius: 2; color: modelData } }
            }
            Text { text: root.minutes; color: P.fg; font.family: P.sans; font.pointSize: 44; font.weight: Font.ExtraBold }
        }
        Item { width: 1; height: 20 }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                Rectangle {
                    required property var modelData
                    required property int index
                    width: 25; height: 25; radius: 12.5
                    color: index === root.weekday ? (index >= 5 ? P.c13 : P.c9) : "transparent"
                    Text { anchors.centerIn: parent; text: parent.modelData; color: P.fg; font.family: P.sans
                           font.pointSize: 10; font.bold: true }
                }
            }
        }
        Item { width: 1; height: 25 }
        BatteryFace {
            anchors.horizontalCenter: parent.horizontalCenter
            level: root.battery; charging: root.charging
            MouseArea { anchors.fill: parent; onClicked: root.batteryClicked() }
        }
        Item { width: 1; height: 30 }
    }

    // middle group: weather, music, five meters on a lighter panel
    Rectangle {
        id: mid
        anchors { top: top.bottom; left: parent.left; right: parent.right }
        height: midCol.height
        color: Qt.rgba(0.141, 0.176, 0.208, 0.4)   // color0 .. "66"
        topRightRadius: 40
        Column {
            id: midCol
            width: parent.width
            topPadding: 30
            bottomPadding: 25
            Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.weatherText; color: P.fg
                   font.family: P.sans; font.pointSize: 14; font.weight: Font.Medium }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Text { text: P.g(P.glyph[root.weatherGlyph] || P.glyph.sun); color: P.c3; font.family: P.icons; font.pointSize: 16
                       anchors.verticalCenter: parent.verticalCenter }
                Text { text: root.weatherTemp; color: P.fg; font.family: P.sans; font.pointSize: 14; font.weight: Font.Medium
                       anchors.verticalCenter: parent.verticalCenter }
            }
            Item { width: 1; height: 40 }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18
                Repeater {
                    model: [["prev", P.c4], ["note", P.fg], ["next", P.c4]]
                    Text {
                        required property var modelData
                        text: P.g(P.glyph[modelData[0]]); color: modelData[1]; font.family: P.icons; font.pointSize: 16
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: parent.modelData[0] === "prev" ? root.prev() : parent.modelData[0] === "next" ? root.next() : root.toggle() }
                    }
                }
            }
            Item { width: 1; height: 5 }
            Text { anchors.horizontalCenter: parent.horizontalCenter; width: 260; horizontalAlignment: Text.AlignHCenter
                   elide: Text.ElideRight; text: root.title || "—"; color: P.fg; font.family: P.sans; font.pointSize: 14; font.weight: Font.Medium }
            Text { anchors.horizontalCenter: parent.horizontalCenter; width: 260; horizontalAlignment: Text.AlignHCenter
                   elide: Text.ElideRight; text: root.artist; color: P.fg; font.family: P.sans; font.pointSize: 10; font.weight: Font.Medium }
            Item { width: 1; height: 60 }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 18
                Repeater {
                    model: [
                        ["volume", P.c5, root.muted ? 0 : root.volume, "The volume is at " + Math.round(root.volume * 100) + "%" + (root.muted ? " and muted" : "")],
                        ["cpu", P.c2, root.cpu, "You are using " + Math.round(root.cpu * 100) + "% of CPU"],
                        ["temp", P.c1, root.temp, "Your CPU temperature is at " + Math.round(root.temp * 100) + "°C"],
                        ["ram", P.c4, root.ram, "You are using " + Math.round(root.ram * 100) + "% of memory"],
                        ["brightness", P.c3, root.brightness, "Your screen is " + Math.round(root.brightness * 100) + "% bright"]]
                    Item {
                        required property var modelData
                        width: 16; height: 70
                        Rectangle { anchors.fill: parent; radius: 8; color: P.c0
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; radius: 8
                                        height: parent.height * Math.max(0, Math.min(1, parent.parent.modelData[2])); color: parent.parent.modelData[1]
                                        Behavior on height { NumberAnimation { duration: 400 } } } }
                        MouseArea {
                            anchors.fill: parent; hoverEnabled: true
                            onEntered: root.hint = parent.modelData[3]
                            onExited: root.hint = ""
                            onClicked: if (parent.modelData[0] === "volume") root.muteClicked()
                            onWheel: w => { const d = w.angleDelta.y > 0 ? 1 : -1;
                                if (parent.modelData[0] === "volume") root.volumeStep(d);
                                else if (parent.modelData[0] === "brightness") root.brightnessStep(d); }
                        }
                    }
                }
            }
        }
    }

    // bottom group: the hover hint (her adaptive tooltip) and the search pill
    Rectangle {
        anchors { top: mid.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        color: Qt.rgba(0.141, 0.176, 0.208, 0.4)
        Text {
            anchors { horizontalCenter: parent.horizontalCenter; bottom: pill.top; bottomMargin: 30 }
            width: 260; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            text: root.hint; color: P.fg; font.family: P.sans; font.pointSize: 10; font.weight: Font.Medium
        }
        Rectangle {
            id: pill
            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 30 }
            width: 200; height: 35; radius: 17.5; color: P.c0
            Text { x: 15; anchors.verticalCenter: parent.verticalCenter; text: P.g(P.glyph.search); color: P.c3
                   font.family: P.icons; font.pointSize: 11 }
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.search() }
        }
    }
}
