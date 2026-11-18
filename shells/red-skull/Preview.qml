// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "FragileBombersAttack.otf" }
    FontLoader { source: "OpenSans-SemiBold.ttf" }
    FakeSys { id: fake; track: "Blue Light"; appClass: ""; user: "keyitdev"; volume: 0.6; now: new Date(2025, 7, 8, 16, 24, 0)
              tags: [1, 2, 3, 4, 5, 6].map(i => ({ id: i, count: i < 3 ? 1 : 0, state: i === 1 ? "focused" : i < 3 ? "occupied" : "empty" })) }
    BarView { width: parent.width; height: 40; sys: fake }
    ClockView { x: parent.width - implicitWidth - parent.width * 0.13; y: parent.height * 0.17; now: fake.now }
    PanelView { x: parent.width - implicitWidth - parent.width * 0.12; y: parent.height * 0.52; width: implicitWidth; height: implicitHeight; sys: fake; showSelection: true; scale: 0.85; transformOrigin: Item.Top }
}
