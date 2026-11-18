import QtQuick
import "Pal.js" as P

Text {
    property bool glyph: false
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    color: P.ink; font.family: glyph ? P.icon : P.round; font.pixelSize: glyph ? 13 : 12; font.weight: Font.ExtraBold
}
