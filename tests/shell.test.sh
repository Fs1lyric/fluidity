# shellcheck shell=bash
# The real shell loads with no QML errors on a hidden display (skipped without Xvfb/qs).
source "$(dirname "$0")/lib.sh"
if ! command -v Xvfb >/dev/null || ! command -v qs >/dev/null || ! command -v dbus-run-session >/dev/null; then ok "skipped: no Xvfb/qs here"; done_testing; fi
log=$(mktemp)
SMOKE_LOG=$log nice "$ROOT/tools/shell-smoke.sh" 7 >/dev/null 2>&1
clean=$(sed 's/\x1b\[[0-9;]*m//g' "$log")
has "configuration loads" "Configuration Loaded" "$clean"
errs=$(grep -E 'ERROR scene|WARN scene|TypeError|ReferenceError|is not a type|Cannot assign' <<<"$clean" | grep -v 'FileView at' || true)
eq "no QML errors or warnings" "" "$errs"
rm -f "$log"
done_testing
