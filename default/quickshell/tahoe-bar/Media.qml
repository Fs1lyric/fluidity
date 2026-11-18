pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

// The MPRIS player the media keys and the control center talk to: the one
// playing, else the first one around.
Singleton {
    id: media

    readonly property MprisPlayer player: {
        const all = Mpris.players.values;
        return all.find(p => p.isPlaying) ?? all[0] ?? null;
    }

    IpcHandler {
        target: "media"
        function toggle(): void { if (media.player?.canTogglePlaying) media.player.togglePlaying() }
        function next(): void { if (media.player?.canGoNext) media.player.next() }
        function previous(): void { if (media.player?.canGoPrevious) media.player.previous() }
    }
}
