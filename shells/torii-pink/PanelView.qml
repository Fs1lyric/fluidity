// Super+F1: the centre island drops down into a bigger notch (his island grown into a panel): the player with
// cover, progress and controls, a volume bar, the quick chips and a workspace row. Keyboard-only through
// KeyNav: arrows/hjkl, Enter, Left/Right on volume, Enter on a workspace goes there, Esc folds it back.
import QtQuick

Rectangle {
    id: p
    property var sys
    property bool showSelection: false
    signal act(string what, var arg)
    signal close()
    readonly property color chip: "#282839"
    readonly property color pink: "#f6a0ca"
    readonly property color dim: "#b9b9c9"
    readonly property string sans: "Lexend Deca"
    readonly property string icons: "Iosevka Nerd Font"
    implicitWidth: 460; implicitHeight: col.implicitHeight + 40
    radius: 22; color: "#1c1e2a"
    focus: true
    onActiveFocusChanged: if (activeFocus) keys.forceActiveFocus()
    Rectangle { width: parent.width; height: 24; color: parent.color }   // flat top: it hangs from the bar

    readonly property var chips: [
        { id: "wifi", glyph: "\u{F05A9}", label: "wifi", on: sys?.wifiOn ?? false },
        { id: "bt", glyph: "\u{F00AF}", label: "bluetooth", on: sys?.btOn ?? false },
        { id: "mic", glyph: "\u{F036D}", label: "mic off", on: sys?.micMuted ?? false },
        { id: "caffeine", glyph: "\u{F0176}", label: "awake", on: sys?.caffeine ?? false }]
    readonly property var apps: [["launcher", "\u{F003B}", "apps"], ["terminal", "\u{F018D}", "kitty"], ["shot", "\u{F0104}", "shot"], ["power", "\u{F0425}", "power"]]

    KeyNav {
        id: keys
        focus: true
        always: p.showSelection
        rows: [["prev", "play", "next"], ["volume"], p.chips.map(c => c.id), (p.sys?.tags ?? []).slice(0, 9).map(t => "ws" + t.id), p.apps.map(a => a[0])]
        sliders: ["volume"]
        onPress: id => { if (id.startsWith("ws")) p.act("ws", parseInt(id.slice(2)))
                         else if (id === "volume") p.act("mute", null)
                         else p.act(id, null)
                         if (["launcher", "terminal", "shot", "power"].indexOf(id) >= 0 || id.startsWith("ws")) p.close() }
        onNudge: (id, d) => p.act("volumeStep", d * 0.05)
        onClose: p.close()
    }

    component Sel: Rectangle {
        property string key
        anchors.fill: parent; anchors.margins: -3; radius: (parent.radius ?? 6) + 3; color: "transparent"
        border.color: p.pink; border.width: 2; visible: keys.isSel(key)
    }

    Column {
        id: col
        x: 22; y: 22; width: parent.width - 44; spacing: 16
        Row {
            spacing: 16
            Rectangle { width: 86; height: 86; radius: 14; color: p.chip; clip: true
                        Image { anchors.fill: parent; source: p.sys?.art ?? ""; fillMode: Image.PreserveAspectCrop }
                        Text { anchors.centerIn: parent; visible: !(p.sys?.art); text: "\u{F03E9}"; font.family: p.icons; font.pixelSize: 34; color: "white" } }
            Column { width: col.width - 102; spacing: 4
                     Text { width: parent.width; elide: Text.ElideRight; text: p.sys?.artist || "nothing playing"; font.family: p.sans; font.pixelSize: 11; color: p.dim }
                     Text { width: parent.width; elide: Text.ElideRight; text: p.sys?.track ?? ""; font.family: p.sans; font.pixelSize: 16; color: "white" }
                     Rectangle { width: parent.width; height: 3; radius: 1.5; color: "#3a3a52"
                                 Rectangle { height: 3; radius: 1.5; color: p.pink; width: parent.width * Math.min(1, (p.sys?.position ?? 0) / Math.max(1, p.sys?.length ?? 1)) } }
                     Row { spacing: 18; topPadding: 6
                           Repeater { model: [["prev", "\u{F04AE}"], ["play", (p.sys?.playing ?? false) ? "\u{F03E4}" : "\u{F040A}"], ["next", "\u{F04AD}"]]
                                      Rectangle { required property var modelData; width: 36; height: 28; radius: 8
                                                  color: modelData[0] === "play" ? p.pink : p.chip
                                                  Text { anchors.centerIn: parent; text: modelData[1]; font.family: p.icons; font.pixelSize: 15
                                                         color: modelData[0] === "play" ? "#1c1e2a" : "white" }
                                                  Sel { key: modelData[0] } } } } }
        }
        Rectangle {
            width: parent.width; height: 34; radius: 9; color: p.chip
            Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: (p.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}"; font.family: p.icons; font.pixelSize: 15; color: "white" }
            Rectangle { x: 40; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 90; height: 6; radius: 3; color: "#3a3a52"
                        Rectangle { height: 6; radius: 3; color: p.pink; width: parent.width * Math.min(1, p.sys?.volume ?? 0) } }
            Text { anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                   text: Math.round((p.sys?.volume ?? 0) * 100); font.family: p.sans; font.pixelSize: 12; color: "white" }
            Sel { key: "volume" }
        }
        Row {
            spacing: 8
            Repeater { model: p.chips
                       Rectangle { required property var modelData; width: (col.width - 24) / 4; height: 32; radius: 9
                                   color: modelData.on ? p.pink : p.chip
                                   Row { anchors.centerIn: parent; spacing: 6
                                         Text { text: modelData.glyph; font.family: p.icons; font.pixelSize: 13; color: modelData.on ? "#1c1e2a" : "white" }
                                         Text { text: modelData.label; font.family: p.sans; font.pixelSize: 11; color: modelData.on ? "#1c1e2a" : "white" } }
                                   Sel { key: modelData.id } } }
        }
        Row {
            spacing: 8; anchors.horizontalCenter: parent.horizontalCenter
            Repeater { model: (p.sys?.tags ?? []).slice(0, 9)
                       Rectangle { required property var modelData; width: 34; height: 26; radius: 8
                                   color: modelData.state === "focused" ? p.pink : modelData.state === "occupied" ? "#6b4f68" : p.chip
                                   Text { anchors.centerIn: parent; text: modelData.id; font.family: p.sans; font.pixelSize: 11
                                          color: modelData.state === "focused" ? "#1c1e2a" : "white" }
                                   Sel { key: "ws" + modelData.id } } }
        }
        Row {
            spacing: 8
            Repeater { model: p.apps
                       Rectangle { required property var modelData; width: (col.width - 24) / 4; height: 32; radius: 9; color: p.chip
                                   Row { anchors.centerIn: parent; spacing: 6
                                         Text { text: modelData[1]; font.family: p.icons; font.pixelSize: 13; color: modelData[0] === "power" ? p.pink : "white" }
                                         Text { text: modelData[2]; font.family: p.sans; font.pixelSize: 11; color: "white" } }
                                   Sel { key: modelData[0] } } }
        }
        Text { anchors.horizontalCenter: parent.horizontalCenter; text: "arrows/hjkl · enter · ←→ volume · esc"
               font.family: p.sans; font.pixelSize: 9; color: p.dim }
    }
}
