#!/usr/bin/python3
"""Render the Fluidity shell views off-screen (a hidden Xvfb display, never the live screen) to PNGs.

  /usr/bin/python3 -I tools/render.py OUT_DIR [scenario ...]
  /usr/bin/python3 -I tools/render.py --list

Each scenario places a pure view (views/*.qml, no Quickshell types) over the theme wallpaper with fixed
props, with animations off, and grabs the window. The repo's fonts are used through a private fontconfig.
Exit code 1 if any scenario logs a QML error or produces no image.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VIEWS = os.path.join(REPO, "default/quickshell/fluidity/views")
QML_TOOL = "/usr/lib/qt6/bin/qml"
THEME = os.environ.get("RENDER_THEME", "fluid")


def palette(theme):
    out = subprocess.run([os.path.join(REPO, "bin/fluidity-theme"), "json"], capture_output=True, text=True,
                         env=dict(os.environ, FLUIDITY_THEMES=os.path.join(REPO, "themes"))).stdout
    t = next(x for x in json.loads(out) if x["name"] == theme)
    c = t["colors"]
    pal = dict(accent=c.get("accent"), cyan=c.get("cyan"), blue=c.get("blue"), red=c.get("red"), fg=c.get("foreground"),
               dim=c.get("dark_foreground"), muted=c.get("muted"), bg=c.get("background"), yellow=c.get("yellow"),
               magenta=c.get("magenta"), orange=c.get("orange", c.get("yellow")))
    return pal, t["wallpaper"]


PAL, WALL = palette(THEME)
SC = {}


def scenario(name, view, props, size=(1920, 1080), place="island"):
    SC[name] = dict(view=view, props=dict(props, pal=PAL, animate=False), size=size, place=place)


K = lambda *k: list(k)
APPS = [dict(icon="", title="Calendio", desc="your day · math at 18:00", keys=K("❖", "A")),
        dict(icon="", title="Calculator", desc="or type = in here"),
        dict(icon="", title="Claude", desc="ask anything", keys=K("❖", "I")),
        dict(icon="", title="Cursorify", desc="cursor designer"),
        dict(icon="", title="Burrow", desc="files", keys=K("❖", "E"))]
HINT = ["↵ open", "↑↓ move", "tab actions", "esc close"]
scenario("idle", "IslandView", dict(view="idle", song="Kokoro · Tycho", playing=True, clock="Wed 18 · 09:41"))
scenario("idle-focus", "IslandView", dict(view="idle", song="Kokoro · Tycho", playing=True, clock="Wed 18 · 09:41", extra="focus 24:12"))
scenario("idle-next", "IslandView", dict(view="idle", clock="Wed 18 · 17:48", extra="math · linear algebra in 12m"))
scenario("launcher", "IslandView", dict(view="launcher", query="ca", items=APPS, index=0, calc=dict(expr="12 * 48 + 7", result="583"), keyHint=HINT))
EMO = [dict(e=e, name=n) for e, n in zip("😭🔥💀🙏✨👀♟🎨📚😤🥹😂🫠💅🤌🫡😮🤝💯🌙🍵🎧🧠⚡🌊🍃🫧💚🩷🤍",
       ["loudly crying face", "fire", "skull", "folded hands", "sparkles", "eyes", "chess pawn", "artist palette", "books", "huffing"] + ["x"] * 20)]
scenario("emoji", "IslandView", dict(view="emoji", placeholder="search emoji", items=EMO, index=0, cats=["recent", "smileys", "people", "nature", "food", "objects"], cat=0))
CLIP = [dict(icon="", title="fn open_or_focus(app…", meta="2m"), dict(icon="󰋩", title="screenshot 1920×1080", meta="9m"),
        dict(icon="", title="github.com/Fs1lyric/fluidity", meta="14m"), dict(icon="", title="Ch. 12, the ink pooled…", meta="1h")]
scenario("clipboard", "IslandView", dict(view="clipboard", placeholder="search clipboard", items=CLIP, index=0,
         preview=dict(kind="text", info="text · 5 lines · from ghostty", text="# open the app, or focus it\nfn open_or_focus(app: &str) {\n    if focus(app) { return }\n    spawn(\"uwsm-app\", app)\n}")))
G = lambda name, *b: dict(name=name, binds=[dict(desc=d, keys=k, on=o) for d, k, o in b])
scenario("cheatsheet", "IslandView", dict(view="cheatsheet", query="sh", groups=[
    G("apps", ("Calendio", K("❖", "A"), False), ("Zen", K("❖", "B"), False), ("Spotify", K("❖", "M"), False), ("Obsidian", K("❖", "N"), False), ("Terminal", K("❖", "↵"), False)),
    G("windows", ("Close", K("❖", "W"), False), ("Float / tile", K("❖", "T"), False), ("Fullscreen", K("❖", "F"), False), ("Toggle split", K("❖", "J"), False), ("Group", K("❖", "G"), False)),
    G("capture", ("Screenshot", K("❖", ";", "S"), True), ("Record", K("❖", ";", "R"), False), ("OCR copy", K("❖", ";", "O"), False), ("Colour pick", K("❖", ";", "P"), False)),
    G("system", ("Launcher", K("❖", "Space"), False), ("Emoji", K("❖", "."), False), ("Clipboard", K("❖", "^", "V"), False), ("Click hints", K("❖", "Q"), False), ("Power", K("❖", "Esc"), False))]))
LEAD = [dict(k=k, label=l) for k, l in [("s", "shot"), ("r", "record"), ("o", "ocr"), ("p", "colour"), ("c", "clipboard"), ("e", "emoji"), ("n", "night"),
        ("d", "dnd"), ("i", "idle"), ("g", "gaps"), ("t", "theme"), ("m", "mode"), ("w", "wall"), ("l", "lock"), ("x", "power")]]
scenario("leader", "IslandView", dict(view="leader", items=LEAD))
POWER = [dict(icon="", label="lock"), dict(icon="󰤄", label="sleep"), dict(icon="󰍃", label="log out"),
         dict(icon="󰜉", label="restart", danger=True), dict(icon="󰐥", label="shut down", danger=True)]
scenario("power", "IslandView", dict(view="power", items=POWER, index=0))
scenario("power-danger", "IslandView", dict(view="power", items=POWER, index=4))
walls = sorted(os.path.join(REPO, "themes/fluid/backgrounds", f) for f in os.listdir(os.path.join(REPO, "themes/fluid/backgrounds")))
scenario("wallpaper", "IslandView", dict(view="wallpaper", title="gruvbox leaves", body="3840×2160 · 3 of 7", index=2,
         items=[dict(src="file://" + w) for w in [walls[0], walls[1], os.path.realpath(WALL), walls[2], walls[3]]]))
scenario("switcher", "IslandView", dict(view="switcher", index=1, items=[dict(icon="", title="Ghostty"), dict(icon="", title="Calendio"),
         dict(icon="", title="Zen"), dict(icon="", title="Obsidian")]))
scenario("notify", "IslandView", dict(view="notify", icon="", title="Math in 10 minutes", body="Linear algebra · chapter 4 · Calendio", keyHint=K("❖", "A")))
scenario("osd", "IslandView", dict(view="osd", icon="󰕾", value=0.64))
scenario("hints", "IslandView", dict(view="hints", title="typed d · 4 matches · esc cancel"))
scenario("control", "IslandView", dict(view="control", index=0, song="Kokoro · Tycho", playing=True,
         items=[dict(icon="󰤨", label="Wi-Fi", on=True, state="home"), dict(icon="󰂯", label="Bluetooth", on=False), dict(icon="󰂛", label="Focus", on=False),
                dict(icon="󰖔", label="Night light", on=True), dict(icon="󰅶", label="Stay awake", on=False), dict(icon="󰕾", label="Output", on=False, state="speakers")],
         groups=[dict(icon="󰕾", value=0.64), dict(icon="󰃠", value=0.8)]))
scenario("notifications", "IslandView", dict(view="notifications", index=0, items=[dict(icon="", title="Math in 10 minutes", desc="Calendio", meta="now"),
         dict(icon="", title="2 new messages", desc="Vesktop", meta="3m")]))
scenario("bar", "BarView", dict(workspaces=[dict(id=1, active=True, occupied=True), dict(id=2, occupied=True), dict(id=3, occupied=True), dict(id=4), dict(id=5)],
         wifi="", volume=64, battery=88, ai=68), place="fill")
scenario("desktop", "DesktopView", dict(media=dict(title="Kokoro", artist="Tycho · Weather", progress=0.42, position="1:42", length="4:03", playing=True),
         agenda=[dict(time="09:00", title="Art · gesture drawing", sub="45 min", color=PAL["magenta"], done=True),
                 dict(time="10:00", title="Code · Fluidity shell", sub="now · 1h 20m left", color=PAL["accent"], now=True),
                 dict(time="13:00", title="Chess · two rapid games", sub="lichess", color=PAL["cyan"]),
                 dict(time="15:00", title="Reading", sub="one chapter", color=PAL["red"]),
                 dict(time="18:00", title="Math · linear algebra", sub="chapter 4", color=PAL["yellow"])],
         sys=dict(cpu=23, ram=61, temp=47, disk=38)), place="fill")

PLACES = {"island": "anchors.horizontalCenter: parent.horizontalCenter; y: 14", "fill": "anchors.fill: parent"}
MAIN = """import QtQuick
import QtQuick.Window
Window {{
    id: win
    width: {w}; height: {h}; visible: true; color: "black"
    Image {{ anchors.fill: parent; source: "wall.jpg"; fillMode: Image.PreserveAspectCrop }}
    {extra}
    {view} {{
        id: v
        {place}
        Component.onCompleted: {{ const p = {props}; for (const k in p) v[k] = p[k]; }}
    }}
    Timer {{ interval: 900; running: true; onTriggered: win.contentItem.grabToImage(r => {{ r.saveToFile("{out}"); Qt.quit(); }}) }}
}}
"""
# the island sits on the bar in every island scenario, like on the real screen
BAR_UNDER = 'BarView { anchors.fill: parent; pal: %s; animate: false; workspaces: [{id:1,active:true,occupied:true},{id:2,occupied:true},{id:3}]; wifi: ""; volume: 64; battery: 88; ai: 68 }'


def fontconfig(tmp):
    conf = os.path.join(tmp, "fonts.conf")
    with open(conf, "w") as f:
        f.write(f"""<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig>
<include ignore_missing="yes">/etc/fonts/fonts.conf</include><dir>{REPO}/default/fonts</dir>
<cachedir>{tmp}/fc-cache</cachedir></fontconfig>""")
    return conf


def main():
    if sys.argv[1:2] == ["--list"]:
        print("\n".join(SC)); return 0
    out = os.path.abspath(sys.argv[1]); names = sys.argv[2:] or list(SC)
    os.makedirs(out, exist_ok=True)
    tmp = tempfile.mkdtemp(prefix="fluidity-render-")
    conf = fontconfig(tmp)
    disp = ":%d" % (90 + os.getpid() % 50)
    xvfb = subprocess.Popen(["Xvfb", disp, "-screen", "0", "1920x1080x24", "-nolisten", "tcp"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(0.8)
    bad = 0
    try:
        for name in names:
            sc = SC[name]
            work = os.path.join(tmp, name); os.makedirs(work)
            for f in os.listdir(VIEWS):
                shutil.copy(os.path.join(VIEWS, f), work)
            subprocess.run(["magick", WALL + "[0]", "-resize", "1920x1080^", "-gravity", "center", "-extent", "1920x1080", os.path.join(work, "wall.jpg")], check=True)
            png = os.path.join(out, name + ".png")
            if os.path.exists(png): os.remove(png)
            extra = BAR_UNDER % json.dumps(PAL) if sc["place"] == "island" else ""
            with open(os.path.join(work, "main.qml"), "w") as f:
                f.write(MAIN.format(w=sc["size"][0], h=sc["size"][1], view=sc["view"], place=PLACES[sc["place"]], extra=extra,
                                    props=json.dumps(sc["props"], ensure_ascii=False), out=png))
            env = dict(os.environ, QT_QPA_PLATFORM="xcb", DISPLAY=disp, FONTCONFIG_FILE=conf, QT_FORCE_STDERR_LOGGING="1")
            env.pop("WAYLAND_DISPLAY", None)
            r = subprocess.run([QML_TOOL, os.path.join(work, "main.qml")], cwd=work, capture_output=True, text=True, env=env, timeout=40)
            errs = [l for l in r.stderr.splitlines() if (".qml:" in l and "Warning" not in l) or "rror" in l]
            if errs or not os.path.exists(png):
                bad += 1
                print(f"FAIL {name}: " + (" | ".join(errs[:4]) or "no image"))
            else:
                print(f"ok   {name}")
    finally:
        xvfb.terminate()
        shutil.rmtree(tmp, ignore_errors=True)
    return 1 if bad else 0


sys.exit(main())
