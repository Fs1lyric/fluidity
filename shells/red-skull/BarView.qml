// His NiOS waybar (the other shots): one dark floating strip centred at the top: settings mark, the focused
// window, the workspace squares (the active one hot pink), the track, date/time and a red power button.
// Recoloured in the hacker palette (maroon, dusty tan, #fc2e64). Pure view.
import QtQuick

Item {
    id: bar
    property var sys
    implicitHeight: 40
    readonly property color strip: "#ec1d0b12"
    readonly property color chip: "#32141f"
    readonly property color tan: "#bfb098"
    readonly property color pink: "#fc2e64"
    readonly property string sans: "Open Sans"
    readonly property string icons: "Iosevka Nerd Font"
    component Lbl: Row {
        property string glyph
        property string value
        property color tint: bar.tan
        spacing: 6; height: 28
        Text { text: parent.glyph; font.family: bar.icons; font.pixelSize: 13; color: parent.tint; anchors.verticalCenter: parent.verticalCenter }
        Text { visible: parent.value !== ""; text: parent.value; font.family: bar.sans; font.weight: Font.DemiBold; font.pixelSize: 12; color: bar.tan; anchors.verticalCenter: parent.verticalCenter
               width: Math.min(implicitWidth, 200); elide: Text.ElideRight }
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter; y: 5; height: 30; radius: 8; color: bar.strip; border.color: "#4d1927"; border.width: 1
        width: row.implicitWidth + 16
        Row {
            id: row; x: 8; height: parent.height; spacing: 16
            Rectangle { width: 24; height: 22; radius: 5; color: bar.chip; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: "\u{F0493}"; font.family: bar.icons; font.pixelSize: 13; color: bar.tan } }
            Lbl { glyph: "\u{F05B6}"; value: bar.sys?.appClass || "Desktop" }
            Rectangle { height: 20; radius: 5; color: "#4d1927"; width: ws.implicitWidth + 12; anchors.verticalCenter: parent.verticalCenter
                        Row { id: ws; anchors.centerIn: parent; spacing: 5
                              Repeater { model: (bar.sys?.tags ?? []).slice(0, 6)
                                         Rectangle { required property var modelData; width: 14; height: 10; radius: 2
                                                     color: modelData.state === "focused" ? bar.pink : modelData.state === "occupied" ? "#8f7d5c" : "#33151f" } } } }
            Lbl { visible: bar.sys?.hasPlayer ?? false; glyph: "\u{F075A}"; tint: bar.pink; value: bar.sys?.track ?? "" }
            Lbl { glyph: "\u{F00ED}"; value: Qt.formatDateTime(bar.sys?.now ?? new Date(), "dd/MM/yy  HH:mm") }
            Lbl { glyph: (bar.sys?.muted ?? false) ? "\u{F075F}" : "\u{F057E}"; value: Math.round((bar.sys?.volume ?? 0) * 100) + "%" }
            Rectangle { width: 24; height: 22; radius: 5; color: bar.pink; anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: "\u{F0425}"; font.family: bar.icons; font.pixelSize: 13; color: "#1d0b12" } }
        }
    }
}
