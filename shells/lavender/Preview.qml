// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "JetBrainsMono-Regular.ttf" }
    FontLoader { source: "JetBrainsMono-Bold.ttf" }
    FakeSys { id: fake; track: "Trying to Feel Alive"; artist: "Porter Robinson"; length: 279; position: 56; volume: 0.52; appClass: "floating"
              now: new Date(2025, 3, 21, 18, 37, 0)
              tags: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(i => ({ id: i, count: i < 4 ? 1 : 0, state: i === 2 ? "focused" : i < 4 ? "occupied" : "empty" })) }
    // his fastfetch kitty: translucent purple-grey with the lavender edge
    Rectangle { x: 90; y: 118; width: 690; height: 320; radius: 10; color: "#cc85799e"; border.color: "#c6c1f4"; border.width: 2
                Text { x: 270; y: 50; font.family: "JetBrains Mono"; font.pixelSize: 14; lineHeight: 1.25; color: "#faf2f2"; textFormat: Text.RichText
                       text: "<span style='color:#c6c1f4'>celeste@love</span><br><br>secureblue (Fedora Atomic) x86_64<br>Linux 6.14.2-300.fc42.x86_64<br>2392 (rpm-ostree)<br>wezterm-gui<br>Hyprland (Wayland)<br>51 mins" } }
    BarView { width: parent.width; height: 40; sys: fake }
    PanelView { x: parent.width - implicitWidth - 8; y: 46; width: implicitWidth; height: implicitHeight; sys: fake; showSelection: true }
}
