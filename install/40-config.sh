# shellcheck shell=bash
source "$ROOT/install/lib.sh"
step "config: starter files (once), app colours that follow the theme"
while IFS= read -r -d '' f; do
  place "$f" "$CONFIG/${f#"$ROOT"/config/}"
done < <(find "$ROOT/config" -type f -print0)
# the theme
[[ -L $CONFIG/fluidity/theme ]] || { mkdir -p "$CONFIG/fluidity"; ln -s "$ROOT/themes/fluid" "$CONFIG/fluidity/theme"; }
# apps without an include read their file straight from the theme
own_link "$CONFIG/fluidity/theme/starship.toml" "$CONFIG/starship.toml"
own_link "$CONFIG/fluidity/theme/fastfetch.jsonc" "$CONFIG/fastfetch/config.jsonc"
[[ -d $CONFIG/vesktop/settings ]] && own_link "$CONFIG/fluidity/theme/vesktop.css" "$CONFIG/vesktop/settings/quickCss.css"
# the default terminal for xdg-terminal-exec
[[ -f $CONFIG/xdg-terminals.list ]] || echo "com.mitchellh.ghostty.desktop" >"$CONFIG/xdg-terminals.list"
FLUIDITY_THEME_LINK=$CONFIG/fluidity/theme FLUIDITY_CONFIG=$CONFIG "$ROOT/bin/fluidity-theme" derived
echo "  theme: $(basename "$(readlink "$CONFIG/fluidity/theme")")"
[[ -d $BACKUP ]] && echo "  replaced files were backed up to $BACKUP"
return 0
