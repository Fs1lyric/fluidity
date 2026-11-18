// Abhra00's waybar ("slanted-bubbles" in Matuprland, everforest from matugen): a row of dark rounded bubbles in
// italic Geist Mono. Left: the pink Arch mark, the player's round prev/pause/next buttons, the ♪ track ♪ bubble.
// Centre: weather, the workspaces (dots; the active one is a wide green pill with its number), notifications.
// Right: network + Bluetooth, battery, volume, Wi-Fi strength and the clock with its pink icon. Pure view.
import QtQuick

Item {
    id: bar
    property var sys
    property bool panelOpen: false
    readonly property color bubble: "#272e33"
    readonly property color hi: "#414b50"
    readonly property color fg: "#d3c6aa"
    readonly property color green: "#83c092"
    readonly property color pink: "#d699b6"
    readonly property string mono: "Geist Mono"
    readonly property string icons: "Iosevka Nerd Font"
    implicitHeight: 44

    component Bubble: Rectangle {
        default property alias content: inner.data
        property int pad: 14
        height: 32; radius: 16; color: bar.bubble
        width: inner.childrenRect.width + pad * 2
        anchors.verticalCenter: parent?.verticalCenter
        Item { id: inner; x: parent.pad; height: parent.height }
    }
    component Glyph: Text { font.family: bar.icons; font.pixelSize: 14; color: bar.fg; anchors.verticalCenter: parent?.verticalCenter }
    component Label: Text { font.family: bar.mono; font.pixelSize: 12; font.italic: true; font.bold: true; color: bar.fg; anchors.verticalCenter: parent?.verticalCenter }

    Rectangle { anchors.fill: parent; color: "#8c272e33" }

    Row {
        x: 6; height: parent.height; spacing: 8
        Bubble { pad: 12; Glyph { text: "\u{F08C7}"; color: bar.pink; font.pixelSize: 18 } }
        Bubble { visible: bar.sys?.hasPlayer ?? false; pad: 8
                 Row { spacing: 8; height: 32
                       Repeater { model: [["\u{F04AE}", "#7fbbb3"], [bar.sys?.playing ? "\u{F03E4}" : "\u{F040A}", bar.pink], ["\u{F04AD}", "#7fbbb3"]]
                                  Rectangle { required property var modelData; width: 22; height: 22; radius: 11; color: bar.hi; anchors.verticalCenter: parent.verticalCenter
                                              Text { anchors.centerIn: parent; text: modelData[0]; font.family: bar.icons; font.pixelSize: 12; color: modelData[1] } } } } }
        Bubble { visible: bar.sys?.hasPlayer ?? false
                 Label { width: Math.min(implicitWidth, 320); elide: Text.ElideRight
                         text: "♪ " + (bar.sys?.artist ? bar.sys.artist + " - " : "") + (bar.sys?.track ?? "") + " ♪" } }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter; height: parent.height; spacing: 8
        Bubble { visible: (bar.sys?.weatherTemp ?? "") !== ""
                 Row { spacing: 10; height: 32; Glyph { text: "\u{F0F31}"; color: bar.pink } Label { text: (bar.sys?.weatherTemp ?? "") + "°" } } }
        Bubble { pad: 6
                 Row { spacing: 6; height: 32
                       Repeater { model: (bar.sys?.tags ?? []).slice(0, 5)
                                  Rectangle { required property var modelData
                                              readonly property bool on: modelData.state === "focused"
                                              width: on ? 50 : 22; height: 18; radius: 9; anchors.verticalCenter: parent.verticalCenter
                                              color: on ? bar.green : bar.hi
                                              Behavior on width { NumberAnimation { duration: 200 } }
                                              Text { anchors.centerIn: parent; visible: parent.on; text: modelData.id; font.family: bar.mono; font.bold: true; font.pixelSize: 11; color: "#1e2326" } } } } }
        Bubble { Row { spacing: 8; height: 32; Label { text: "0" } Glyph { text: "\u{F009A}" } } }
    }

    Row {
        anchors.right: parent.right; anchors.rightMargin: 6; height: parent.height; spacing: 8
        Bubble { Row { spacing: 12; height: 32
                       Glyph { text: bar.sys?.online ? "\u{F05A9}" : "\u{F05AA}" }
                       Glyph { text: bar.sys?.btOn ? "\u{F00AF}" : "\u{F00B2}" } } }
        Bubble { visible: bar.sys?.hasBattery ?? false
                 Row { spacing: 8; height: 32; Glyph { text: bar.sys?.charging ? "\u{F0084}" : "\u{F0079}" }
                       Label { text: Math.round((bar.sys?.battery ?? 1) * 100) + "%" } } }
        Bubble { Row { spacing: 8; height: 32; Glyph { text: bar.sys?.muted ? "\u{F075F}" : "\u{F057E}" }
                       Label { text: Math.round((bar.sys?.volume ?? 0) * 100) + "%" } } }
        Bubble { visible: !(bar.sys?.wired ?? false)
                 Row { spacing: 8; height: 32; Glyph { text: "\u{F05A9}" }
                       Label { text: Math.round((bar.sys?.wifiStrength ?? 0) * 100) + "%" } } }
        Bubble { color: bar.panelOpen ? bar.hi : bar.bubble
                 Row { spacing: 8; height: 32; Glyph { text: "\u{F0954}"; color: bar.pink }
                       Label { text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "hh:mm:ss AP") } } }
    }
}
