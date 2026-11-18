// The big pixel clock, the date in pixel capitals, and the forecast row (weather glyph, high and low).
import QtQuick

Column {
    id: c
    property date now: new Date()
    property var days: []
    readonly property color ink: "#fcefe6"
    spacing: 14
    function glyph(code) { return code === 113 ? "󰖙" : code === 116 ? "󰖕" : code <= 122 ? "󰖐" : code < 200 || code >= 263 && code <= 321 ? "󰖗"
                                  : code >= 323 && code <= 395 && code !== 353 && code !== 356 && code !== 359 ? "󰖘" : code >= 386 ? "󰖓" : "󰖖" }
    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(c.now, "HH:mm"); font.family: "Silkscreen"; font.bold: true; font.pixelSize: 132; color: c.ink
           font.letterSpacing: -4 }
    Text { anchors.horizontalCenter: parent.horizontalCenter; text: Qt.formatDateTime(c.now, "dddd, MMM dd").toUpperCase(); font.family: "Silkscreen"; font.bold: true; font.pixelSize: 30; color: c.ink }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter; spacing: 54; topPadding: 6
        Repeater {
            model: c.days
            Column {
                required property var modelData
                required property int index
                spacing: 2
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.modelData.max + "C."; font.family: "Silkscreen"; font.bold: true; font.pixelSize: 14; color: c.ink }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: c.glyph(parent.modelData.code); font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 34; color: c.ink }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.index === 0 ? Qt.formatDate(parent.modelData.day, "ddd").toUpperCase() : parent.modelData.min + "C."
                       font.family: "Silkscreen"; font.bold: true; font.pixelSize: 14; color: c.ink }
                Text { anchors.horizontalCenter: parent.horizontalCenter; visible: parent.index > 0; text: Qt.formatDate(parent.modelData.day, "ddd").toUpperCase()
                       font.family: "Silkscreen"; font.bold: true; font.pixelSize: 14; color: c.ink }
            }
        }
    }
}
