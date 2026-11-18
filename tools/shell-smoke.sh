#!/usr/bin/env bash
# Start the real Fluidity shell for a few seconds on a hidden Xvfb display, with a private D-Bus and no
# Hyprland, and print any QML errors. Never touches the live desktop. Layer-shell lines are stripped
# (Xvfb has no layer shell); everything else runs as written.
set -uo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
cleanup() { kill ${xvfb:-} ${qsp:-} 2>/dev/null; for m in $(awk -v t="$tmp" 'index($2, t) == 1 {print $2}' /proc/mounts); do fusermount3 -u "$m" 2>/dev/null; done; rm -rf "$tmp"; }
trap cleanup EXIT
cp -r "$root/default/quickshell/${SHELL_NAME:-fluidity}" "$tmp/fluidity"
sed -i -E '/WlrLayershell\./d; /^\s*mask: Region/d' "$tmp"/fluidity/*.qml
disp=":$((60 + RANDOM % 30))"
Xvfb "$disp" -screen 0 1920x1080x24 -nolisten tcp >/dev/null 2>&1 & xvfb=$!
sleep 0.8
env -u WAYLAND_DISPLAY -u HYPRLAND_INSTANCE_SIGNATURE GIO_USE_VFS=local GTK_USE_PORTAL=0 QT_QPA_PLATFORMTHEME= QT_QPA_PLATFORM=xcb DISPLAY="$disp" FLUIDITY_PATH="$root" \
  HOME="$tmp/home" XDG_STATE_HOME="$tmp/state" XDG_RUNTIME_DIR="$tmp" \
  timeout "${1:-6}" dbus-run-session -- qs -p "$tmp/fluidity" >"$tmp/log" 2>&1
cp "$tmp/log" "${SMOKE_LOG:-/dev/null}"; grep -E "ERROR|error|Error|\.qml:[0-9]+" "$tmp/log" | grep -v "Hyprland\|HYPRLAND\|hyprland\|xdg-desktop-portal\|pipewire\|atspi\|host portal" | head -30
echo "--- $(wc -l <"$tmp/log") log lines"
