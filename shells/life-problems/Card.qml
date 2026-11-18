// The retro card every widget sits on: cream, 3 px ink outline, rounded, and a hard ink shadow down-right.
import QtQuick
import "Pal.js" as P

Item {
    id: c
    default property alias content: face.data
    property int shadow: 5
    Rectangle { x: c.shadow; y: c.shadow; width: c.width; height: c.height; radius: 10; color: P.ink; visible: c.shadow > 0 }
    Rectangle { id: face; width: c.width; height: c.height; radius: 10; color: P.cream; border.color: P.ink; border.width: 3 }
}
