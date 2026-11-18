# shellcheck shell=bash
source "$ROOT/install/lib.sh"
step "preflight"
[[ $EUID -ne 0 ]] || { echo "run as your user, not root" >&2; return 1; }
[[ -f /etc/arch-release || -n ${FLUIDITY_SKIP_PACKAGES:-} ]] || { echo "Fluidity is for Arch Linux" >&2; return 1; }
echo "  root: $ROOT"
