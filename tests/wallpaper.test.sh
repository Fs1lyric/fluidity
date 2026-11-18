# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"

fresh() {
  sandbox
  rm "$SANDBOX/stubs/fluidity-wallpaper"
  export FLUIDITY_WALLS=$SANDBOX/walls; mkdir -p "$FLUIDITY_WALLS"
  touch "$FLUIDITY_WALLS"/{a.jpg,b.png,c.webp,notes.txt}
  for s in magick awww-daemon; do printf '#!/usr/bin/env bash\necho "%s $*" >> %q\n' "$s" "$LOG" >"$SANDBOX/stubs/$s"; chmod +x "$SANDBOX/stubs/$s"; done
  printf '#!/usr/bin/env bash\necho "pgrep $*" >> %q\n' "$LOG" >"$SANDBOX/stubs/pgrep"   # daemon "running"
  theme fluid keyboard; touch "$FLUIDITY_THEMES/fluid/wallpaper.jpg"
  theme tahoe mac
}
t() { if "$@"; then ok "$name"; else fail "$name" "$(calls | paste -sd';')"; fi; }

fresh; fluidity-wallpaper set "$FLUIDITY_WALLS/a.jpg"
name="set draws it with a grow transition"; t called "awww img $FLUIDITY_WALLS/a.jpg"
eq "set remembers it" "$FLUIDITY_WALLS/a.jpg" "$(cat "$FLUIDITY_STATE/wallpaper")"
eq "set links current-wallpaper" "$FLUIDITY_WALLS/a.jpg" "$(readlink "$FLUIDITY_STATE/current-wallpaper")"
status "set refuses a missing file" 1 fluidity-wallpaper set /nope.jpg

fresh; fluidity-wallpaper set "$FLUIDITY_WALLS/a.jpg"; : >"$LOG"; fluidity-wallpaper restore
name="restore redraws the remembered one"; t called "awww img $FLUIDITY_WALLS/a.jpg"

fresh; eq "list shows only images, sorted" "a.jpg b.png c.webp" "$(fluidity-wallpaper list | xargs -n1 basename | paste -sd' ')"

fresh; fluidity-wallpaper set "$FLUIDITY_WALLS/a.jpg"; fluidity-wallpaper next
eq "next goes to the following image" "$FLUIDITY_WALLS/b.png" "$(cat "$FLUIDITY_STATE/wallpaper")"
fluidity-wallpaper set "$FLUIDITY_WALLS/c.webp"; fluidity-wallpaper next
eq "next wraps" "$FLUIDITY_WALLS/a.jpg" "$(cat "$FLUIDITY_STATE/wallpaper")"

# theme OLD NEW: remember OLD's wallpaper, use NEW's remembered one, else NEW's own
fresh; fluidity-wallpaper set "$FLUIDITY_WALLS/b.png"; fluidity-wallpaper theme tahoe fluid
eq "theme switch remembers the old theme's wallpaper" "$FLUIDITY_WALLS/b.png" "$(cat "$FLUIDITY_STATE/wallpaper-tahoe")"
eq "a theme never used starts on its own wallpaper" "$FLUIDITY_THEMES/fluid/wallpaper.jpg" "$(cat "$FLUIDITY_STATE/wallpaper")"
echo "$FLUIDITY_WALLS/c.webp" >"$FLUIDITY_STATE/wallpaper-fluid"; fluidity-wallpaper theme tahoe fluid
eq "a remembered wallpaper wins" "$FLUIDITY_WALLS/c.webp" "$(cat "$FLUIDITY_STATE/wallpaper")"

status "unknown command fails" 1 fluidity-wallpaper bogus
done_testing
