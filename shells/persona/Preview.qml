// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "DMSerifDisplay.ttf" }
    FontLoader { source: "Anton.ttf" }
    FakeSys { id: fake; now: new Date(2026, 5, 15, 21, 30, 0) }
    DeskView { anchors.fill: parent; sys: fake; depth: true }
}
