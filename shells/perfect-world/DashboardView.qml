// amarena dashboard (elemental/dashboard/amarena.lua): four columns of rounded boxes over color0 CC.
// Esc / q / F1 closes. Covid numbers come from disease.sh (her corona-stats.online is gone).
import QtQuick
import "Pal.js" as P

Rectangle {
    id: root
    property string profile: "profile.png"
    property string userName: "ELENA"
    property string host: "@amarena"
    property string fortune: "Life would be so much easier if we could just look at the source code.\n— Dave Olson"
    property bool dnd: false
    property real diskUsed: 0.75
    property string diskText: "75%"
    property string cases: "3732 (+60)"
    property string deaths: "193 (+0)"
    property string uptime: "up 19 hours, 12 minutes"
    property date day: new Date(2020, 6, 11)
    signal closed()
    signal openUrl(string url)
    signal openDir(string name)
    signal toggleDnd()
    signal screenshot()

    implicitWidth: 1920; implicitHeight: 1080
    color: "#cc242d35"
    focus: true
    Keys.onPressed: e => { if (e.key === Qt.Key_Escape || e.key === Qt.Key_F1 || e.text === "q") { root.closed(); e.accepted = true } }
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.MiddleButton | Qt.RightButton; onClicked: root.closed() }

    Row {
        anchors.centerIn: parent
        // box_gap 6 around every box
        Column {
            DashBox { w: 300; h: 340
                Column {
                    anchors.centerIn: parent; spacing: 6
                    Rectangle { width: 120; height: 120; radius: 30; clip: true; color: P.c0; anchors.horizontalCenter: parent.horizontalCenter
                        Image { anchors.fill: parent; source: root.profile; fillMode: Image.PreserveAspectCrop; sourceSize: Qt.size(240, 240) } }
                    Item { width: 1; height: 18 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.userName; color: P.fg
                           font.family: P.sans; font.pointSize: 20; font.weight: Font.Black }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.host; color: P.c8
                           font.family: P.mono; font.pointSize: 16 }
                }
            }
            DashBox { w: 300; h: 140
                Text { anchors.centerIn: parent; width: 230; wrapMode: Text.WordWrap; text: root.fortune; color: P.c4
                       font.family: P.sans; font.pointSize: 11; font.italic: true; font.weight: Font.Medium }
            }
        }
        Column {
            DashBox { w: 150; h: 150; fill: "transparent"
                Grid {
                    anchors.centerIn: parent; columns: 2; spacing: 10
                    Repeater {
                        model: [["GH", P.c4, P.c12, "https://github.com/elenapan/dotfiles", [true, true, false, true]],
                                ["YT", P.c1, P.c9, "https://youtube.com/", [true, true, true, false]],
                                ["RD", P.c3, P.c11, "https://reddit.com/", [true, false, true, true]],
                                ["4C", P.c2, P.c10, "https://4chan.org/", [false, true, true, true]]]
                        Rectangle {
                            required property var modelData
                            width: 55; height: 55
                            readonly property var r: modelData[4]   // tl tr br bl rounded?
                            topLeftRadius: r[0] ? 27.5 : 4; topRightRadius: r[1] ? 27.5 : 4
                            bottomRightRadius: r[2] ? 27.5 : 4; bottomLeftRadius: r[3] ? 27.5 : 4
                            color: ma.containsMouse ? modelData[2] : modelData[1]
                            Text { anchors.centerIn: parent; text: parent.modelData[0]; color: P.fg; font.family: P.sans
                                   font.pointSize: 11; font.bold: true }
                            MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: root.openUrl(parent.modelData[3]) }
                        }
                    }
                }
            }
            DashBox { w: 150; h: 78
                Text { anchors.centerIn: parent; text: P.g(root.dnd ? P.glyph.bellOff : P.glyph.bell); color: root.dnd ? P.c8 : P.c2
                       font.family: P.icons; font.pointSize: 25 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleDnd() }
            }
            DashBox { w: 150; h: 78
                Text { anchors.centerIn: parent; text: P.g(P.glyph.camera); color: P.c3; font.family: P.icons; font.pointSize: 25 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.screenshot() }
            }
            DashBox { w: 150; h: 150
                Item {
                    anchors.centerIn: parent; width: 90; height: 90
                    Canvas {
                        id: arc; anchors.fill: parent
                        property real v: root.diskUsed
                        onVChanged: requestPaint()
                        onPaint: { const c = getContext("2d"); c.reset(); c.lineWidth = 8; c.lineCap = "round";
                            c.strokeStyle = P.c0; c.beginPath(); c.arc(45, 45, 40, 0, 2 * Math.PI); c.stroke();
                            c.strokeStyle = P.c5; c.beginPath(); c.arc(45, 45, 40, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * v); c.stroke(); }
                    }
                    Text { anchors.centerIn: parent; text: hov.containsMouse ? root.diskText : P.g(P.glyph.disk)
                           color: hov.containsMouse ? P.fg : P.c4; font.family: hov.containsMouse ? P.sans : P.icons
                           font.pointSize: hov.containsMouse ? 13 : 23; font.weight: Font.Medium }
                    MouseArea { id: hov; anchors.fill: parent; hoverEnabled: true }
                }
            }
        }
        Column {
            DashBox { w: 200; h: 300
                Column {
                    anchors.centerIn: parent; spacing: 10
                    Repeater {
                        model: [["home", P.c1, P.c9], ["downloads", P.c2, P.c10], ["music", P.c6, P.c14],
                                ["pictures", P.c4, P.c12], ["wallpapers", P.c5, P.c13], ["screenshots", P.c3, P.c11]]
                        Text {
                            required property var modelData
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData[0]; color: bm.containsMouse ? modelData[2] : modelData[1]
                            font.family: P.sans; font.pointSize: 16; font.bold: true
                            MouseArea { id: bm; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: root.openDir(parent.modelData[0]) }
                        }
                    }
                }
            }
            DashBox { w: 200; h: 180
                Column {
                    anchors.centerIn: parent; spacing: 14
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Pandemic"; color: P.c2
                           font.family: P.sans; font.pointSize: 20; font.bold: true }
                    Row { spacing: 10
                        Text { text: P.g(P.glyph.cases); color: P.c3; font.family: P.icons; font.pointSize: 20 }
                        Text { text: root.cases; color: P.fg; font.family: P.sans; font.pointSize: 14; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter } }
                    Row { spacing: 10
                        Text { text: P.g(P.glyph.deaths); color: P.c1; font.family: P.icons; font.pointSize: 20 }
                        Text { text: root.deaths; color: P.fg; font.family: P.sans; font.pointSize: 14; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter } }
                }
            }
        }
        Column {
            DashBox { w: 300; h: 400
                Column {
                    anchors.centerIn: parent; spacing: 14
                    readonly property date first: new Date(root.day.getFullYear(), root.day.getMonth(), 1)
                    readonly property int lead: (first.getDay() + 6) % 7
                    readonly property int days: new Date(root.day.getFullYear(), root.day.getMonth() + 1, 0).getDate()
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDate(root.day, "MMMM yyyy")
                           color: P.c4; font.family: P.sans; font.pointSize: 20; font.weight: Font.Medium }
                    Grid {
                        id: cal; columns: 7; columnSpacing: 2; rowSpacing: 14
                        Repeater { model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                            Text { required property var modelData; width: 34; horizontalAlignment: Text.AlignHCenter
                                   text: modelData; color: P.fg; font.family: P.sans; font.pointSize: 12; font.weight: Font.Medium } }
                        Repeater { model: cal.parent.lead; Item { width: 34; height: 1 } }
                        Repeater { model: cal.parent.days
                            Text { required property int index; width: 34; horizontalAlignment: Text.AlignHCenter
                                   text: index + 1; color: index + 1 === root.day.getDate() ? P.c1 : P.fg
                                   font.family: P.sans; font.pointSize: 12; font.weight: Font.Medium } }
                    }
                }
            }
            DashBox { w: 300; h: 80
                Row { anchors.centerIn: parent; spacing: 14
                    Text { text: P.g(P.glyph.uptime); color: P.c3; font.family: P.icons; font.pointSize: 20 }
                    Text { text: root.uptime; color: P.fg; font.family: P.sans; font.pointSize: 11; font.weight: Font.Medium; anchors.verticalCenter: parent.verticalCenter } }
            }
        }
    }
}
