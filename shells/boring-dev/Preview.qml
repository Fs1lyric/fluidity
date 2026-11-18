// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; cpu: 0.02; ramUsed: 12.7; temp: 46; netDown: 251; netUp: 136; volume: 1
              now: new Date(2026, 10, 16, 23, 59, 0)
              tags: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => ({ id: i, count: 1, state: i === 3 ? "focused" : i < 3 ? "occupied" : "empty" })) }
    BarView { x: parent.width * 0.18; y: 6; width: parent.width * 0.64; height: 30; sys: fake }
    // niri columns with Catppuccin borders: btop on the left, the radar on the right
    Rectangle { x: 30; y: 52; width: 930; height: 1000; radius: 4; color: "#1e1e2e"; opacity: 0.93; border.color: "#45475a"; border.width: 2 }
    Rectangle { x: 980; y: 52; width: 910; height: 1000; radius: 4; color: "#1e1e2e"; opacity: 0.93; border.color: "#b4befe"; border.width: 2
        Text { x: 14; y: 10; text: "6 km SE of Tokyo  ⏸ 10:00p · -110m · 14% echo"; color: "#a6adc8"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14 } }
}
