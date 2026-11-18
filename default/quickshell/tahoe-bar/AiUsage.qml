pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Claude + Codex plan usage from fluidity-ai-usage, polled every minute while the robot
// is in the menu bar (Bar.qml sets `wanted`). The script never refreshes the logins; tests in
// ~/claude/archy-cleanup/ai-usage. Fields of `data`:
//   claude / codex  { session, sessionResets, week, weekResets, stale } (percent, unix seconds)
//   worst           highest percent across providers (null = no data)
//   level           "ok" < 60 <= "warn" < 85 <= "crit"
Singleton {
    id: ai

    property bool wanted: false
    property var data: null
    property real fetchedAt: 0
    readonly property var worst: data?.worst ?? null
    readonly property string level: data?.level ?? "warn"

    // Re-read now unless a read is running or one finished in the last 30 s.
    function refresh(force) {
        if (fetch.running) return;
        if (!force && Date.now() - fetchedAt < 30000) return;
        fetch.running = true;
    }

    Process {
        id: fetch
        command: ["sh", "-c", "exec fluidity-ai-usage 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    ai.data = JSON.parse(text);
                    ai.fetchedAt = Date.now();
                } catch (e) {}
            }
        }
    }
    Timer {
        interval: 60000; running: ai.wanted; repeat: true; triggeredOnStart: true
        onTriggered: ai.refresh(true)
    }
}
