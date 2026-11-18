# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
H=$(mktemp -d); trap 'rm -rf "$H"' EXIT
HOME=$H lua "$ROOT/tests/hypr_test.lua" "$ROOT" || fails=$((fails + 1))
# the whole starter config, once per theme (each theme's final file runs last)
mkdir -p "$H/.config/fluidity"; cp -r "$ROOT/config/hypr" "$H/.config/hypr"
bad=()
for t in "$ROOT"/themes/*/; do
  ln -sfn "${t%/}" "$H/.config/fluidity/theme"
  HOME=$H FLUIDITY_PATH=$ROOT lua "$ROOT/tests/hypr_test.lua" "$ROOT" full "$(basename "$t")" >"$H/out" 2>&1 || bad+=("$(basename "$t"): $(grep -A1 FAIL "$H/out" | tail -1)")
done
eq "the starter config loads with every theme (${#bad[@]} broken)" "" "${bad[*]}"
done_testing
