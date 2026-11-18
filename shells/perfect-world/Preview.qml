// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    TagsView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 10
               tags: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => ({ id: i, state: i === 2 ? "focused" : [1, 3, 5, 6].indexOf(i) >= 0 ? "occupied" : "empty" })) }
    SidebarView { anchors { top: parent.top; bottom: parent.bottom; left: parent.left } width: 300 }
    DockView { anchors { bottom: parent.bottom; bottomMargin: 8; horizontalCenter: parent.horizontalCenter }
               items: ["zen", "vesktop", "calendio", "obsidian", "ghostty", "spotify"].map((c, i) => ({ cls: c, open: i !== 3, focused: i === 1 })) }
}
