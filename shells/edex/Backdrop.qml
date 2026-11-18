// Black eDEX background and the TERMINAL / MAIN SHELL frame, under the windows (layer Bottom).
import QtQuick
import Quickshell
import Quickshell.Wayland
import "Pal.js" as P

PanelWindow {
    id: w
    property bool bottomShown: true
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: P.black
    WlrLayershell.namespace: "qs-edex-backdrop"
    WlrLayershell.layer: WlrLayer.Bottom
    FrameView {
        x: 668; y: 4
        width: w.width - 668 - 8
        height: w.height - (w.bottomShown ? 335 : 0) - 12
    }
}
