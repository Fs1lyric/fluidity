pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// The notification daemon. New ones open the bar's island for a few seconds; all are kept for the
// history view (Super+Alt+comma).
Singleton {
    id: notifs
    property bool dnd: false
    readonly property var history: server.trackedNotifications
    signal arrived(var n)

    function clear() { for (const n of server.trackedNotifications.values.slice()) n.dismiss() }
    function dismissNewest() { const v = server.trackedNotifications.values; if (v.length) v[v.length - 1].dismiss() }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: false
        imageSupported: true
        persistenceSupported: true
        onNotification: n => {
            n.tracked = true;
            if (!notifs.dnd || n.urgency === NotificationUrgency.Critical) notifs.arrived(n);
        }
    }
    IpcHandler {
        target: "notifications"
        function clear(): void { notifs.clear() }
        function dismiss(): void { notifs.dismissNewest() }
        function toggleDnd(): void { notifs.dnd = !notifs.dnd }
        function dndStatus(): string { return notifs.dnd ? "on" : "off" }
    }
}
