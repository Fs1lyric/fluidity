// The theme picker's preview of this shell: a transition caught halfway (outline drawn, the world growing out of it).
import QtQuick

Item {
    anchors.fill: parent
    FakeSys { id: fake; title: "kitty"; track: "Marigold"; artist: "Pinegrove" }
    TransitionView { anchors.fill: parent; incoming: "wall.jpg"; edges: "preview-edges.png"; grow: "preview-grow.png"; mode: "character"
                     running: true; progress: 1.35; current: ""; line: "#f2efe6" }
    BarView { anchors { top: parent.top; left: parent.left; right: parent.right } height: 30; sys: fake
              pal: ["#14161b", "#e8e9ee", "#9fb2d6", "#c9a86a"] }
}
