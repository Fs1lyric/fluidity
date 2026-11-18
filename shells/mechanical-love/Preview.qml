// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    SidebarView { anchors { top: parent.top; bottom: parent.bottom; left: parent.left } width: 300
                  iconDir: "icons/"; weatherDir: "weather/" }
    TagbarView { anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter } tagDir: "taglist/"; iconDir: "icons/"
                 tags: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => ({ id: i, state: i === 2 ? "focused" : [1, 5, 9].indexOf(i) >= 0 ? "occupied" : "empty" })) }
}
