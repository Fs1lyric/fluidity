// Audio levels from cava (raw ascii output), for the visualizers some rices show. Only runs where it is used.
import QtQuick
import Quickshell.Io

Item {
    id: c
    property int bars: 32
    property bool active: true
    property var levels: Array(bars).fill(0)     // 0..1 per bar
    Process {
        running: c.active
        command: ["bash", "-c", "command -v cava >/dev/null || exit 0; cfg=$(mktemp); printf '[general]\\nbars=%s\\nframerate=30\\n[output]\\nmethod=raw\\nraw_target=/dev/stdout\\ndata_format=ascii\\nascii_max_range=100\\nbar_delimiter=59\\nframe_delimiter=10\\n' "
                  + c.bars + " > \"$cfg\"; exec cava -p \"$cfg\""]
        stdout: SplitParser { onRead: line => { const v = line.split(";").filter(x => x !== "").map(x => +x / 100); if (v.length) c.levels = v } }
    }
}
