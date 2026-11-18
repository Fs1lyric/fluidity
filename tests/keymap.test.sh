# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
lua "$ROOT/tests/keymap_test.lua" "$ROOT"
