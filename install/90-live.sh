# shellcheck shell=bash
step "session"
if [[ -n ${FLUIDITY_NO_LIVE:-} || -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
  echo "  not in a Hyprland session (or FLUIDITY_NO_LIVE): log in to Hyprland to start Fluidity"
else
  hyprctl reload >/dev/null
  "$ROOT/bin/fluidity-mode" start
  "$ROOT/bin/fluidity-wallpaper" restore >/dev/null 2>&1 || "$ROOT/bin/fluidity-wallpaper" theme "" fluid
  echo "  reloaded Hyprland and started the shell"
fi
