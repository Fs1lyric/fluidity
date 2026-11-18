// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; ram: 0.27; battery: 0.86; cpu: 0.18; now: new Date(2025, 8, 6, 17, 23, 44)
              tags: [1, 2, 3, 4, 5, 6, 7, 8, 9].map(i => ({ id: i, count: [1, 1, 3, 1, 0, 0, 0, 1, 1][i - 1], state: i === 1 ? "focused" : "occupied" })) }
    // two kitty windows in the grey Minecraft frame
    Repeater {
        model: [[12, 10, 970, 960], [988, 10, 920, 960]]
        Rectangle { required property var modelData; x: modelData[0]; y: modelData[1]; width: modelData[2]; height: modelData[3]
                    color: "#292928"; border.color: "#c6c6c6"; border.width: 4
                    Rectangle { anchors.fill: parent; anchors.margins: 4; color: "transparent"; border.color: "#555555"; border.width: 2 } }
    }
    Text { x: 40; y: 50; color: "#d8c868"; font.family: "Monocraft"; font.pixelSize: 15; lineHeight: 1.35; textFormat: Text.RichText
           text: "<span style='color:#c87a9a'>hooss@code-machine</span>: <span style='color:#7aa8c8'>~/Vidoes/obs</span><br>$ fastfetch<br><br>" +
                 "OS&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Arch Linux x86_64<br>WM&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Hyprland 0.50.1 (Wayland)<br>Memory&nbsp;&nbsp;[ <span style='color:#80c040'>■■■</span>------- ] 4.07 GiB" }
    HotbarView { x: (parent.width - implicitWidth) / 2; y: parent.height - implicitHeight - 4; sys: fake }
    ClockView { x: 0; y: parent.height - implicitHeight; now: fake.now }
}
