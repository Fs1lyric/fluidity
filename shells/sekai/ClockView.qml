// The big desktop clock: chunky rounded digits, the hour in lilac and the minutes in sky blue, each with a
// dark teal outline and a white rim, "PM" tucked under the minutes.
import QtQuick
import "Pal.js" as P

Item {
    id: c
    property date now: new Date()
    implicitWidth: row.implicitWidth; implicitHeight: 130
    Row {
        id: row
        Repeater {
            model: [[Qt.formatDateTime(c.now, "hh AP").slice(0, 2), P.lilac], [":", P.ink], [Qt.formatDateTime(c.now, "mm"), P.sky]]
            Item {
                required property var modelData
                width: face.implicitWidth; height: face.implicitHeight
                // a thick ink outline: the digits stamped in ink around the face, then the white rim, then the face
                Repeater { model: 16
                    Text { required property int index; x: 5 * Math.cos(index * Math.PI / 8); y: 5 * Math.sin(index * Math.PI / 8)
                           text: parent.modelData[0]; color: P.ink; font: face.font } }
                Text { id: face; text: parent.modelData[0]; color: parent.modelData[1]; style: Text.Outline; styleColor: P.paper
                       font.family: P.round; font.pixelSize: 110; font.weight: Font.Black }
            }
        }
    }
    Text { anchors { right: row.right; top: row.bottom; topMargin: -22 } text: Qt.formatDateTime(c.now, "AP")
           font.family: P.round; font.pixelSize: 14; font.weight: Font.Black; color: P.ink }
}
