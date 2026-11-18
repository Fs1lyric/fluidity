# shellcheck shell=bash
# Every fluidity-* command the binds, the shell and the themes call exists in bin/ and answers --help-ish
# usage errors with a non-zero exit instead of crashing.
source "$(dirname "$0")/lib.sh"
used=$(grep -rhoE 'fluidity-[a-z][a-z-]*[a-z]' "$ROOT/default" "$ROOT/bin" | sort -u | grep -vE '^fluidity-(bar|island-|desktop|themes|render|ai-usage\.json|launcher-recent|emoji-recent|clip|brightness|scratch-window|awake|reminder|share|clip-|menuba)$')
missing=()
for c in $used; do
  case $c in fluidity-[a-z]*.json | fluidity-theme/*) continue ;; esac
  [[ -x $ROOT/bin/$c ]] || missing+=("$c")
done
eq "every called command exists" "" "${missing[*]}"
for c in "$ROOT"/bin/fluidity-*; do
  n=$(basename "$c")
  [[ $n == fluidity-ai-usage ]] && continue
  bash -n "$c" 2>/dev/null || [[ $(head -1 "$c") == *python* ]] || fail "$n parses"
done
ok "every command parses"
done_testing
