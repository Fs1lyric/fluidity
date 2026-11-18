// One of his eww boxes (eww.yuck "computer-box"): plain black, bold white text, no styling sheet at all.
import QtQuick

Rectangle {
    property string text: "remove ads $9.99"
    color: "#000000"
    Text { x: 12; anchors.verticalCenter: parent.verticalCenter; text: parent.text; color: "#ffffff"
           font.family: "Cantarell"; font.pixelSize: 14; font.weight: Font.Bold }
}
