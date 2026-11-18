# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"

out=$(fluidity version 2>&1)
has "version prints the name" "Fluidity" "$out"

out=$(fluidity help 2>&1)
has "help lists the version command" "version" "$out"

status "no command shows help and exits 0" 0 fluidity
status "unknown command exits 2" 2 fluidity no-such-thing
out=$(fluidity no-such-thing 2>&1)
has "unknown command says so" "unknown command" "$out"

# subcommands are separate scripts: fluidity foo runs bin/fluidity-foo
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
printf '#!/usr/bin/env bash\necho "sub ran with $*"\n' >"$tmp/fluidity-demo"; chmod +x "$tmp/fluidity-demo"
out=$(PATH="$tmp:$PATH" fluidity demo a b)
eq "dispatches to fluidity-<cmd> with its args" "sub ran with a b" "$out"

done_testing
