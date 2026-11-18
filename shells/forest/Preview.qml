// The theme picker's preview of this shell (render/render.py --previews draws it over the theme's wallpaper).
import QtQuick

Item {
    anchors.fill: parent
    FontLoader { source: "JetBrainsMono-Regular.ttf" }
    FontLoader { source: "JetBrainsMono-Light.ttf" }
    FakeSys { id: fake; battery: 0.12; cpu: 0.18; ram: 0.31; volume: 0.74; now: new Date(2021, 11, 27, 11, 34, 0)
              wifiOn: true; btOn: false; appClass: "kitty"
              tags: [1, 2, 3, 4, 5, 6, 7, 8, 9].map(i => ({ id: i, count: i < 3 ? 1 : 0, state: i === 1 ? "focused" : i < 3 ? "occupied" : "empty" })) }
    // his two windows: nvim with the centred title and the zsh/pfetch one
    Repeater {
        model: [[90, 80, 1000, 600, "lua/utils.lua - nvim"], [695, 545, 430, 270, "zsh"]]
        Rectangle { required property var modelData; x: modelData[0]; y: modelData[1]; width: modelData[2]; height: modelData[3]
                    radius: 8; color: "#1d2021"
                    Text { anchors.horizontalCenter: parent.horizontalCenter; y: 14; text: modelData[4]; font.family: "JetBrains Mono"; font.pixelSize: 13; color: "#d4be98" }
                    Text { x: 22; y: 12; text: "✕"; font.pixelSize: 13; color: "#928374" } }
    }
    Text { x: 115; y: 140; font.family: "JetBrains Mono"; font.pixelSize: 14; lineHeight: 1.45; textFormat: Text.RichText; color: "#d4be98"
           text: "<span style='color:#ea6962'><i>local</i></span> map = <span style='color:#ea6962'><i>function</i></span>(mode, key, cmd, opts, defaults)<br>" +
                 "&nbsp;&nbsp;opts = vim.tbl_deep_extend(<span style='color:#a9b665'>\"force\"</span>, { silent = <span style='color:#d3869b'>true</span> }, opts)<br>" +
                 "&nbsp;&nbsp;<span style='color:#ea6962'><i>if</i></span> type(cmd) == <span style='color:#a9b665'>\"function\"</span> <span style='color:#ea6962'><i>then</i></span><br>" +
                 "&nbsp;&nbsp;&nbsp;&nbsp;<span style='color:#ea6962'><i>local</i></span> fn_id = utils.create(cmd)<br>&nbsp;&nbsp;<span style='color:#ea6962'><i>end</i></span>" }
    Text { x: 720; y: 600; font.family: "JetBrains Mono"; font.pixelSize: 13; lineHeight: 1.4; textFormat: Text.RichText; color: "#d4be98"
           text: "<span style='color:#89b482'>&gt;</span> pfetch<br><span style='color:#d3869b'>advait</span>@ocean<br>os&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;NixOS 22.05<br>kernel&nbsp;5.10.78<br>memory&nbsp;962M / 7815M" }
    BarView { width: parent.width; height: 52; y: parent.height - 52; sys: fake; panelOpen: true }
    PanelView { x: parent.width - implicitWidth - 10; y: parent.height - implicitHeight - 50; width: implicitWidth; height: implicitHeight
                sys: fake; brightness: 0.25; showSelection: true }
}
