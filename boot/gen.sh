#!/usr/bin/env bash
# Bake every graphic of the Fluidity boot screen (the initramfs has no fonts): your wallpaper blurred and
# darkened, the italic serif clock glyphs (accent colon), the date glyphs, the glass password pill, the dots.
#   boot/gen.sh [WALLPAPER] [ACCENT] [CYAN]
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); root=$(dirname "$here"); out=$here/plymouth/fluidity
wall=${1:-$(readlink -f "$root/themes/fluid/wallpaper.jpg")}
acc=${2:-#d7e59b}; cyan=${3:-#c2e6d6}; fg='#eef0e4'; dim='#9a9b92'
serif=$root/default/fonts/InstrumentSerif-Italic.ttf; sans=$root/default/fonts/Geist-Regular.ttf
mkdir -p "$out"; rm -f "$out"/*.png
magick "$wall[0]" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x22 -fill '#0a0c0e' -colorize 58% "$out/bg.png"
BIG="0123456789:"
for ((i = 0; i < ${#BIG}; i++)); do
  c=${BIG:i:1}; col=$fg; [[ $c == : ]] && col=$acc
  magick -background none -fill "$col" -font "$serif" -pointsize 230 -gravity center -size 130x260 "label:$c" "$out/big-$i.png"
done
SMALL="0123456789:, ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
for ((i = 0; i < ${#SMALL}; i++)); do
  c=${SMALL:i:1}
  if [[ $c == " " ]]; then magick -size 19x46 xc:none "$out/small-$i.png"; continue; fi
  magick -background none -fill "$fg" -font "$serif" -pointsize 34 -gravity center -size 19x46 "label:$c" "$out/small-$i.png"
done
# the glass pill with an accent -> mint rim, and a lime dot
magick -size 380x64 xc:none -fill "rgba(10,12,14,0.82)" -stroke "$acc" -strokewidth 2 -draw "roundrectangle 2,2 377,61 31,31" "$out/field.png"
magick -size 14x14 xc:none -fill "$acc" -draw "circle 7,7 7,1" "$out/dot.png"
magick -background none -fill "$dim" -font "$sans" -pointsize 18 "label:enter your password to unlock" "$out/layout.png"
# the droplet + wordmark
magick -size 64x80 xc:none -fill "$acc" -draw "path 'M 32,4 C 44,22 58,36 58,52 A 26,26 0 0 1 6,52 C 6,36 20,22 32,4 Z'" "$out/drop.png"
magick -background none -fill "$fg" -font "$serif" -pointsize 44 "label:fluidity" "$out/word.png"
echo "baked $(ls "$out" | wc -l) images into $out"
