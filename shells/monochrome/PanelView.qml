// agridyne's two Plasma panels made into "islands" with Panel Colorizer (panel-layout.png):
//   top: system monitor (cpu graph, cpu %, ram %, temp, net), a long empty island, weather + night-colour + clock, control station
//   bottom: launcher + pinned apps, a long empty island, tray icons and the clock
import QtQuick

Item {
    id: p
    property var sys
    property bool lower: false
    property var cpuHistory: []
    property var apps: [["0xf003b", "launcher"], ["0xf024b", "files"], ["0xf059f", "browser"], ["0xf0239", "terminal"],
                        ["0xf0493", "settings"], ["0xf0849", "url:https://github.com"], ["0xf04c7", "exec:steam"]]
    signal act(string what, var arg)
    implicitHeight: 34
    readonly property color island: Qt.rgba(0.11, 0.11, 0.11, 0.86)
    readonly property color edge: Qt.rgba(1, 1, 1, 0.10)
    readonly property color fg: "#e8e8e8"
    readonly property string font: "JetBrainsMono Nerd Font"
    function g(cp) { return String.fromCodePoint(cp) }
    function rate(b) { return b > 1048576 ? (b / 1048576).toFixed(1) + " MiB" : b > 1024 ? Math.round(b / 1024) + " KiB" : Math.round(b) + " B" }

    component Island: Rectangle {
        height: 26; radius: 5; color: p.island; border.color: p.edge; border.width: 1
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    }
    component Mono: Text { color: p.fg; font.family: p.font; font.pixelSize: 11; anchors.verticalCenter: parent ? parent.verticalCenter : undefined }
    component Btn: Text {
        property string what
        color: p.fg; font.family: p.font; font.pixelSize: 14; anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        MouseArea { anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
            onClicked: { const w = parent.what; if (w.startsWith("url:")) p.act("url", w.slice(4)); else if (w.startsWith("exec:")) p.act("exec", ["bash", "-c", w.slice(5)]); else p.act(w, null) } }
    }

    Row {
        id: leftRow
        x: 6; height: parent.height; spacing: 6
        // top: system monitor island
        Island {
            visible: !p.lower; width: mon.width + 16
            Row { id: mon; anchors.centerIn: parent; spacing: 10
                Canvas {
                    id: graph; width: 26; height: 16; anchors.verticalCenter: parent.verticalCenter
                    property var pts: p.cpuHistory
                    onPtsChanged: requestPaint()
                    onPaint: { const c = getContext("2d"); c.reset(); c.fillStyle = "#d8d8d8";
                        pts.forEach((v, i) => c.fillRect(i * 2, height - Math.max(1, v * height), 1.5, Math.max(1, v * height))) }
                }
                Mono { text: Math.round((p.sys?.cpu ?? 0) * 100) + "%" }
                Mono { text: Math.round((p.sys?.ram ?? 0) * 100) + "%" }
                Mono { text: Math.round(p.sys?.temp ?? 0) + "°" }
                Mono { text: p.rate(p.sys?.netDown ?? 0) }
            }
        }
        // bottom: launcher + pinned apps
        Island {
            visible: p.lower; width: appRow.width + 18
            Row { id: appRow; anchors.centerIn: parent; spacing: 14
                Repeater { model: p.apps; Btn { required property var modelData; text: p.g(+modelData[0]); what: modelData[1] } } }
        }
    }
    Row {
        id: rightRow
        anchors { right: parent.right; rightMargin: 6 }
        height: parent.height; spacing: 6
        Island {
            width: tray.width + 18
            Row { id: tray; anchors.centerIn: parent; spacing: 12
                Btn { visible: p.lower; text: p.g(p.sys?.muted ? 0xf075f : 0xf057e); what: "mute" }
                Btn { visible: p.lower; text: p.g(p.sys?.btOn ? 0xf00af : 0xf00b2); what: "bt" }
                Btn { visible: p.lower; text: p.g(p.sys?.online ? 0xf0928 : 0xf092e); what: "wifi" }
                Btn { visible: !p.lower; text: p.g(0xf0599); what: "url:https://wttr.in" }
                Btn { visible: !p.lower; text: p.g(0xf0594); what: "night" }
                Column { anchors.verticalCenter: parent.verticalCenter
                    Mono { anchors.verticalCenter: undefined; anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 10
                           text: Qt.formatDateTime(p.sys?.now ?? new Date(), "h:mm AP") }
                    Mono { anchors.verticalCenter: undefined; anchors.horizontalCenter: parent.horizontalCenter; font.pixelSize: 8; color: "#a0a0a0"
                           text: Qt.formatDateTime(p.sys?.now ?? new Date(), "yyyy-MM-dd") } }
            }
        }
        Island { width: 34; Btn { anchors.centerIn: parent; text: p.g(p.lower ? 0xf0425 : 0xf0493); what: p.lower ? "power" : "settings" } }
        // CatWalkR: a little cat sitting on the top panel, sleepier when the CPU is idle
        Island { visible: !p.lower; width: 34
            Text { anchors.centerIn: parent; font.pixelSize: 15; color: p.fg; text: (p.sys?.cpu ?? 0) > 0.5 ? "ᓚᘏᗢ" : "ᶻ𝗓𐰁"; font.family: p.font } }
    }
    // the long empty island between the two ends
    Island { anchors { left: leftRow.right; right: rightRow.left; leftMargin: 6; rightMargin: 6 } }

    Timer { interval: 2000; running: !p.lower; repeat: true; triggeredOnStart: true
            onTriggered: p.cpuHistory = (p.cpuHistory.length >= 13 ? p.cpuHistory.slice(1) : p.cpuHistory).concat([p.sys?.cpu ?? 0]) }
}
