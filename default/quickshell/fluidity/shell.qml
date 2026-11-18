//@ pragma IconTheme Papirus-Dark
// Fluidity shell: the bar, the island (every popup), notifications, the OSD, the desktop clock and cards,
// and the theme picker. `qs -c fluidity`; keybinds talk to it with `qs -c fluidity ipc call ...` (fluidity-island).
import Quickshell

ShellRoot {
    Variants { model: Quickshell.screens; BarWindow {} }
    Variants { model: Quickshell.screens; DesktopWindow {} }
    Variants { model: Quickshell.screens; DockWindow {} }
    OverlayWindow {}
    ThemePickerWindow {}
}
