// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; track: "Digital Gaze"; artist: "desktophut"; playing: false }
    HudView { anchors.fill: parent; sys: fake; wallpaper: "wall.jpg"; cursorX: 2286; cursorY: 1330; gpuTemp: "56"
              levels: Array(48).fill(0).map((_, i) => Math.abs(Math.sin(i * 0.45)) * (0.3 + 0.7 * Math.abs(Math.cos(i * 0.13)))) }
    PanelView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 34; sys: fake
                cpuHistory: [0.1, 0.3, 0.2, 0.5, 0.4, 0.2, 0.6, 0.3, 0.2, 0.4, 0.1, 0.3, 0.2] }
    PanelView { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 34; lower: true; sys: fake }
}
