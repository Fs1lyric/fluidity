# shellcheck shell=bash
# The installer, run against a sandbox HOME with packages and live steps skipped.
source "$(dirname "$0")/lib.sh"
fresh() {
  H=$(mktemp -d); CLEAN+=("$H"); trap 'rm -rf "${CLEAN[@]}"' EXIT
  mkdir -p "$H/.config/hypr" "$H/.config/ghostty"
  echo "my old hypr" >"$H/.config/hypr/hyprland.lua"
  echo "my old ghostty" >"$H/.config/ghostty/config"
}
run() { HOME=$H XDG_CONFIG_HOME=$H/.config XDG_STATE_HOME=$H/.local/state XDG_DATA_HOME=$H/.local/share XDG_CACHE_HOME=$H/.cache \
        FLUIDITY_SKIP_PACKAGES=1 FLUIDITY_NO_LIVE=1 bash "$ROOT/install.sh" "$@" >"$H/out" 2>&1; }

fresh; run; code=$?
eq "install finishes" 0 "$code"
eq "the repo is linked as the Fluidity root" "$ROOT" "$(readlink -f "$H/.local/share/fluidity")"
eq "commands are on PATH" "$ROOT/bin/fluidity-theme" "$(readlink -f "$H/.local/bin/fluidity-theme")"
eq "the shell config is linked" "$ROOT/default/quickshell/fluidity" "$(readlink -f "$H/.config/quickshell/fluidity")"
eq "theme shells are linked" "$ROOT/shells/mechanical-love" "$(readlink -f "$H/.config/quickshell/mechanical-love")"
eq "the default theme is fluid" "fluid" "$(basename "$(readlink "$H/.config/fluidity/theme")")"
has "the starter hyprland.lua is in place" 'require("hypr.init")' "$(cat "$H/.config/hypr/hyprland.lua")"
b=$(ls -d "$H"/.local/state/fluidity/backup/* 2>/dev/null | head -1)
eq "your old hyprland.lua is backed up" "my old hypr" "$(cat "$b/.config/hypr/hyprland.lua" 2>/dev/null)"
eq "your old ghostty config is backed up" "my old ghostty" "$(cat "$b/.config/ghostty/config" 2>/dev/null)"
eq "starship follows the theme" "$H/.config/fluidity/theme/starship.toml" "$(readlink "$H/.config/starship.toml")"
[[ -f $H/.local/share/fonts/fluidity/Geist-Regular.ttf ]] && ok "fonts are installed" || fail "fonts are installed"
has "hyprlock colours are written" '$accent' "$(cat "$H/.cache/fluidity/hyprlock-colors.conf" 2>/dev/null)"

# rerunning keeps your edits: files already from Fluidity are not replaced
echo "-- my edit" >>"$H/.config/hypr/bindings.lua"; run; code=$?
eq "rerun finishes" 0 "$code"
has "rerun keeps your edits" "-- my edit" "$(cat "$H/.config/hypr/bindings.lua")"
eq "rerun makes no new backup of unchanged files" 1 "$(ls -d "$H"/.local/state/fluidity/backup/* | wc -l)"
done_testing
