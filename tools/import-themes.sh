#!/usr/bin/env bash
# One-off import of the Luminescent themes into Fluidity (rerunnable): copies every theme folder,
# then strips what Fluidity does itself: the old keyboard.lua layer and the per-theme mac-mode key.
# The `fluid` theme's own final is dropped, so it gets the Liquid feel from default/hypr/liquid.lua.
set -euo pipefail
src=${1:-$HOME/claude/luminescent/themes}
dst=$(cd "$(dirname "$0")/.." && pwd)/themes
rm -rf "$dst"; mkdir -p "$dst"
cp -a "$src"/. "$dst"/
for f in "$dst"/*/hyprland-final.lua; do
  sed -i -e '/keyboard\.lua/d' -e '/io.open(keyboard/d' -e '/Productivity layer shared by every keyboard-mode theme/d' \
         -e '/Switch to mac mode", "lyric-theme set tahoe"/d' "$f"
done
/usr/bin/python3 -I "$(dirname "$0")/free-theme-keys.py" "$dst"
cat > "$dst/fluid/hyprland-final.lua" <<'LUA'
-- Fluid is Fluidity's default theme: its feel is default/hypr/liquid.lua, nothing to override here.
LUA
rm -f "$dst/fluid/shell"   # Fluid IS the Fluidity shell: no theme shell of its own
echo "imported $(ls "$dst" | wc -l) themes into $dst"

# The per-theme Quickshell shells (a theme's `shell` file names one) and their shared widgets.
shells_src=$(dirname "$src")/shells
shells_dst=$(dirname "$dst")/shells
rm -rf "$shells_dst"; cp -a "$shells_src" "$shells_dst"
cp -a "$(dirname "$src")/tools/shell-common" "$shells_dst/.common"
grep -rlI 'lyric' "$shells_dst" | while read -r f; do
  sed -i -e 's#\.config/lyric-theme#.config/fluidity/theme#g' -e 's#lyric-theme#fluidity-theme#g' \
         -e 's#\.local/share/lyric/#.local/share/fluidity/#g' -e 's#lyric-shell#fluidity-shell#g' -e 's#"qs", "-c", "lyric"#"qs", "-c", "fluidity"#g' -e 's#qs -c lyric#qs -c fluidity#g' -e 's#\.cache/lyric/#.cache/fluidity/#g' "$f"
done
echo "imported $(ls "$shells_dst" | wc -l) theme shells into $shells_dst"

# Fluid's default wallpaper is your fern photo (approved 2026-11-18), when it is on this machine.
fern="$HOME/Wallpapers for desktop/gruvbox-5-leaves.jpg"
[[ -e $fern ]] && ln -sfn "$fern" "$dst/fluid/wallpaper.jpg"

# The dotfiles.lol rices keep their shells in ~/.local/share/lyric/rices: bring just the shell folders
# (and pill's surface scripts) in, and point the themes at the copies.
rices=$HOME/.local/share/lyric/rices
if [[ -d $rices ]]; then
  cp -a "$rices/impasto/home/.config/quickshell" "$shells_dst/impasto"
  cp -a "$rices/nothing-os/config/quickshell/glyph" "$shells_dst/glyph"
  cp -a "$rices/pill/configs/quickshell/pill" "$shells_dst/pill"
  cp -a "$rices/pill/configs/quickshell/lock" "$shells_dst/lock"
  cp -a "$rices/pill/configs/hypr/scripts" "$shells_dst/.pill-scripts"
  sed -i 's#/.local/share/lyric/rices/pill/configs/hypr/scripts/#/.local/share/fluidity/shells/.pill-scripts/#g' "$dst/pill/hyprland-final.lua"
  { grep -rlI "lyric/rices" "$shells_dst" || true; } | while read -r f; do
    sed -i -e 's#\.local/share/lyric/rices/pill/configs/hypr/scripts/#.local/share/fluidity/shells/.pill-scripts/#g' \
           -e 's#\.local/share/lyric/rices/pill/configs/quickshell/#.config/quickshell/#g' "$f"
  done
  echo "imported the dotfiles.lol rice shells (impasto, glyph, pill, lock)"
fi
