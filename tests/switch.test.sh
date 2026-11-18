# shellcheck shell=bash
# fluidity-switch on / back, against a sandbox HOME (never the live one).
source "$(dirname "$0")/lib.sh"
H=$(mktemp -d); trap 'rm -rf "$H"' EXIT
mkdir -p "$H/.config/hypr" "$H/.config/quickshell/dock" "$H/.local/share/old-themes/tahoe"
echo "old hypr" >"$H/.config/hypr/hyprland.lua"
echo "old dock" >"$H/.config/quickshell/dock/shell.qml"
ln -s "$H/.local/share/old-themes/tahoe" "$H/.config/lyric-theme"
run() { HOME=$H XDG_CONFIG_HOME=$H/.config XDG_STATE_HOME=$H/.local/state XDG_DATA_HOME=$H/.local/share XDG_CACHE_HOME=$H/.cache \
        FLUIDITY_SKIP_PACKAGES=1 FLUIDITY_NO_LIVE=1 "$ROOT/bin/fluidity-switch" "$@" >"$H/out" 2>&1; }
run on; eq "switch on finishes" 0 $?
has "Hyprland now loads Fluidity" 'require("hypr.init")' "$(cat "$H/.config/hypr/hyprland.lua")"
eq "the old lyric-theme path follows the Fluidity theme" "$H/.config/fluidity/theme" "$(readlink "$H/.config/lyric-theme")"
eq "the dock is Fluidity's" "$ROOT/default/quickshell/dock" "$(readlink -f "$H/.config/quickshell/dock")"
run back; eq "switch back finishes" 0 $?
eq "your old hyprland.lua is back" "old hypr" "$(cat "$H/.config/hypr/hyprland.lua")"
eq "your old dock is back" "old dock" "$(cat "$H/.config/quickshell/dock/shell.qml" 2>/dev/null)"
eq "lyric-theme points where it did" "$H/.local/share/old-themes/tahoe" "$(readlink "$H/.config/lyric-theme")"
done_testing
