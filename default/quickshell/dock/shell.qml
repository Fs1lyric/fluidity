//@ pragma IconTheme WhiteSur-dark
// macOS-style dock. Run with `qs -c dock`.
// Pins and settings live in state.json next to this file (written by the dock itself).
import Quickshell

ShellRoot {
    Variants {
        model: Quickshell.screens
        Dock {}
    }
}
