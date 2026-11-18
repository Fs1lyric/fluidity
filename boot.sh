#!/usr/bin/env bash
# One command on a fresh Arch install:  curl -fsSL <raw url of this file> | bash
set -euo pipefail
repo=${FLUIDITY_REPO:-https://github.com/Fs1lyric/fluidity.git}
dest=${XDG_DATA_HOME:-$HOME/.local/share}/fluidity
sudo pacman -S --needed --noconfirm git base-devel
if ! command -v yay >/dev/null; then
  tmp=$(mktemp -d); git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay"
  (cd "$tmp/yay" && makepkg -si --noconfirm); rm -rf "$tmp"
fi
if [[ -d $dest/.git ]]; then git -C "$dest" pull --ff-only; else git clone "$repo" "$dest"; fi
exec bash "$dest/install.sh"
