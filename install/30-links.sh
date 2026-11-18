# shellcheck shell=bash
source "$ROOT/install/lib.sh"
step "links: commands, shell, theme shells, fonts"
[[ $(readlink -f "$DATA/fluidity" 2>/dev/null) == "$ROOT" ]] || own_link "$ROOT" "$DATA/fluidity"
mkdir -p "$HOME/.local/bin"
for b in "$ROOT"/bin/fluidity*; do own_link "$b" "$HOME/.local/bin/$(basename "$b")"; done
for d in "$ROOT"/default/quickshell/*/; do own_link "${d%/}" "$CONFIG/quickshell/$(basename "$d")"; done   # fluidity, tahoe-bar, dock
for d in "$ROOT"/shells/*/; do
  n=$(basename "$d"); l=$CONFIG/quickshell/$n
  # a theme shell another setup still links (the old Luminescent) is left alone until you switch over
  if [[ -L $l && $(readlink -f "$l") != "$(readlink -f "$d")" && -z ${FLUIDITY_TAKEOVER:-} ]]; then continue; fi
  own_link "${d%/}" "$l"
done
mkdir -p "$DATA/fonts/fluidity"
cp -u "$ROOT"/default/fonts/*.ttf "$DATA/fonts/fluidity/"
command -v fc-cache >/dev/null && fc-cache -f "$DATA/fonts/fluidity" >/dev/null 2>&1
echo "  $(ls "$ROOT"/bin/fluidity* | wc -l) commands, $(ls -d "$ROOT"/shells/*/ | wc -l) theme shells"
