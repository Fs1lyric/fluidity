// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; track: "Marine Bloomin' — Moon feat. Adachi Rei"; artist: "beat_shob" }
    // a see-through Konsole window with its grey dots, like the post
    Rectangle { x: 150; y: 180; width: 1090; height: 700; radius: 16; color: Qt.rgba(0.45, 0.65, 0.9, 0.35); border.color: Qt.rgba(1, 1, 1, 0.3)
        Text { anchors.horizontalCenter: parent.horizontalCenter; y: 8; text: "~ : bash — Konsole"; color: "#ffffff"; font.family: "Inter"; font.pixelSize: 13 }
        Row { anchors { right: parent.right; rightMargin: 14 } y: 10; spacing: 8; Repeater { model: 3; Rectangle { width: 13; height: 13; radius: 7; color: "#6b6b6b" } } }
        Rectangle { x: 14; y: 10; width: 13; height: 13; radius: 7; color: "#6b6b6b" }
        Text { x: 22; y: 44; text: "[lyric@archy ~]$ ▯"; color: "#ffffff"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15 } }
    TopView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 64; sys: fake
              levels: Array(24).fill(0).map((_, i) => 0.2 + Math.abs(Math.sin(i * 0.9)) * 0.8) }
    DockView { anchors { left: parent.left; right: parent.right; bottom: parent.bottom; leftMargin: 86; rightMargin: 86; bottomMargin: 8 } height: 52
               sys: fake; iconDir: "file:///home/lyric/.local/share/icons/WhiteSur/apps/scalable/"
               apps: ["zen-browser", "discord", "org.gnome.Nautilus", "com.mitchellh.ghostty", "utilities-system-monitor", "preferences-system",
                      "visual-studio-code", "applets-screenshooter"].map(i => ({ icon: i, cmd: [] })) }
    DeskMenuView { x: 1300; y: 560; width: 300; height: implicitHeight; scale: 1.0 }
}
