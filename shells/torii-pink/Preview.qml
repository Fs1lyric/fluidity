// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "LexendDeca-Regular.ttf" }
    FontLoader { source: "LexendDeca-Medium.ttf" }
    FakeSys { id: fake; track: "Locals (Girls like us) [with gabby start]"; artist: "underscores"; cpu: 0.11; temp: 67; ram: 0.40; diskUsed: 0.70
              appClass: "kitty"; title: "n"; volume: 0.42; btConnected: 1; battery: 0.19; weatherTemp: "20.9"; now: new Date(2026, 1, 20, 11, 24, 0)
              tags: [1, 2, 3, 4, 5, 6].map(i => ({ id: i, count: i < 3 ? 1 : 0, state: i === 1 ? "focused" : i < 3 ? "occupied" : "empty" })) }
    // his two kitty windows down the left, the pink gradient border on the focused one
    Rectangle { x: 60; y: 64; width: 690; height: 390; radius: 12; color: "#e61c1e2a"
                Text { x: 200; y: 40; color: "white"; font.family: "Lexend Deca"; font.pixelSize: 15; lineHeight: 1.5; textFormat: Text.RichText
                       text: "Wassup<br><br><span style='color:#f6a0ca'>OS</span> Arch Linux<br><span style='color:#f6a0ca'>SHELL</span> zsh 5.9<br><span style='color:#f6a0ca'>TERMINAL</span> kitty 0.45.0<br><span style='color:#f6a0ca'>UPTIME</span> 16 hours, 57 mins" } }
    Rectangle { x: 60; y: 490; width: 690; height: 470; radius: 12; color: "#e61c1e2a"; border.color: "#f6a0ca"; border.width: 4
                Text { x: 40; y: 40; color: "white"; font.family: "monospace"; font.pixelSize: 15; lineHeight: 1.5; textFormat: Text.RichText
                       text: "<span style='color:#f6a0ca'>impl</span> Token {<br>&nbsp;&nbsp;&nbsp;&nbsp;<span style='color:#f6a0ca'>pub fn</span> new(token_type: TokenType) -&gt; Self {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Self { token_type, lexeme, row, col }<br>&nbsp;&nbsp;&nbsp;&nbsp;}<br>}" } }
    BarView { width: parent.width; height: 44; sys: fake; expanded: true }
    PanelView { x: (parent.width - implicitWidth) / 2; y: 0; width: implicitWidth; height: implicitHeight; sys: fake; showSelection: true }
}
