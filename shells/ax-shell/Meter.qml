import QtQuick
import "Pal.js" as P

Column {
    id: m
    property string label
    property real value
    spacing: 4; width: 150
    Row { width: m.width
          Text { text: m.label; color: P.dim; font.family: P.mono; font.pixelSize: 11; width: m.width - 40 }
          Text { text: Math.round(m.value * 100) + "%"; color: P.fg; font.family: P.mono; font.pixelSize: 11; width: 40; horizontalAlignment: Text.AlignRight } }
    Rectangle { width: m.width; height: 6; radius: 3; color: P.pill
                Rectangle { width: m.width * Math.max(0, Math.min(1, m.value)); height: 6; radius: 3; color: P.pink } }
}
