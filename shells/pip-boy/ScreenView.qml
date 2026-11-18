// The Pip-Boy screen the bottom tabs open: STATS (system), INV (apps), MAP (weather), DATA (date + to do),
// RADIO (player + visualizer). Phosphor green on CRT black with scanlines and a soft vignette.
import QtQuick
import "Pal.js" as P

Rectangle {
    id: s
    property var sys
    property string tab: "STATS"
    property var levels: []
    signal act(string what, var arg)
    signal pick(string t)
    color: Qt.rgba(0.02, 0.07, 0.03, 0.94)
    border.color: P.hi; border.width: 2
    readonly property string f: "Share Tech Mono"
    function pct(x) { return Math.round((x ?? 0) * 100) }
    // tab strip
    Row {
        id: tabs; x: 40; y: 24; spacing: 34
        Repeater {
            model: ["STATS", "INV", "MAP", "DATA", "RADIO"]
            Text { required property string modelData; text: modelData; color: s.tab === modelData ? P.hi : P.mid
                   font.family: s.f; font.pixelSize: 26; font.bold: s.tab === modelData
                   Rectangle { visible: s.tab === parent.modelData; anchors.top: parent.bottom; width: parent.width; height: 2; color: P.hi }
                   MouseArea { anchors.fill: parent; onClicked: s.pick(parent.modelData) } }
        }
    }
    Rectangle { x: 24; y: 70; width: parent.width - 48; height: 2; color: P.hi }
    Item {
        id: body; x: 40; y: 96; width: parent.width - 80; height: parent.height - 136
        // STATS
        Column {
            visible: s.tab === "STATS"; spacing: 18; width: parent.width
            Repeater {
                model: [["HP  (battery)", s.sys?.battery ?? 1], ["CPU (RAD)", s.sys?.cpu ?? 0], ["MEMORY", s.sys?.ram ?? 0],
                        ["DISK", s.sys?.diskUsed ?? 0], ["VOLUME", s.sys?.volume ?? 0], ["SIGNAL", s.sys?.wifiStrength ?? 0]]
                Row {
                    required property var modelData
                    spacing: 20
                    Text { width: 240; text: parent.modelData[0]; color: P.hi; font.family: s.f; font.pixelSize: 22 }
                    Rectangle { width: body.width - 360; height: 18; y: 4; color: "transparent"; border.color: P.hi; border.width: 2
                                Rectangle { x: 3; y: 3; height: 12; width: (parent.width - 6) * Math.max(0, Math.min(1, parent.parent.modelData[1])); color: P.hi } }
                    Text { text: s.pct(parent.modelData[1]) + "%"; color: P.hi; font.family: s.f; font.pixelSize: 22 }
                }
            }
            Text { topPadding: 14; color: P.mid; font.family: s.f; font.pixelSize: 18
                   text: (s.sys?.user ?? "") + "@" + (s.sys?.host ?? "") + "   LVL " + (s.sys?.packages ?? 0) + "   UPTIME " + (s.sys?.uptime ?? "") + "   " + Math.round(s.sys?.temp ?? 0) + "°C" }
        }
        // INV: apps as inventory items
        Grid {
            visible: s.tab === "INV"; columns: 2; columnSpacing: 60; rowSpacing: 10
            Repeater {
                model: [["Terminal", "terminal", "Wgt 1"], ["Files", "files", "Wgt 3"], ["Browser", "browser", "Wgt 4"], ["Launcher", "launcher", "Wgt 0"],
                        ["Settings", "settings", "Wgt 2"], ["Screenshot", "shot", "Wgt 1"], ["Lock", "lock", "Wgt 0"], ["Power", "power", "Wgt 9"]]
                Rectangle {
                    required property var modelData
                    width: 420; height: 40; color: ma.containsMouse ? P.hi : "transparent"
                    Text { x: 14; anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[0]; font.family: s.f; font.pixelSize: 22; color: ma.containsMouse ? P.bg : P.hi }
                    Text { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: parent.modelData[2]
                           font.family: s.f; font.pixelSize: 18; color: ma.containsMouse ? P.bg : P.mid }
                    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: s.act(parent.modelData[1], null) }
                }
            }
        }
        // MAP: the weather report for where you are
        Column {
            visible: s.tab === "MAP"; spacing: 14
            Text { text: "LOCATION: " + (s.sys?.weatherPlace || "THE WASTELAND").toUpperCase(); color: P.hi; font.family: s.f; font.pixelSize: 30 }
            Text { text: (s.sys?.weatherTemp || "--") + "°C   " + (s.sys?.weatherCond || "").toUpperCase(); color: P.hi; font.family: s.f; font.pixelSize: 64 }
            Text { text: "HUMIDITY " + (s.sys?.weatherHumidity || "--") + "    WIND " + (s.sys?.weatherWind || "--"); color: P.mid; font.family: s.f; font.pixelSize: 22 }
            Text { text: s.sys?.night ? "NIGHT. STAY INSIDE THE VAULT." : "DAYLIGHT. WEAR YOUR RAD-X."; color: P.mid; font.family: s.f; font.pixelSize: 22 }
        }
        // DATA: date + quests (to do list)
        Column {
            visible: s.tab === "DATA"; spacing: 10; width: parent.width
            Text { text: Qt.formatDateTime(s.sys?.now ?? new Date(), "dddd dd MMMM yyyy  HH:mm").toUpperCase(); color: P.hi; font.family: s.f; font.pixelSize: 28 }
            Text { text: "QUESTS"; topPadding: 10; color: P.mid; font.family: s.f; font.pixelSize: 20 }
            Repeater {
                model: s.sys?.todos ?? []
                Text { required property var modelData; required property int index
                       text: (modelData.done ? "[x] " : "[ ] ") + modelData.text; color: modelData.done ? P.mid : P.hi; font.family: s.f; font.pixelSize: 22
                       MouseArea { anchors.fill: parent; onClicked: s.act("todoToggle", parent.index) } }
            }
            Rectangle { width: 520; height: 36; color: "transparent"; border.color: P.mid
                        TextInput { id: q; anchors.fill: parent; anchors.margins: 8; color: P.hi; font.family: s.f; font.pixelSize: 18
                                    onAccepted: { s.act("todoAdd", text); text = "" }
                                    Text { visible: !q.text; text: "> new quest"; color: P.dim; font: q.font } } }
        }
        // RADIO: player + visualizer
        Column {
            visible: s.tab === "RADIO"; spacing: 16; width: parent.width
            Text { text: s.sys?.hasPlayer ? "> " + s.sys.track : "> NO STATION"; color: P.hi; font.family: s.f; font.pixelSize: 34; width: parent.width; elide: Text.ElideRight }
            Text { text: s.sys?.artist ?? ""; color: P.mid; font.family: s.f; font.pixelSize: 22 }
            Row {
                height: 200; spacing: 4
                Repeater { model: s.levels.length ? s.levels : Array(40).fill(0.05)
                           Rectangle { required property var modelData; width: (body.width - 160) / 40; height: Math.max(2, 200 * modelData); y: 200 - height; color: P.hi } }
            }
            Row { spacing: 40
                  Repeater { model: [["|<", "prev"], [s.sys?.playing ? "PAUSE" : "PLAY", "play"], [">|", "next"]]
                             Text { required property var modelData; text: "[ " + modelData[0] + " ]"; color: P.hi; font.family: s.f; font.pixelSize: 26
                                    MouseArea { anchors.fill: parent; onClicked: s.act(parent.modelData[1], null) } } } }
        }
    }
    // scanlines + vignette
    Column { anchors.fill: parent; clip: true; Repeater { model: Math.ceil(s.height / 4)
             Rectangle { width: s.width; height: 4; color: "transparent"; Rectangle { width: parent.width; height: 1; color: "#30000000" } } } }
    Rectangle { anchors.fill: parent; color: "transparent"; border.color: "#5560e597"; border.width: 8; opacity: 0.25 }
}
