# shellcheck shell=bash
# A sandbox: temp HOME-ish dirs plus stub desktop commands that only log what they were asked to do.
# pgrep "succeeds" for qs -c NAME only when $SANDBOX/running-NAME exists.
sandbox() {
  SANDBOX=$(mktemp -d)
  SANDBOXES+=("$SANDBOX"); trap 'rm -rf "${SANDBOXES[@]}"' EXIT
  export FLUIDITY_THEMES=$SANDBOX/themes FLUIDITY_THEME_LINK=$SANDBOX/config/fluidity/theme
  export FLUIDITY_STATE=$SANDBOX/state FLUIDITY_CACHE=$SANDBOX/cache
  mkdir -p "$FLUIDITY_THEMES" "$SANDBOX/config/fluidity" "$SANDBOX/stubs"
  LOG=$SANDBOX/calls; : >"$LOG"
  local s
  for s in hyprctl qs pkill setsid notify-send awww fluidity-wallpaper fluidity-mode; do
    printf '#!/usr/bin/env bash\necho "%s $*" >> %q\n' "$s" "$LOG" >"$SANDBOX/stubs/$s"
  done
  printf '#!/usr/bin/env bash\necho "pgrep $*" >> %q\n[[ -e %q/running-${2##* } ]]\n' "$LOG" "$SANDBOX" >"$SANDBOX/stubs/pgrep"
  chmod +x "$SANDBOX/stubs/"*
  export PATH=$SANDBOX/stubs:$PATH
}
# theme NAME MODE [file=content ...]
theme() {
  local d=$FLUIDITY_THEMES/$1; mkdir -p "$d"; echo "$2" >"$d/mode"; shift 2
  local kv; for kv in "$@"; do printf '%s\n' "${kv#*=}" >"$d/${kv%%=*}"; done
}
called() { grep -qF -- "$1" "$LOG"; }
calls() { cat "$LOG"; }
