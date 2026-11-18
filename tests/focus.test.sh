# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"
sandbox
for s in systemd-run systemctl; do printf '#!/usr/bin/env bash\necho "%s $*" >> %q\n' "$s" "$LOG" >"$SANDBOX/stubs/$s"; chmod +x "$SANDBOX/stubs/$s"; done
t() { if "$@"; then ok "$name"; else fail "$name" "$(calls | paste -sd';')"; fi; }
fluidity-focus start 25 >/dev/null
end=$(cat "$FLUIDITY_STATE/focus-until" 2>/dev/null); now=$(date +%s)
if (( end >= now + 1490 && end <= now + 1510 )); then ok "start 25 sets the end 25 min out"; else fail "start 25 sets the end 25 min out" "$end vs $now"; fi
name="start turns do not disturb on"; t called "qs -c fluidity ipc call notifications toggleDnd"
name="start schedules the end"; t called "systemd-run --user"
has "status shows the minutes left" "25" "$(fluidity-focus status)"
: >"$LOG"; fluidity-focus stop >/dev/null
[[ -e $FLUIDITY_STATE/focus-until ]] && fail "stop clears the timer" || ok "stop clears the timer"
eq "status when idle" "off" "$(fluidity-focus status)"
status "a silly length fails" 1 fluidity-focus start abc
done_testing
