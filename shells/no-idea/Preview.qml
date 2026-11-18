// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    TopView { anchors { top: parent.top; left: parent.left; right: parent.right }
              tags: [1, 2, 3, 4, 5, 6, 7, 8, 9].map(i => ({ id: i, state: i === 1 ? "focused" : i < 4 ? "occupied" : "empty" })) }
    SidebarView { x: 0; y: 0 }
    DockView { anchors { bottom: parent.bottom; bottomMargin: 8; horizontalCenter: parent.horizontalCenter }
               iconDir: "candy/"
               apps: ["flameshot", "zen", "spotify", "obsidian", "nvim", "calendar", "vesktop", "com.mitchellh.ghostty", "thunar", "btop"].map(i => ({ icon: i, cmd: [] })) }
}
