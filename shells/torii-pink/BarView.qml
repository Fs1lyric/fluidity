// gitKhym's AGS bar ("yuu"): three dark islands in Lexend Deca with the #F6A0CA accent. Left: the pink Arch
// mark, then stat chips (CPU, temperature, RAM, disk, window class, title). Centre: the island hangs from the top
// edge like a notch: the paw, artist over title with a thin pink progress line, prev/pause/next. Right: volume,
// headphones/Bluetooth, battery; the date over the time and the pink weather chip. Pure view.
import QtQuick

Item {
    id: bar
    property var sys
    property bool expanded: false        // the island drops down into the panel (shell.qml)
    readonly property color bg: "#1c1e2a"
    readonly property color chip: "#282839"
    readonly property color pink: "#f6a0ca"
    readonly property color fg: "#ffffff"
    readonly property string sans: "Lexend Deca"
    readonly property string icons: "Iosevka Nerd Font"
    implicitHeight: 44

    component Chip: Rectangle {
        default property alias content: inner.data
        height: 24; radius: 7; color: bar.chip
        width: inner.childrenRect.width + 20
        anchors.verticalCenter: parent?.verticalCenter
        Item { id: inner; x: 10; height: parent.height }
    }
    component Stat: Row {
        property string glyph
        property string value
        spacing: 6; height: 24
        Text { text: parent.glyph; font.family: bar.icons; font.pixelSize: 12; color: bar.fg; anchors.verticalCenter: parent.verticalCenter }
        Text { text: parent.value; font.family: bar.sans; font.pixelSize: 11; color: bar.fg; anchors.verticalCenter: parent.verticalCenter }
    }

    Text { x: 20; anchors.verticalCenter: parent.verticalCenter; text: "\u{F08C7}"; font.family: bar.icons; font.pixelSize: 22; color: bar.pink }

    Rectangle {
        x: 76; y: 6; height: 32; radius: 10; color: bar.bg
        width: left.implicitWidth + 12
        Row { id: left; x: 6; height: parent.height; spacing: 6
              Chip { Stat { glyph: "\u{F061A}"; value: Math.round((bar.sys?.cpu ?? 0) * 100) + "%" } }
              Chip { Stat { glyph: "\u{F050F}"; value: Math.round(bar.sys?.temp ?? 0) + "°C" } }
              Chip { Stat { glyph: "\u{F035B}"; value: Math.round((bar.sys?.ram ?? 0) * 100) + "%" } }
              Chip { Stat { glyph: "\u{F02CA}"; value: Math.round((bar.sys?.diskUsed ?? 0) * 100) + "%" } }
              Chip { visible: (bar.sys?.appClass ?? "") !== ""; Stat { glyph: "\u{F05B6}"; value: bar.sys?.appClass ?? "" } }
              Chip { visible: (bar.sys?.title ?? "") !== ""
                     Text { anchors.verticalCenter: parent.verticalCenter; width: Math.min(implicitWidth, 160); elide: Text.ElideRight
                            text: bar.sys?.title ?? ""; font.family: bar.sans; font.pixelSize: 11; color: bar.fg } } }
    }

    // the notch
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter; y: -12
        width: 360; height: 56; radius: 18; color: bar.bg
        visible: !bar.expanded
        Text { x: 20; y: 20; text: "\u{F03E9}"; font.family: bar.icons; font.pixelSize: 22; color: bar.fg }
        Column { x: 58; y: 16; width: 190; spacing: 2
                 Text { width: parent.width; elide: Text.ElideRight; text: bar.sys?.artist || "nothing playing"; font.family: bar.sans; font.pixelSize: 10; color: "#b9b9c9" }
                 Text { width: parent.width; elide: Text.ElideRight; text: bar.sys?.track ?? ""; font.family: bar.sans; font.pixelSize: 12; color: bar.fg }
                 Rectangle { width: parent.width; height: 2; color: "#3a3a52"
                             Rectangle { height: 2; color: bar.pink; width: parent.width * Math.min(1, (bar.sys?.position ?? 0) / Math.max(1, bar.sys?.length ?? 1)) } } }
        Row { anchors.right: parent.right; anchors.rightMargin: 18; y: 20; spacing: 14
              Text { text: "\u{F04AE}"; font.family: bar.icons; font.pixelSize: 14; color: "#b9b9c9" }
              Text { text: (bar.sys?.playing ?? false) ? "\u{F03E4}" : "\u{F040A}"; font.family: bar.icons; font.pixelSize: 14; color: bar.fg }
              Text { text: "\u{F04AD}"; font.family: bar.icons; font.pixelSize: 14; color: "#b9b9c9" } }
    }

    Row {
        anchors.right: parent.right; anchors.rightMargin: 14; height: parent.height; spacing: 14
        Rectangle {
            y: 6; height: 32; radius: 10; color: bar.bg; width: right.implicitWidth + 12; anchors.verticalCenter: parent.verticalCenter
            Row { id: right; x: 6; height: parent.height; spacing: 6
                  Chip { Stat { glyph: (bar.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}"; value: Math.round((bar.sys?.volume ?? 0) * 100) } }
                  Chip { Stat { glyph: "\u{F02CB}"; value: (bar.sys?.btConnected ?? 0) > 0 ? bar.sys.btConnected + " connected" : (bar.sys?.btOn ? "on" : "off") } }
                  Chip { visible: bar.sys?.hasBattery ?? false
                         Stat { glyph: "\u{F0079}"; value: Math.round((bar.sys?.battery ?? 1) * 100) + "%" } } }
        }
        Column { anchors.verticalCenter: parent.verticalCenter
                 Text { anchors.right: parent.right; text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "ddd MMM d"); font.family: bar.sans; font.pixelSize: 11; color: bar.fg }
                 Text { anchors.right: parent.right; text: Qt.formatDateTime(bar.sys?.now ?? new Date(), "h:mm AP"); font.family: bar.sans; font.pixelSize: 11; font.weight: Font.Medium; color: bar.fg } }
        Rectangle { visible: (bar.sys?.weatherTemp ?? "") !== ""; anchors.verticalCenter: parent.verticalCenter
                    height: 28; radius: 8; color: bar.pink; width: wt.implicitWidth + 22
                    Text { id: wt; anchors.centerIn: parent; text: "\u{F0599}  " + (bar.sys?.weatherTemp ?? "") + "°"; font.family: bar.sans; font.pixelSize: 12; font.weight: Font.Medium; color: bar.bg } }
    }
}
