// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick
import "Pal.js" as P

Item {
    anchors.fill: parent
    FakeSys { id: fake; title: "/home/fun - qutebrowser"; track: "Where Did You Sleep Last Night"; artist: "Nirvana - MTV Unplugged In New York"
              now: new Date(2021, 9, 16, 11, 28, 0); cpu: 0.05; ram: 0.12; volume: 1 }
    DeskView { anchors.fill: parent; sys: fake }
    // a qutebrowser window: cream title bar with two rings, hard shadow
    Card {
        x: 760; y: 170; width: 400; height: 640; shadow: 10
        Rectangle { x: 0; y: 0; width: parent.width; height: 40; radius: 10; color: P.cream; border.color: P.ink; border.width: 3 }
        Row { x: 14; y: 11; spacing: 6; Repeater { model: 2; Rectangle { width: 18; height: 18; radius: 9; color: "transparent"; border.color: P.ink; border.width: 3 } } }
        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 10; text: fake.title; font.family: P.mono; font.pixelSize: 14; font.weight: Font.Medium; color: P.ink }
        Rectangle { x: 3; y: 40; width: parent.width - 6; height: parent.height - 43; color: P.teal }
        Card { x: 26; y: 100; width: 340; height: 60; Text { x: 18; anchors.verticalCenter: parent.verticalCenter; text: "Search"; font.family: P.mono; font.pixelSize: 15; color: P.ink } }
        Card { x: 26; y: 200; width: 340; height: 200
               Text { anchors.horizontalCenter: parent.horizontalCenter; y: 40; text: "Welcome!"; font.family: P.mono; font.pixelSize: 22; font.bold: true; color: P.ink } }
    }
    BarView { x: 46; y: 38; width: parent.width - 92; height: 34; sys: fake }
    FrameView { anchors.fill: parent }
}
