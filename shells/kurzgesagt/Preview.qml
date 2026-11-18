// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "Montserrat-Light.ttf" }
    FakeSys { id: fake; battery: 0.934; online: false; volume: 0.9 }
    // his see-through mint kitty with neofetch
    Rectangle { x: 1310; y: 230; width: 590; height: 360; color: "#b0d8f0e8"
        Text { x: 300; y: 12; color: "#1c3a5a"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; lineHeight: 1.3; textFormat: Text.RichText
               text: "<b style='color:#0f6860'>quan@quanlaptop</b><br>---------------<br><b>OS:</b> Arch Linux x86_64<br><b>Kernel:</b> 5.8.14-arch1-1<br><b>Shell:</b> bash 5.0.18<br>" +
                     "<b>WM:</b> bspwm<br><b>Compositor:</b> picom<br><b>Status Bar:</b> yuzubar<br><b>Wallpaper:</b> Kurzgesagt<br><b>Text Editor:</b> kakoune<br><b>Terminal:</b> kitty" }
        Text { x: 40; y: 240; text: "ART by KURZGESAGT"; color: "#1c3a5a"; font.family: "Montserrat Light"; font.italic: true; font.pixelSize: 16 } }
    BarView { anchors { bottom: parent.bottom; left: parent.left; right: parent.right } height: 30; sys: fake }
}
