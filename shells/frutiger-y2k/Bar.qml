// A thin glass bar used by the meters: hairline track, blue fill.
import QtQuick
import "Pal.js" as P

Rectangle {
    property real value
    property color fill: P.blue
    height: 4; radius: 2; color: "#dde3ea"
    Rectangle { height: parent.height; radius: 2; color: parent.fill; width: parent.width * Math.max(0, Math.min(1, parent.value)) }
}
