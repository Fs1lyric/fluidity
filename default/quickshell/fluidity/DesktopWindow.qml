import QtQuick
import Quickshell
import Quickshell.Wayland
import "views"

// The desktop under the windows: the big clock and the cards. Never takes input.
PanelWindow {
    id: w
    required property var modelData
    screen: modelData
    visible: Island.barShown
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: -1
    color: "transparent"
    WlrLayershell.namespace: "fluidity-desktop"
    WlrLayershell.layer: WlrLayer.Bottom
    mask: Region {}

    DesktopView {
        anchors.fill: parent
        pal: Theme.pal
        hours: Status.hours; minutes: Status.minutes; weekday: Status.weekday; date: Status.date
        media: {
            const p = Island.player;
            if (!p || !p.trackTitle) return { title: "", artist: "", progress: 0, position: "", length: "", playing: false, art: "" };
            const fmt = s => Math.floor(s / 60) + ":" + String(Math.floor(s % 60)).padStart(2, "0");
            return { title: p.trackTitle, artist: [p.trackArtist, p.trackAlbum].filter(Boolean).join(" · "), progress: p.length > 0 ? p.position / p.length : 0,
                     position: fmt(p.position || 0), length: fmt(p.length || 0), playing: p.isPlaying, art: p.trackArtUrl || "" };
        }
        agenda: Status.agenda
        sys: Status.sys
    }
}
