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
  sed -i -e '/keyboard\.lua/d' -e '/Productivity layer shared by every keyboard-mode theme/d' \
         -e '/Switch to mac mode", "lyric-theme set tahoe"/d' "$f"
done
cat > "$dst/fluid/hyprland-final.lua" <<'LUA'
-- Fluid is Fluidity's default theme: its feel is default/hypr/liquid.lua, nothing to override here.
LUA
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
