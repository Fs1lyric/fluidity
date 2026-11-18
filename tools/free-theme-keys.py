"""Move theme binds off Fluidity's keys: each listed chord becomes the next free SUPER + F<n> (and its
unbind line goes, since nothing needs unbinding on a free key). Run by tools/import-themes.sh.
  python3 -I tools/free-theme-keys.py THEMES_DIR
"""
import os
import re
import sys

TAKEN = {  # theme -> chords that clash with the Fluidity keymap (tests/keymap_test.lua checks the result)
    "impasto": ["SUPER + X", "SUPER + TAB", "SUPER + comma", "SUPER + T", "SUPER + U", "SUPER + CTRL + B", "SUPER + CTRL + W"],
    "nothing-os": ["SUPER + I", "SUPER + P", "SUPER + SHIFT + W", "SUPER + SHIFT + S", "SUPER + Period"],
    "pill": ["SUPER + I", "SUPER + C", "SUPER + G"],
}
root = sys.argv[1]
for theme, chords in TAKEN.items():
    path = os.path.join(root, theme, "hyprland-final.lua")
    if not os.path.exists(path):
        continue
    src = open(path).read()
    used = set(re.findall(r'"SUPER \+ F(\d+)"', src))
    n, moved = 1, []
    for chord in chords:
        while str(n) in used:
            n += 1
        new = f"SUPER + F{n}"; used.add(str(n))
        src = re.sub(r'^\s*hl\.unbind\("' + re.escape(chord) + r'"\)\s*\n', "", src, flags=re.M)
        src = src.replace(f'bind("{chord}"', f'bind("{new}"')
        moved.append(f"{chord} -> {new}")
    src += "\n-- Fluidity moved these off its own keys (tools/free-theme-keys.py): " + ", ".join(moved) + "\n"
    open(path, "w").write(src)
    print(f"{theme}: " + ", ".join(moved))
