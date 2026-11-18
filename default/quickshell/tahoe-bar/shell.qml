//@ pragma IconTheme WhiteSur-dark
// Fluidity mac mode: the macOS Tahoe menu bar, its menus, Spotlight and the mac dialogs.
// Notifications, the OSD and the control centre come from the Fluidity shell (qs -c fluidity), which keeps running.
import Quickshell

ShellRoot {
    Variants { model: Quickshell.screens; Bar {} }
    Spotlight {}
    MacDialogs {}
}
