// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "MPLUSRounded1c-Black.ttf" }
    FontLoader { source: "MPLUSRounded1c-ExtraBold.ttf" }
    FakeSys { id: fake; workspace: 4; track: "TGIF"; artist: "XG"; user: "art.shoon"; weatherTemp: "24"; battery: 0.48
              now: new Date(2026, 9, 11, 19, 56, 0)
              todos: [{ text: "Shell name? Puyopuyo or SekaiPop", done: false }, { text: "welcome screen", done: true }, { text: "smart optimization", done: true },
                      { text: "able to change app icon and cursor live on wayland", done: true }, { text: "redesign web, cute, clip for phone", done: true },
                      { text: "not working: gamemode and on-screen keyboard", done: false }] }
    BarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 34; sys: fake }
    TodoView { x: 14; y: 120; sys: fake }
    ClockView { x: parent.width - implicitWidth - 40; y: parent.height * 0.4; now: fake.now }
    DockView { x: (parent.width - implicitWidth) / 2; y: parent.height - 62; width: implicitWidth; height: 54; sys: fake }
}
