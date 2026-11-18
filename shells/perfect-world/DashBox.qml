// One dashboard box: w x h with a 6 px gap around it, radius 12, background colour.
import QtQuick
import "Pal.js" as P

Item {
    id: b
    property int w: 150
    property int h: 150
    property color fill: P.bg
    default property alias content: inner.data
    width: w + 12; height: h + 12
    Rectangle { id: inner; x: 6; y: 6; width: b.w; height: b.h; radius: 12; color: b.fill }
}
