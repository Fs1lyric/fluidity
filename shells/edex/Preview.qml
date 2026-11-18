// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick
import "Pal.js" as P

Rectangle {
    anchors.fill: parent
    color: P.black
    ColumnsView { anchors { top: parent.top; left: parent.left } width: 660; height: parent.height - 335; animate: false }
    FrameView { x: 668; y: 4; width: parent.width - 676; height: parent.height - 347 }
    BottomView { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 335 }
}
