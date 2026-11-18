#!/usr/bin/env bash
# Run the real shell on a hidden Xvfb display (private D-Bus, no Hyprland), open island views over IPC,
# optionally type keys, and screenshot each step:  tools/shell-shot.sh OUT_DIR "launcher|" "launcher|cal" ...
# Each step is VIEW|KEYS (KEYS typed with xdotool). Never touches the live desktop.
set -uo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
out=$(realpath "$1"); shift; mkdir -p "$out"
tmp=$(mktemp -d)
cleanup() { kill ${xvfb:-} ${qsp:-} 2>/dev/null; for m in $(awk -v t="$tmp" 'index($2, t) == 1 {print $2}' /proc/mounts); do fusermount3 -u "$m" 2>/dev/null; done; rm -rf "$tmp"; }
trap cleanup EXIT
cp -r "$root/default/quickshell/fluidity" "$tmp/fluidity"
sed -i -E '/WlrLayershell\./d; /^\s*mask: Region/d' "$tmp"/fluidity/*.qml
mkdir -p "$tmp/home/.config/fluidity" "$tmp/state/fluidity" "$tmp/fonts"
ln -s "$root/themes/${THEME:-fluid}" "$tmp/home/.config/fluidity/theme"
cat >"$tmp/fonts.conf" <<CONF
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig>
<include ignore_missing="yes">/etc/fonts/fonts.conf</include><dir>$root/default/fonts</dir><cachedir>$tmp/fc</cachedir></fontconfig>
CONF
disp=":$((60 + RANDOM % 30))"
Xvfb "$disp" -screen 0 1920x1080x24 -nolisten tcp >/dev/null 2>&1 & xvfb=$!
sleep 0.8
DISPLAY=$disp setsid -f sh -c "magick '$root/themes/${THEME:-fluid}/wallpaper.jpg[0]' -resize 1920x1080^ -extent 1920x1080 '$tmp/wall.png' && display -window root '$tmp/wall.png'" >/dev/null 2>&1
run() { FLUIDITY_NO_POLKIT=1 env -u WAYLAND_DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE GIO_USE_VFS=local GTK_USE_PORTAL=0 QT_QPA_PLATFORMTHEME= QT_QPA_PLATFORM=xcb DISPLAY="$disp" FLUIDITY_PATH="$root" \
  PATH="$root/bin:$PATH" HOME="$tmp/home" XDG_STATE_HOME="$tmp/state" XDG_RUNTIME_DIR="$tmp" FONTCONFIG_FILE="$tmp/fonts.conf" "$@"; }
run dbus-run-session -- sh -c "qs -p '$tmp/fluidity' >'$tmp/log' 2>&1 & sleep $((4 + ${#@} * 3)); echo done" & qsp=$!
sleep 3.5
i=0
for step in "$@"; do
  view=${step%%|*}; keys=${step#*|}
  if [[ $view != idle ]]; then run qs -p "$tmp/fluidity" ipc call island open "$view" "" >/dev/null 2>&1; fi
  sleep 0.9
  [[ -n $keys ]] && DISPLAY=$disp xdotool type --delay 60 "$keys" && sleep 0.5
  DISPLAY=$disp import -window root "$out/$(printf %02d $i)-$view.png"
  run qs -p "$tmp/fluidity" ipc call island close >/dev/null 2>&1; sleep 0.5
  i=$((i + 1))
done
sed 's/\x1b\[[0-9;]*m//g' "$tmp/log" | grep -E 'ERROR|WARN scene|TypeError|ReferenceError|\.qml:' | grep -v 'FileView\|pipewire' | head -20
