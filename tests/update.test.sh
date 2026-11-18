# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"
sandbox
H=$SANDBOX/home; mkdir -p "$H"
R=$SANDBOX/repo; mkdir -p "$R/migrations" "$R/bin"
cp "$ROOT/bin/fluidity-update" "$R/bin/"
printf 'echo ran-one >>%q\n' "$SANDBOX/m" >"$R/migrations/20260101-1-one.sh"
printf 'echo ran-two >>%q\n' "$SANDBOX/m" >"$R/migrations/20260102-1-two.sh"
printf '#!/usr/bin/env bash\necho "install $*" >> %q\n' "$LOG" >"$R/install.sh"
for s in git fluidity-mode sudo snapper; do printf '#!/usr/bin/env bash\necho "%s $*" >> %q\n' "$s" "$LOG" >"$SANDBOX/stubs/$s"; chmod +x "$SANDBOX/stubs/$s"; done
up() { HOME=$H XDG_STATE_HOME=$H/state FLUIDITY_PATH=$R "$R/bin/fluidity-update" "$@" >/dev/null 2>&1; }
up
eq "migrations run once each, in order" "ran-one ran-two" "$(paste -sd' ' "$SANDBOX/m")"
if called "install"; then ok "update re-runs the installer (links, new starters)"; else fail "update re-runs the installer"; fi
up
eq "a second update runs nothing again" "ran-one ran-two" "$(paste -sd' ' "$SANDBOX/m")"
mkdir -p "$R/.git"; : >"$LOG"; up
if called "git -C $R pull --ff-only"; then ok "a git checkout is pulled"; else fail "a git checkout is pulled" "$(calls)"; fi
done_testing
