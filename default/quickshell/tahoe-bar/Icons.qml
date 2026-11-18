pragma Singleton
import Quickshell

// App icons by window class / app id, resolved the same way as the dock.
Singleton {
    readonly property var overrides: ({ "vesktop": "discord", "calendi": "calendar" })

    function forApp(appId) {
        if (!appId) return Quickshell.iconPath("application-x-executable");
        const entry = DesktopEntries.byId(appId) ?? DesktopEntries.heuristicLookup(appId);
        const name = entry?.icon || appId;
        const icon = overrides[name] ?? name;
        if (icon.startsWith("/")) return "file://" + icon;
        return Quickshell.iconPath(icon, "application-x-executable");
    }
}
