// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; title: "Hartshorne - 1977 - Algebraic Geometry.pdf"; artist: "Rameau"; track: "Les sauvages" }
    // a zathura page on paper with his 3 px black border, like the post
    Rectangle { x: 120; y: 60; width: 900; height: 950; color: "#fdf6e3"; border.color: "#000000"; border.width: 3
        Column { x: 60; y: 50; width: parent.width - 120; spacing: 14
            Text { text: "Blowing Up"; font.family: "serif"; font.italic: true; font.pixelSize: 30; color: "#000000" }
            Repeater { model: 9
                Text { width: parent.width; wrapMode: Text.WordWrap; font.family: "serif"; font.pixelSize: 22; color: "#000000"
                       text: "As another example of a birational map, we will now construct the blowing-up of a variety at a point. This important construction is the main tool in the resolution of singularities." } } } }
    Rectangle { x: 1050; y: 160; width: 640; height: 360; color: "#fdf6e3"; border.color: "#000000"; border.width: 3 }
    Rectangle { x: 1140; y: 600; width: 560; height: 120; color: "#fdf6e3"; border.color: "#000000"; border.width: 3
        Row { anchors { bottom: parent.bottom; bottomMargin: 6; horizontalCenter: parent.horizontalCenter } spacing: 3
            Repeater { model: 60; Rectangle { width: 6; height: 4 + Math.abs(Math.sin(index * 1.7)) * 30 * (index === 38 ? 3 : 1); color: "#000000"; anchors.bottom: parent.bottom } } } }
    BarView { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 30; sys: fake }
}
