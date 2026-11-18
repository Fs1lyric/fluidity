# shellcheck shell=bash
# Every shell view draws off-screen without a QML error (skipped where Xvfb or Qt's qml tool is missing).
source "$(dirname "$0")/lib.sh"
if ! command -v Xvfb >/dev/null || [[ ! -x /usr/lib/qt6/bin/qml ]]; then ok "skipped: no Xvfb/qml here"; done_testing; fi
out=$(mktemp -d)
log=$(nice /usr/bin/python3 -I "$ROOT/tools/render.py" "$out" 2>&1); code=$?
n=$(grep -c '^ok' <<<"$log")
eq "every view renders ($n ok)" 0 "$code"
[[ $code == 0 ]] || printf '%s\n' "$log" | grep FAIL
rm -rf "$out"
done_testing
