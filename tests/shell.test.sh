# shellcheck shell=bash
# The real shells (fluidity; mac mode's tahoe-bar and dock) load with no QML errors on a hidden display.
source "$(dirname "$0")/lib.sh"
if ! command -v Xvfb >/dev/null || ! command -v qs >/dev/null || ! command -v dbus-run-session >/dev/null; then ok "skipped: no Xvfb/qs here"; done_testing; fi
for sh in fluidity tahoe-bar dock; do
  log=$(mktemp)
  SHELL_NAME=$sh SMOKE_LOG=$log nice "$ROOT/tools/shell-smoke.sh" 7 >/dev/null 2>&1
  clean=$(sed 's/\x1b\[[0-9;]*m//g' "$log")
  has "$sh loads" "Configuration Loaded" "$clean"
  errs=$(grep -E 'ERROR scene|WARN scene|TypeError|ReferenceError|is not a type|Cannot assign' <<<"$clean" | grep -v 'FileView at' || true)
  eq "$sh: no QML errors" "" "$errs"
  rm -f "$log"
done
done_testing
