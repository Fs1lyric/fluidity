# shellcheck shell=bash
# The lock: plain (your wallpaper) or redacted (a frosted, unreadable copy of the screen).
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"
sandbox
printf '#!/usr/bin/env bash\necho "hyprlock $*" >> %q\n' "$LOG" >"$SANDBOX/stubs/hyprlock"; printf '#!/usr/bin/env bash\nexit 1\n' >"$SANDBOX/stubs/pidof"; chmod +x "$SANDBOX/stubs/"*
export XDG_CONFIG_HOME=$SANDBOX/config; mkdir -p "$XDG_CONFIG_HOME/hypr"; cp "$ROOT/config/hypr/hyprlock.conf" "$XDG_CONFIG_HOME/hypr/"
eq "plain by default" off "$(fluidity-lock redact status)"
fluidity-lock; has "plain lock uses your config" "hyprlock" "$(calls)"
name="  without the redacted one"; called "redact" && fail "$name" || ok "$name"
fluidity-lock redact on >/dev/null; eq "redact on" on "$(fluidity-lock redact status)"
: >"$LOG"; fluidity-lock
has "redacted lock uses its own config" "hyprlock -c" "$(calls)"
c=$(sed -n 's/^hyprlock -c //p' "$LOG")
has "  that frosts a screenshot" "path = screenshot" "$(cat "$c" 2>/dev/null)"
has "  and keeps your widgets" "input-field" "$(cat "$c" 2>/dev/null)"
fluidity-lock redact toggle >/dev/null; eq "toggle back" off "$(fluidity-lock redact status)"
done_testing
