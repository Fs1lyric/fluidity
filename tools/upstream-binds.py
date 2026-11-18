"""Turn upstream Hyprland .conf bindings into a sorted list of normalised chords.

Usage: python3 -I tools/upstream-binds.py SHA FILE.conf... > tests/fixtures/upstream-binds.txt
Each output line is `CHORD<TAB>description`, CHORD normalised the same way tests/keymap_test.lua does it.
"""
import re
import sys

ORDER = ["SUPER", "CTRL", "ALT", "SHIFT"]
ALIASES = {"CONTROL": "CTRL", "WIN": "SUPER", "MOD4": "SUPER"}


def key_name(k):
    k = k.strip().upper()
    m = re.fullmatch(r"CODE:(\d+)", k)
    if m and 10 <= int(m.group(1)) <= 19:
        return str((int(m.group(1)) - 9) % 10)
    if k == "CODE:61":
        return "SLASH"
    return k


def chord(mods, key):
    ms = {ALIASES.get(m, m) for m in re.split(r"[\s+]+", mods.upper()) if m}
    return " + ".join([m for m in ORDER if m in ms] + [key_name(key)])


def main():
    sha, files = sys.argv[1], sys.argv[2:]
    out = {}
    for f in files:
        for line in open(f, encoding="utf-8"):
            m = re.match(r"^\s*bind[a-z]*\s*=\s*([^,]*),([^,]*),\s*([^,]*)", line)
            if not m:
                continue
            c = chord(m.group(1), m.group(2))
            out.setdefault(c, m.group(3).strip())
    print(f"# upstream basecamp/omarchy@{sha}: default/hypr/bindings/*.conf + config/hypr/bindings.conf")
    for c in sorted(out):
        print(f"{c}\t{out[c]}")


main()
