#!/usr/bin/env bash
# Install Fluidity for this user. Safe to run again: files you already got from Fluidity are never
# replaced (they are yours), anything else it replaces is copied to ~/.local/state/fluidity/backup/<time>/.
#   bash install.sh            everything
#   FLUIDITY_SKIP_PACKAGES=1   skip pacman/AUR
#   FLUIDITY_NO_LIVE=1         don't touch a running session (no reload, no shell start)
set -uo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
export ROOT
CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}
STATE=${XDG_STATE_HOME:-$HOME/.local/state}/fluidity
DATA=${XDG_DATA_HOME:-$HOME/.local/share}
BACKUP=${FLUIDITY_BACKUP:-$STATE/backup/$(date +%Y%m%d-%H%M%S)}
MANIFEST=$STATE/installed-files
export CONFIG STATE DATA BACKUP MANIFEST
mkdir -p "$STATE"; touch "$MANIFEST"

step() { printf '\n\033[1;38;2;215;229;155m●\033[0m %s\n' "$1"; }
for s in "$ROOT"/install/[0-9]*.sh; do
  # shellcheck source=/dev/null
  source "$s" || { echo "fluidity: step $(basename "$s") failed" >&2; exit 1; }
done
step "done. Fluidity $(cat "$ROOT/VERSION") is installed."
