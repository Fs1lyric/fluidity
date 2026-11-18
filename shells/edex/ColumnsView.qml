// eDEX-UI's two module columns on the left: PANEL/SYSTEM (clock, sysinfo, cpu, memory, top processes, clipboard)
// and PANEL/NETWORK (status, world view, traffic). Pure view, 650 x 1060 at 1080p.
import QtQuick
import "Pal.js" as P

Item {
    id: root
    property string time: "14:07:46"
    property string year: "2018"
    property string date: "NOV 20"
    property string uptime: "1:20:02"
    property string power: "WIRED"
    property string cpuModel: "Intel® Core™ i5-4200H"
    property var cpuA: [0.2, 0.5, 0.4, 0.8, 0.6, 0.7, 0.5, 0.9, 0.6, 0.7]
    property var cpuB: [0.3, 0.4, 0.6, 0.5, 0.7, 0.6, 0.8, 0.6, 0.7, 0.8]
    property string labelA: "# 1 - 2"
    property string labelB: "# 3 - 4"
    property int avgA: 94
    property int avgB: 94
    property string temp: "66°C"
    property string fmin: "3.17GHz"
    property string fmax: "3.18GHz"
    property int tasks: 242
    property real memUsed: 0.4
    property string memText: "USING 3 OUT OF 7.5 GiB"
    property var procs: [["8541", "python3", "32.8%", "2.8%"], ["21673", "electron", "24.5%", "2.1%"], ["21638", "electron", "9.9%", "1.6%"],
                         ["1590", "Xorg", "5%", "2.1%"], ["11391", "firefox-bin", "4.8%", "5.7%"]]
    property string netState: "ONLINE"
    property string ipv4: "194.187.249.52"
    property string ping: "3ms"
    property string coords: "48.8927, 2.2874"
    property var netUp: [0.02, 0.05, 0.03, 0.04, 0.02, 0.06, 0.03]
    property var netDown: [0.05, 0.1, 0.06, 0.08, 0.9, 0.05, 0.04]
    property string netTotal: "25.1 MB OUT, 1.2 GB IN"
    property bool animate: true
    signal copy()
    signal paste()
    implicitWidth: 660; implicitHeight: 1060
    Rectangle { anchors.fill: parent; color: P.black }

    // -------- SYSTEM column --------
    Column {
        x: 10; y: 10; width: 310; spacing: 14
        Hdr { width: parent.width; leftText: "PANEL"; rightText: "SYSTEM" }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.time.split("").join(" ")
               color: P.c; font.family: P.main; font.pixelSize: 42; font.weight: Font.Light }
        Row {
            width: parent.width
            Repeater { model: [[root.year, root.date], ["UPTIME", root.uptime], ["TYPE", "LINUX"], ["POWER", root.power]]
                Column { required property var modelData; width: 310 / 4
                    Text { text: modelData[0]; color: P.a(0.6); font.family: P.main; font.pixelSize: 13 }
                    Text { text: modelData[1]; color: P.c; font.family: P.main; font.pixelSize: 14 } } }
        }
        Hdr { width: parent.width; leftText: "CPU USAGE"; rightText: root.cpuModel }
        Repeater { model: [[root.labelA, root.avgA, root.cpuA], [root.labelB, root.avgB, root.cpuB]]
            Row { required property var modelData; spacing: 8
                Column { width: 60
                    Text { text: modelData[0]; color: P.c; font.family: P.main; font.pixelSize: 13 }
                    Text { text: "Avg. " + modelData[1] + "%"; color: P.a(0.6); font.family: P.main; font.pixelSize: 11 } }
                Graph { width: 242; height: 38; values: parent.modelData[2] } } }
        Row {
            width: parent.width
            Repeater { model: [["TEMP", root.temp], ["MIN", root.fmin], ["MAX", root.fmax], ["TASKS", root.tasks]]
                Column { required property var modelData; width: 310 / 4
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData[0]; color: P.a(0.6); font.family: P.main; font.pixelSize: 12 }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: modelData[1]; color: P.c; font.family: P.main; font.pixelSize: 12 } } }
        }
        Hdr { width: parent.width; leftText: "MEMORY"; rightText: root.memText }
        Grid {
            columns: 40; rowSpacing: 4; columnSpacing: 5
            Repeater { model: 440
                Rectangle { required property int index; width: 2.6; height: 2.6
                    color: index / 440 < root.memUsed ? P.c : P.a(0.22) } }
        }
        Hdr { width: parent.width; leftText: "TOP PROCESSES"; rightText: "PID | NAME | CPU | MEM" }
        Column { width: parent.width; spacing: 3
            Repeater { model: root.procs
                Row { required property var modelData
                    Text { width: 55; text: modelData[0]; color: P.a(0.7); font.family: P.main; font.pixelSize: 13 }
                    Text { width: 125; text: modelData[1]; color: P.c; font.family: P.main; font.pixelSize: 13; elide: Text.ElideRight }
                    Text { width: 65; horizontalAlignment: Text.AlignRight; text: modelData[2]; color: P.c; font.family: P.main; font.pixelSize: 13 }
                    Text { width: 65; horizontalAlignment: Text.AlignRight; text: modelData[3]; color: P.c; font.family: P.main; font.pixelSize: 13 } } } }
        Hdr { width: parent.width; leftText: "CLIPBOARD ACCESS"; rightText: "" }
        Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: 22
            Repeater { model: ["COPY", "PASTE"]
                Rectangle { required property var modelData; width: 130; height: 30; color: cm.pressed ? P.a(0.3) : "transparent"; border.color: P.c; border.width: 1
                    Text { anchors.centerIn: parent; text: parent.modelData; color: P.c; font.family: P.main; font.pixelSize: 15 }
                    MouseArea { id: cm; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: parent.modelData === "COPY" ? root.copy() : root.paste() } } } }
    }

    // -------- NETWORK column --------
    Column {
        x: 340; y: 10; width: 310; spacing: 12
        Hdr { width: parent.width; leftText: "PANEL"; rightText: "NETWORK" }
        Hdr { width: parent.width; leftText: "NETWORK STATUS"; rightText: "" }
        Row {
            width: parent.width
            Repeater { model: [["STATE", root.netState, 80], ["IPv4", root.ipv4, 170], ["PING", root.ping, 60]]
                Column { required property var modelData; width: modelData[2]
                    Text { text: modelData[0]; color: P.a(0.6); font.family: P.main; font.pixelSize: 13 }
                    Text { text: modelData[1]; color: P.c; font.family: P.main; font.pixelSize: 15 } } }
        }
        Hdr { width: parent.width; leftText: "WORLD VIEW"; rightText: "GLOBAL NETWORK MAP" }
        Item { width: parent.width; height: 14
            Text { text: "ENDPOINT LAT/LON"; color: P.a(0.6); font.family: P.main; font.pixelSize: 11 }
            Text { anchors.right: parent.right; text: root.coords; color: P.a(0.6); font.family: P.main; font.pixelSize: 11 } }
        Globe { width: parent.width; height: 270; running: root.animate }
        Hdr { width: parent.width; leftText: "NETWORK TRAFFIC"; rightText: "UP / DOWN, MB/S" }
        Item { width: parent.width; height: 14
            Text { text: "TOTAL"; color: P.a(0.6); font.family: P.main; font.pixelSize: 11 }
            Text { anchors.right: parent.right; text: root.netTotal; color: P.a(0.6); font.family: P.main; font.pixelSize: 11 } }
        Graph { width: parent.width; height: 140; centered: true; values: root.netUp; values2: root.netDown }
    }
}
