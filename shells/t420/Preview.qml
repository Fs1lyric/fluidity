// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; title: "st — ~/src/dwm"; track: "Kuroi Uta"; now: new Date(2025, 10, 17, 21, 30, 0) }
    BarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 22; sys: fake }
    // dwm's tiling: a master st on the left, the stack on the right, 2 px green border on the focused one
    Rectangle { x: 0; y: 22; width: 960; height: 1058; color: "#0b0809"; border.color: "#7fc98f"; border.width: 2
        Text { x: 10; y: 8; color: "#d8cfc8"; font.family: "DejaVu Sans Mono"; font.pixelSize: 14; lineHeight: 1.2
               text: "lyric@t420 ~/src/dwm $ make clean install\nrm -f dwm drw.o dwm.o util.o\ncc -c -std=c99 -pedantic -Wall -Os drw.c\ncc -o dwm drw.o dwm.o util.o -lX11\ninstalling executable file to /usr/local/bin\nlyric@t420 ~/src/dwm $ ▊" } }
    Rectangle { x: 960; y: 22; width: 960; height: 529; color: "#120c0e"; border.color: "#2a1e20"; border.width: 2 }
    Rectangle { x: 960; y: 551; width: 960; height: 529; color: "#120c0e"; border.color: "#2a1e20"; border.width: 2 }
}
