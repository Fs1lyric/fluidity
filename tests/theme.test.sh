# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"

fresh() {
  sandbox
  theme fluid keyboard 'colors.toml=accent = "#d7e59b"' TITLE=Fluid TAGLINE='lime on charcoal'
  touch "$FLUIDITY_THEMES/fluid/wallpaper.jpg" "$FLUIDITY_THEMES/fluid/preview.png"
  theme tahoe mac
  ln -s "$FLUIDITY_THEMES/tahoe" "$FLUIDITY_THEME_LINK"
}
real_mode() { # use the real fluidity-mode instead of the stub
  rm "$SANDBOX/stubs/fluidity-mode"
}

fresh
eq "current prints the linked theme" tahoe "$(fluidity-theme current)"
eq "list shows every theme, current marked" "  fluid|* tahoe" "$(fluidity-theme list | paste -sd'|')"
eq "mode prints the current theme's mode" mac "$(fluidity-theme mode)"

fresh
fluidity-theme set fluid >/dev/null
eq "set swaps the link" "$FLUIDITY_THEMES/fluid" "$(readlink "$FLUIDITY_THEME_LINK")"
if called "hyprctl reload"; then ok "set reloads Hyprland"; else fail "set reloads Hyprland"; fi
if called "pkill -USR2 -x ghostty"; then ok "set reloads Ghostty"; else fail "set reloads Ghostty"; fi
if called "qs -c fluidity ipc call theme reload"; then ok "set tells the shell"; else fail "set tells the shell"; fi
if called "fluidity-mode start"; then ok "set starts the right shell pieces"; else fail "set starts the right shell pieces"; fi
if called "fluidity-wallpaper theme tahoe fluid"; then ok "set hands the wallpaper over"; else fail "set hands the wallpaper over" "$(calls)"; fi

fresh
status "unknown theme fails" 1 fluidity-theme set nope
eq "unknown theme leaves the link" "$FLUIDITY_THEMES/tahoe" "$(readlink "$FLUIDITY_THEME_LINK")"
if called hyprctl; then fail "unknown theme reloads nothing"; else ok "unknown theme reloads nothing"; fi

fresh
fluidity-theme next >/dev/null
eq "next wraps around (tahoe -> fluid)" "$FLUIDITY_THEMES/fluid" "$(readlink "$FLUIDITY_THEME_LINK")"

fresh
rm "$FLUIDITY_THEME_LINK"; mkdir "$FLUIDITY_THEME_LINK"
status "refuses to replace a real folder" 1 fluidity-theme set fluid
if [[ -d $FLUIDITY_THEME_LINK && ! -L $FLUIDITY_THEME_LINK ]]; then ok "the real folder is kept"; else fail "the real folder is kept"; fi

fresh
json=$(fluidity-theme json)
eq "json lists themes with mode, colours, title" "fluid keyboard #d7e59b Fluid|tahoe mac  Tahoe" \
  "$(python3 -I -c 'import json,sys; print("|".join(f"{t["name"]} {t["mode"]} {t["colors"].get("accent","")} {t["title"]}" for t in json.loads(sys.argv[1])))' "$json")"
eq "json marks current" "tahoe" "$(python3 -I -c 'import json,sys; print([t["name"] for t in json.loads(sys.argv[1]) if t["current"]][0])' "$json")"

fresh
rows=$(fluidity-theme rows)
eq "rows: one preview link per theme that has a picture" "fluid.png" "$(cut -f1 <<<"$rows" | xargs -n1 basename | paste -sd' ')"

status "unknown command fails" 1 fluidity-theme bogus
done_testing
