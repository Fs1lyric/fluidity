# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
HOME=$(mktemp -d) lua "$ROOT/tests/hypr_test.lua" "$ROOT"
