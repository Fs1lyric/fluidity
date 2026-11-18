# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"
fresh() {
  sandbox; rm "$SANDBOX/stubs/fluidity-mode"
  theme fluid keyboard; theme mechanical-love keyboard shell=mechanical-love; theme tahoe mac
  ln -s "$FLUIDITY_THEMES/fluid" "$FLUIDITY_THEME_LINK"
}
t() { if "$@"; then ok "$name"; else fail "$name" "$(calls | paste -sd';')"; fi; }

fresh; fluidity-widgets off >/dev/null
name="off hides the bar and the desktop"; t called "qs -c fluidity ipc call bar conceal"
eq "off is remembered" off "$(fluidity-widgets status)"
: >"$LOG"; fluidity-mode start >/dev/null
name="with widgets off, starting the mode keeps them hidden"; t called "qs -c fluidity ipc call bar conceal"
name="  and doesn't show the bar"; if called "bar reveal"; then fail "$name"; else ok "$name"; fi

fresh; ln -sfn "$FLUIDITY_THEMES/mechanical-love" "$FLUIDITY_THEME_LINK"; touch "$SANDBOX/running-mechanical-love"
fluidity-widgets off >/dev/null
name="off stops a theme's own bar"; t called "pkill -f qs -c mechanical-love( |$)"
fresh; ln -sfn "$FLUIDITY_THEMES/tahoe" "$FLUIDITY_THEME_LINK"; fluidity-widgets off >/dev/null
name="off stops the mac dock"; t called "pkill -f qs -c dock( |$)"
name="  and the mac menu bar"; t called "pkill -f qs -c tahoe-bar( |$)"
name="  and doesn't start them"; if called "setsid -f qs -c dock"; then fail "$name"; else ok "$name"; fi

fresh; fluidity-widgets off >/dev/null; : >"$LOG"; fluidity-widgets toggle >/dev/null
eq "toggle turns them back on" on "$(fluidity-widgets status)"
name="on shows the bar again"; t called "qs -c fluidity ipc call bar reveal"
status "unknown command fails" 1 fluidity-widgets bogus
done_testing
