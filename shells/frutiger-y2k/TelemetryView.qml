// The TELEMETRY column on the right: processor ring + temp/load + sparkline, memory/storage, network with a
// sparkline, power, and PULSE (the mini player). Its own exclusive strip, so windows tile beside it.
import QtQuick
import "Pal.js" as P

Rectangle {
    id: t
    property var sys
    signal act(string what, var arg)
    radius: 18; color: P.glass; border.color: P.rim
    property var cpuHist: Array(40).fill(0)
    property var netHist: Array(40).fill(0)
    Timer { interval: 2000; running: true; repeat: true
            onTriggered: { t.cpuHist = t.cpuHist.slice(1).concat([t.sys?.cpu ?? 0]); t.netHist = t.netHist.slice(1).concat([Math.min(1, (t.sys?.netDown ?? 0) / 1048576)]) } }
    function kb(x) { return x > 1048576 ? (x / 1048576).toFixed(1) + " MB/s" : Math.round(x / 1024) + " KB/s" }
    Text { x: 16; y: 14; text: "◢ TELEMETRY"; font.family: P.sans; font.pixelSize: 13; font.letterSpacing: 2; color: P.ink }
    Text { x: 16; y: 34; text: "STATION · " + (t.sys?.host ?? "").toUpperCase(); font.family: P.sans; font.pixelSize: 8; font.letterSpacing: 1.2; color: P.label }
    Column {
        x: 10; y: 56; width: t.width - 20; spacing: 10
        Glass {
            width: parent.width; height: 120; title: "PROCESSOR"; note: (t.sys?.kernel ?? "").split("-")[0]
            Item { x: 14; y: 2; width: 52; height: 52
                   Canvas { anchors.fill: parent; property real f: t.sys?.cpu ?? 0; onFChanged: requestPaint()
                            onPaint: { const g = getContext("2d"); g.reset(); g.lineWidth = 5; g.strokeStyle = "#dde3ea"; g.beginPath(); g.arc(26, 26, 22, 0, 2 * Math.PI); g.stroke();
                                       g.strokeStyle = P.blue; g.beginPath(); g.arc(26, 26, 22, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * f); g.stroke() } }
                   Text { anchors.centerIn: parent; text: Math.round((t.sys?.cpu ?? 0) * 100) + "%"; font.family: P.sans; font.pixelSize: 11; color: P.ink } }
            Column { x: 80; y: 4; spacing: 3
                     Text { text: "TEMP  " + Math.round(t.sys?.temp ?? 0) + "°C"; font.family: P.sans; font.pixelSize: 10; color: P.ink }
                     Text { text: "LOAD  " + ((t.sys?.cpu ?? 0) * 4).toFixed(2); font.family: P.sans; font.pixelSize: 10; color: P.ink }
                     Text { text: "PKGS  " + (t.sys?.packages ?? 0); font.family: P.sans; font.pixelSize: 10; color: P.ink } }
            Spark { x: 14; y: 60; width: parent.width - 28; height: 24; values: t.cpuHist }
        }
        Glass {
            width: parent.width; height: 96; title: "MEMORY / STORAGE"; note: "RAM · SSD"
            Column { x: 14; y: 2; width: parent.width - 28; spacing: 6
                     Text { text: "RAM  " + Math.round((t.sys?.ram ?? 0) * 100) + "%      " + (t.sys?.ramUsed ?? 0).toFixed(1) + " / " + (t.sys?.ramTotal ?? 0).toFixed(1); font.family: P.sans; font.pixelSize: 10; color: P.ink }
                     Bar { width: parent.width; value: t.sys?.ram ?? 0 }
                     Text { text: "SSD  " + Math.round((t.sys?.diskUsed ?? 0) * 100) + "%      " + (t.sys?.diskFree ?? "") + " free"; font.family: P.sans; font.pixelSize: 10; color: P.ink }
                     Bar { width: parent.width; value: t.sys?.diskUsed ?? 0 } }
        }
        Glass {
            width: parent.width; height: 96; title: "NETWORK"; note: t.sys?.wired ? "ETH" : (t.sys?.ssid ?? "")
            Text { x: 14; y: 2; text: "▾ " + t.kb(t.sys?.netDown ?? 0) + "    ▴ " + t.kb(t.sys?.netUp ?? 0); font.family: P.sans; font.pixelSize: 11; color: P.ink }
            Spark { x: 14; y: 26; width: parent.width - 28; height: 30; values: t.netHist }
        }
        Glass {
            width: parent.width; height: 66; title: "POWER"; note: t.sys?.charging ? "CHARGING" : "BATTERY"
            Text { x: 14; y: 0; text: "BAT " + Math.round((t.sys?.battery ?? 1) * 100) + "%"; font.family: P.sans; font.pixelSize: 10; color: P.ink }
            Bar { x: 14; y: 18; width: parent.width - 28; value: t.sys?.battery ?? 1 }
        }
    }
    Glass {
        x: 10; anchors.bottom: parent.bottom; anchors.bottomMargin: 10; width: t.width - 20; height: 132; title: "PULSE"; note: t.sys?.playing ? "LIVE" : "STANDBY"
        Rectangle { x: 14; y: 2; width: 44; height: 44; radius: 8; color: "#eef2f6"; border.color: P.rim; clip: true
                    Image { anchors.fill: parent; source: t.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop } }
        Column { x: 68; y: 4; width: parent.width - 82
                 Text { width: parent.width; elide: Text.ElideRight; text: t.sys?.hasPlayer ? t.sys.track : "No signal"; font.family: P.sans; font.pixelSize: 12; font.weight: Font.DemiBold; color: P.ink }
                 Text { width: parent.width; elide: Text.ElideRight; text: t.sys?.hasPlayer ? t.sys.artist : "awaiting transmission"; font.family: P.sans; font.pixelSize: 10; color: P.label } }
        Rectangle { x: 14; y: 56; width: parent.width - 28; height: 2; color: P.blue }
        Row { anchors.horizontalCenter: parent.horizontalCenter; y: 66; spacing: 14
              Repeater { model: [["󰒮", "prev"], [t.sys?.playing ? "󰏤" : "󰐊", "play"], ["󰒭", "next"]]
                         Rectangle { required property var modelData; width: 34; height: 24; radius: 12; color: modelData[1] === "play" ? P.blue : "#eef2f6"; border.color: P.rim
                                     Text { anchors.centerIn: parent; text: parent.modelData[0]; font.family: P.mono; font.pixelSize: 13; color: parent.modelData[1] === "play" ? "white" : P.ink }
                                     MouseArea { anchors.fill: parent; onClicked: t.act(parent.modelData[1], null) } } } }
    }
}
