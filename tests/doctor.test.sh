# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"
sandbox
H=$SANDBOX/home; mkdir -p "$H/.config"
printf '#!/usr/bin/env bash\n[[ $1 == -Q ]] && [[ $2 != ghostty ]]\n' >"$SANDBOX/stubs/pacman"; chmod +x "$SANDBOX/stubs/pacman"
out=$(HOME=$H XDG_CONFIG_HOME=$H/.config fluidity-doctor 2>&1); code=$?
eq "a broken setup exits non-zero" 1 "$code"
has "it names the missing package" "ghostty" "$out"
has "it names the missing theme link" "theme" "$out"
has "it says how to fix" "fluidity-install" "$out"
done_testing
