// One yuzubar word: Montserrat on the teal, a salmon underline, clickable.
import QtQuick

Item {
    id: w
    property string text
    signal clicked()
    implicitWidth: t.implicitWidth; height: parent ? parent.height : 30
    Text { id: t; anchors.verticalCenter: parent.verticalCenter; text: w.text; color: "#f0fae8"; font.family: "Montserrat Light"; font.pixelSize: 18 }
    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: "#c8705a" }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: w.clicked() }
}
