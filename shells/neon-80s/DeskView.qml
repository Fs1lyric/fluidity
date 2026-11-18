// The desktop widgets from his screenshot: a gotop-style stats panel (CPU, memory, disk, network graph, battery)
// and below it cava's bars in a blue -> pink gradient, both in dark navy glass with a thin grey frame.
import QtQuick

Column {
    id: v
    property var sys
    property var levels: []
    property bool showViz: true
    property bool showStats: true
    spacing: 18
    readonly property string mono: "JetBrainsMono Nerd Font"
    property var hist: Array(60).fill(0)
    Timer { interval: 1000; running: v.showStats; repeat: true
            onTriggered: v.hist = v.hist.slice(1).concat([Math.min(1, (v.sys?.netDown ?? 0) / 2097152)]) }
    Rectangle {
        visible: v.showStats
        width: v.width; height: 300; color: "#c0141830"; border.color: "#566395"; border.width: 1
        Column {
            x: 14; y: 10; width: parent.width - 28; spacing: 10
            Repeater {
                model: [["CPU Usage", v.sys?.cpu ?? 0, "#188fed"], ["Memory Usage", v.sys?.ram ?? 0, "#b893ce"], ["Disk Usage", v.sys?.diskUsed ?? 0, "#f9f871"],
                        ["Battery", v.sys?.battery ?? 1, "#b6f23a"]]
                Column {
                    id: grp
                    required property var modelData
                    spacing: 3; width: parent.width
                    Text { text: parent.modelData[0] + "  " + Math.round(parent.modelData[1] * 100) + "%"; color: "#e8e8f0"; font.family: v.mono; font.pixelSize: 13 }
                    Row { spacing: 1
                          Repeater { model: 60
                                     Rectangle { required property int index; width: (v.width - 28) / 60 - 1; height: 12
                                                 color: index / 60 < grp.modelData[1] ? grp.modelData[2] : "#2d496f" } } }
                }
            }
            Text { text: "Network Usage   IN " + Math.round((v.sys?.netDown ?? 0) / 1024) + "K/s"; color: "#e8e8f0"; font.family: v.mono; font.pixelSize: 13 }
            Row { height: 40; spacing: 1
                  Repeater { model: v.hist
                             Rectangle { required property var modelData; width: (v.width - 28) / 60 - 1; height: Math.max(1, 40 * modelData); y: 40 - height; color: "#188fed" } } }
        }
    }
    Rectangle {
        visible: v.showViz
        width: v.width; height: 200; color: "#c0141830"; border.color: "#566395"; border.width: 1
        Row {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 12; x: 12; spacing: 6
            Repeater {
                model: v.levels.length ? v.levels : Array(36).fill(0.08)
                Rectangle {
                    required property var modelData
                    width: (v.width - 24) / 36 - 6; height: Math.max(4, 170 * modelData)
                    anchors.bottom: parent.bottom
                    gradient: Gradient { GradientStop { position: 0; color: Qt.rgba(1, 0.16, 0.6, Math.min(1, modelData * 1.6)) }
                                         GradientStop { position: 0.6; color: "#7a5cff" } GradientStop { position: 1; color: "#188fed" } }
                }
            }
        }
    }
}
