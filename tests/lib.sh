# Tiny assert helpers, sourced by every tests/*.test.sh.
# shellcheck shell=bash
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export PATH="$ROOT/bin:$PATH"
fails=0

ok()   { printf '  ok    %s\n' "$1"; }
fail() { printf '  FAIL  %s\n' "$1"; [[ -n ${2:-} ]] && printf '        %s\n' "$2"; fails=$((fails + 1)); }

# eq NAME EXPECTED ACTUAL
eq() { if [[ $2 == "$3" ]]; then ok "$1"; else fail "$1" "expected [$2] got [$3]"; fi; }
# has NAME NEEDLE HAYSTACK
has() { if [[ $3 == *"$2"* ]]; then ok "$1"; else fail "$1" "missing [$2] in [${3:0:200}]"; fi; }
# status NAME EXPECTED_CODE CMD...
status() { local n=$1 want=$2; shift 2; "$@" >/dev/null 2>&1; local got=$?; eq "$n" "$want" "$got"; }

done_testing() { exit $((fails > 0)); }
