# shellcheck shell=bash
source "$(dirname "$0")/lib.sh"
source "$(dirname "$0")/stubs.sh"
sandbox
# pacman knows "ripgrep"; the AUR helper knows the rest; nothing is installed
printf '#!/usr/bin/env bash\necho "pacman $*" >> %q\ncase "$1" in -Si) [[ $2 == ripgrep ]] ;; -Q) exit 1 ;; esac\n' "$LOG" >"$SANDBOX/stubs/pacman"
for s in sudo yay; do printf '#!/usr/bin/env bash\necho "%s $*" >> %q\n' "$s" "$LOG" >"$SANDBOX/stubs/$s"; done
chmod +x "$SANDBOX/stubs/"*
t() { if called "$1"; then ok "$2"; else fail "$2" "$(calls | paste -sd';')"; fi; }

FLUIDITY_TTY=1 fluidity-install ripgrep >/dev/null
t "sudo pacman -S --needed --noconfirm ripgrep" "repo packages go through pacman"
: >"$LOG"; FLUIDITY_TTY=1 fluidity-install wl-kbptr >/dev/null
t "yay -S --needed --noconfirm wl-kbptr" "AUR packages go through the AUR helper"
: >"$LOG"; FLUIDITY_TTY=1 fluidity-install ripgrep wl-kbptr >/dev/null
t "sudo pacman -S --needed --noconfirm ripgrep" "a mixed list splits: repo part"
t "yay -S --needed --noconfirm wl-kbptr" "a mixed list splits: AUR part"
status "no packages is a usage error" 1 fluidity-install
done_testing
