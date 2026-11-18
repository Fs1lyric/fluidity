# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"

fresh() {
  sandbox
  rm "$SANDBOX/stubs/fluidity-mode"
  theme fluid keyboard
  theme tahoe mac
  theme mechanical-love keyboard shell=mechanical-love
  ln -s "$FLUIDITY_THEMES/fluid" "$FLUIDITY_THEME_LINK"
}
started() { called "setsid -f qs -c $1"; }
stopped() { called "pkill -f qs -c $1"; }
t() { if "$@"; then ok "$name"; else fail "$name" "$(calls | paste -sd';')"; fi; }

fresh; fluidity-mode start >/dev/null
name="the core shell always starts"; t started fluidity
name="keyboard: the dock is stopped"; t stopped dock
name="keyboard: the Fluidity bar shows"; t called "qs -c fluidity ipc call bar show"
name="keyboard: other theme shells stop"; t stopped mechanical-love

fresh; touch "$SANDBOX/running-fluidity"; fluidity-mode start >/dev/null
name="a running core shell is left alone"; if started fluidity; then fail "$name"; else ok "$name"; fi

fresh; ln -sfn "$FLUIDITY_THEMES/mechanical-love" "$FLUIDITY_THEME_LINK"; fluidity-mode start >/dev/null
name="a theme shell starts its own bar"; t started mechanical-love
name="a theme shell hides the Fluidity bar"; t called "qs -c fluidity ipc call bar hide"

fresh; ln -sfn "$FLUIDITY_THEMES/tahoe" "$FLUIDITY_THEME_LINK"; fluidity-mode start >/dev/null
name="mac: the dock starts"; t started dock
name="mac: the menu bar starts"; t started tahoe-bar
name="mac: the Fluidity bar hides"; t called "qs -c fluidity ipc call bar hide"

fresh; fluidity-mode current >/dev/null
eq "current prints the mode" keyboard "$(fluidity-mode current)"

# toggle goes to mac (tahoe) and remembers the keyboard theme to come back to
fresh; ln -s "$SANDBOX/stubs/hyprctl" "$SANDBOX/stubs/fluidity-theme-stub"
printf '#!/usr/bin/env bash\necho "fluidity-theme $*" >> %q\n' "$LOG" >"$SANDBOX/stubs/fluidity-theme"; chmod +x "$SANDBOX/stubs/fluidity-theme"
fluidity-mode toggle >/dev/null
name="toggle from keyboard goes to tahoe"; t called "fluidity-theme set tahoe"
eq "toggle remembers the keyboard theme" fluid "$(cat "$FLUIDITY_STATE/last-keyboard-theme")"
ln -sfn "$FLUIDITY_THEMES/tahoe" "$FLUIDITY_THEME_LINK"; : >"$LOG"
fluidity-mode toggle >/dev/null
name="toggle back returns to the remembered theme"; t called "fluidity-theme set fluid"

# a theme shell called "fluid" must not be mistaken for the core shell "fluidity" (or the other way round)
fresh; theme fluid keyboard shell=fluid; touch "$SANDBOX/running-fluidity"
fluidity-mode start >/dev/null
name="a running fluidity does not count as a running fluid"; t started fluid
name="stopping a theme shell can't hit fluidity"; if grep -q 'pkill -f qs -c fluid( |$)' "$LOG" || ! grep -q 'pkill -f qs -c fluidity$' "$LOG"; then ok "$name"; else fail "$name" "$(calls | paste -sd';')"; fi

status "unknown command fails" 1 fluidity-mode bogus
done_testing
