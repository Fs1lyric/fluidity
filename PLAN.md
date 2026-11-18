# Fluidity

Your own system, built the way Omarchy is built: one repo, one install command, one set of `fluidity-*`
commands, one update command. Made for you only.

## Decisions (from you, 2026-11-18)

- **Name:** Fluidity.
- **Fresh desktop layer, nothing of yours lost.** New repo, clean code written for it. Your files, apps and
  data stay exactly where they are (see "Never touched").
- **Default look:** the `fluid` theme (charcoal `#111417`, pistachio `#d7e59b`, blush `#f2a7a7`,
  off-white `#e3e4da`) on your fern wallpaper (`gruvbox-5-leaves.jpg`). Keyboard mode, **Liquid** look:
  see "Look: Liquid" below and `mockups/showcase.html` + `mockups/popups.html` (approved 2026-11-18).
- **All 49 themes come along**, each with its own shell, wallpaper and theme picker slice.
- **Mac mode stays** as a mode you switch to with one key (Tahoe dock, menu bar, Settings app).
- **Keybinds:** the upstream Omarchy binds exactly, dwindle layout by default. Fill the ~20 that are still
  missing. Theme and mode binds never override an upstream key.
- **Keyboard only:** every panel, widget and picker can be driven from the keyboard.
- **No lyric menu.** You nuked it on 2026-11-13; it stays gone. Launcher stays omenu.

## Keymap: one chord per app (decided 2026-11-18)

Super only (no Hyper/CapsLock daemon), apps only (navigation stays on the Omarchy binds).
Checked against upstream `basecamp/omarchy` master `default/hypr/bindings/*.conf` + `config/hypr/bindings.conf`.
Upstream uses plain Super on C F G J K L O P S T V W X (+ Return, Space, Tab, Esc, Backspace, comma, digits).
Free plain-Super letters: **A B D E H I M N Q R U Y Z**. The fastest tier (one modifier) goes there.
Every app key is **open-or-focus** (never a second copy, never on a hidden workspace).

| Key | App | Note |
|---|---|---|
| Super+A | Calendio | agenda, your daily app (kept) |
| Super+B | Zen | browser, workspace 2 (kept) |
| Super+D | Vesktop | chat (kept) |
| Super+M | Spotify | music (kept) |
| Super+N | Obsidian | notes (kept) |
| Super+H | btop | system monitor (kept) |
| Super+E | Burrow | files ("explore") |
| Super+I | Claude | AI ("intelligence") |
| Super+U | Flowday | tasks ("up next") |
| Super+Z | VS Code Insiders | code (Zed isn't installed) |
| Super+R, Super+Y | free | yours to fill |
| Super+Q | click hints | a letter on every clickable spot, type it to click (wl-kbptr, new package) |
| Super+; | leader | next letter does a rare action; a small hint strip shows the letters |
| Super+K | cheat sheet | upstream already shows keybinds here; rebuilt as a searchable, keyboard-only overlay |

Upstream's Super+Shift app slots stay where they are and point at your apps where the job matches
(Shift+B Zen, Shift+F Burrow, Shift+M Spotify, Shift+O Obsidian, Shift+C Calendio, Shift+N nvim).

**Leader (Super+; then one letter).** The hint strip is one line at the bottom of the screen. It isn't a menu,
it can't be navigated, and it disappears on the next key or Esc.
s screenshot · r record · o OCR copy · p colour picker · c clipboard history · e emoji ·
n night light · d do not disturb · i idle inhibit · g gaps · t next theme · m mac/keyboard mode ·
w next wallpaper · l lock · x power.
(Super+; is emoji today, which is a duplicate of Super+Period; emoji stays on Period.)

Test: `tests/keymap.test.sh` fails on any duplicate chord, any upstream chord that's missing or rebound,
and any app key that isn't open-or-focus.

## The little things: every popup redesigned (added 2026-11-18)

You use these dozens of times a day, so they matter as much as the bar. Today they're a mix: fuzzel text lists
(emoji, clipboard, Super+K keybinds), the `qs -c lyric` launcher, and separate Quickshell panels (power,
wallpaper). In Fluidity they're all **one Quickshell component, `Picker`**, with one design language in the
current theme's colours (Fluid by default), drawn as **the island** (see "Look: Liquid"): the accent only on
the selected row, snappy 150 ms open, Esc closes, everything works from the keyboard, it opens on the
visible workspace, and the first result is already selected.

| Surface | Key | Today | Fluidity |
|---|---|---|---|
| Launcher | Super+Space | qs launcher | app icons, fuzzy match, recent first, inline calculator (`=2*8`) and web search (`?query`) |
| Emoji | Super+Period | fuzzel list | grid with big glyphs, category tabs on Tab, recent row, skin tone on Shift+Enter |
| Clipboard | Super+Ctrl+V | fuzzel list | list + preview pane, images shown as thumbnails, Delete removes, pin favourites |
| Cheat sheet | Super+K | fuzzel list | grouped (apps, windows, workspaces, capture, leader), drawn key caps, type to filter |
| Leader strip | Super+; | new | one-line strip of key caps at the bottom of the screen |
| Click hints | Super+Q | new | glowing accent pills; non-matching ones fade as you type |
| Power | Super+Esc | qs panel | 5 bubbles, the selected one widens and shows its name, one letter each |
| Wallpaper | Super+Ctrl+Space | qs panel | thumbnail strip, live preview, arrows + Enter |
| Theme picker | Super+Ctrl+Shift+Space | slices view | kept (you liked it), restyled to match |
| Window switcher | Alt+Tab | current | live thumbnails of the windows |
| Notifications, OSD | n/a | qs lyric | same card style; the volume/brightness OSD is a thin bar |

Process: **mock up first.** `mockups/popups.html` shows every surface in Fluid, plus one other theme to prove it
re-themes, rendered off-screen to PNG for checking. You open it yourself (`xdg-open`), pick or adjust,
then it gets built. It's built in phase 3 with the shell. Tests cover keyboard paths (every surface opens,
filters, selects, closes with keys only) under Xvfb.

## Look: Liquid (approved 2026-11-18)

The first mockup (square boxes, monospace, thin borders) looked like Omarchy, and you rejected it. Fluidity has
its own look:

- **The island.** The bar is three floating pills. The centre one shows the song + waveform and the time, and
  *every* popup (launcher, emoji, clipboard, cheat sheet, leader, power, wallpaper, Alt+Tab, notifications,
  volume OSD) is that pill growing into the popup with a spring (slight overshoot, ~0.45 s), then shrinking back.
- **Selection** is a lime to mint gradient pill that slides between rows; never a jump.
- **Round, glassy:** windows have 22 px corners, dark glass and blur; the focused window gets a slowly rotating
  lime/mint/blue/pink gradient border.
- **Type:** Geist (UI), Instrument Serif italic (big clock, names, numbers), JetBrains Mono Nerd Font (terminal,
  key caps). Fonts ship as static instances (Qt renders variable Google fonts Thin).
- **Desktop:** a huge italic serif clock with a glowing accent colon, plus music, Calendio-today and system-ring
  cards; soft accent light drifts over the wallpaper, with a fine film grain on top.
- Everything follows the current theme's colours, so all 49 themes get the island too.

## Never touched

Fluidity only owns the desktop config. It never moves, edits or deletes:
`~/claude`, `~/Wallpapers`, `~/Info maxxer`, `~/claude/second-brain`, `~/.local/share/calendio`, browser
profiles (Zen, Helium), Spotify/spicetify, your apps (Calendio, Flowday, Jotter, Burrow, ...), git repos.

Any `~/.config` file the installer replaces is first copied to `~/.local/state/fluidity/backup/<date>/`.
Old Luminescent, Tahoe and `lyric-*` stay on disk until Fluidity is running and you say to remove them.

## How it works (the Omarchy shape)

```
fluidity/
  boot.sh              curl | bash entry: clone to ~/.local/share/fluidity, run install/
  install/             idempotent steps: preflight, packages, config, login, apps, first-run
    packages.txt       curated from today's 259 explicit packages
  bin/fluidity-*       every command (theme, mode, summon, capture, toggle, update, doctor, ...)
  default/             read-only defaults, owned by the repo, replaced on update
    hypr/              binds, input, look and feel, motion, autostart (Lua)
    quickshell/        the one Fluidity shell (bar, notifications, OSD, control center, picker)
    apps/              ghostty, starship, btop, fastfetch, nvim, ...
  config/              starter user files, copied to ~/.config ONCE, then yours to edit
  themes/<name>/       49 themes (fluid is the default)
  modes/keyboard|mac   what each mode starts, stops and binds
  migrations/          dated scripts that fluidity-update runs once each
  tests/
  .github/workflows/   CI: shellcheck, tests, off-screen renders, installer run in an Arch container
```

The rule that makes updates safe: **the repo owns `default/`, you own `~/.config`.** `~/.config/hypr/*.lua`
loads the defaults first and your overrides after, so `fluidity-update` (git pull + migrations) never
overwrites your changes.

## Build order (one phase per session, small commits, tests first)

0. **Skeleton.** Repo, this plan, CI workflow, `bin/` and `tests/` harness, Fs1lyric identity.
1. **Hyprland defaults + keymap.** The keymap section above, Binds rewritten from upstream with a test that diffs them against the upstream
   list (fails while any of the ~20 are missing), input, look and feel, snappy "snap" motion
   (every speed <= 2), autostart, monitors. Dwindle default, Super+L flips a workspace to scrolling.
2. **Theme engine.** `fluidity-theme list|current|set|next`, a clean rewrite of lyric-theme. Move the 49
   themes and gen-themes.py / match-walls.py in, port their tests, make `fluid` the default.
   Wallpapers stay links to your own images (4K rule kept).
3. **The Fluidity shell** (`qs -c fluidity`). One shell with modules: bar, notifications, OSD, control
   center, slices theme picker (Super+Ctrl+Shift+Space), AI usage. Per-theme shells plug in as overrides.
   Rendered off-screen in CI, screenshots uploaded as artifacts.
4. **Modes.** `fluidity-mode keyboard|mac` on one key. Mac mode brings the Tahoe dock, menu bar and
   Settings app into the repo (rebuilt, not linked from archy-cleanup), springy motion kept for mac only.
5. **Productivity commands.** summon overlays (Spotify, Vesktop, Calendio, Obsidian, btop on visible
   workspaces), capture (screenshot, OCR, recording, colour picker), toggles, clipboard history, web
   apps, a keyboard-driven keybind cheat sheet, the Toolkit features.
6. **Apps layer.** Ghostty, starship (`~ ❯`), btop, fastfetch, nvim, browser defaults, all themed from the
   current theme. Calendio first-class on Super+A.
7. **Installer.** `boot.sh` + `install/` steps, every step safe to rerun. Login chain branded Fluidity
   (Plymouth LUKS screen, Limine, SDDM autologin). CI runs the full install in an `archlinux` container.
8. **Update, migrations, doctor.** `fluidity-update` (pull, migrations, reload), `fluidity-doctor`
   (checks packages, links, services, reports what is broken), snapper snapshot before each update.
9. **Switch over on this machine.** Install Fluidity beside the old setup, switch to it, you use it for a
   while, then retire Luminescent and `lyric-*` only when you say so.

## Checks

- Tests written first for every command and run in GitHub Actions (cloud testing rule). If Actions is
  billing-blocked: local, headless only (Xvfb, off-screen renders), never a window on the live screen.
- Nothing is launched on your screen without asking. The real switch-over in phase 9 happens with you.
- Every phase ends with tests, shellcheck and renders green, and the result reported as it is.

## Open questions (answer whenever, they don't block phase 0-2)

- GitHub repo: private `Fs1lyric/fluidity` (default) or public like Omarchy?
- Boot and login screens: Fluidity branding (name + logo), or keep your current lyric Plymouth clock?
- A Fluidity logo: want one designed, or text only?

## Status 2026-11-18 (end of the build session)

Built, test-first, all in this repo (`bash tests/run.sh`: 18 test files, all green, on this PC headless):
- **Phase 0** skeleton, `fluidity` dispatcher, test harness, CI workflow (never ran: no GitHub repo yet).
- **Phase 1** keymap: all 190 upstream chords, one-chord apps, leader, hints, cheat sheet; Liquid look
  (22 px round glass, turning gradient border, spring motion <= 300 ms); starter `~/.config/hypr` layering.
- **Phase 2** 49 themes + 38 theme shells imported (`tools/import-themes.sh`, rerunnable), theme binds moved
  off Fluidity keys (`tools/free-theme-keys.py`), `fluidity-theme`, `fluidity-mode`, `fluidity-wallpaper`.
- **Phase 3** the Fluidity shell (`default/quickshell/fluidity`): bar pills, island with 14 views, desktop clock
  + cards (Calendio today, read-only), notifications, OSD, slices theme picker. Pure views render off-screen
  (`tools/render.py`); the real shell loads and opens views over IPC on a hidden display (`tools/shell-shot.sh`).
- **Phase 4** mac mode in the repo: `tahoe-bar` + `dock` shells; their panels open the island.
- **Phase 5** every `fluidity-*` command the binds/shell call (28 commands).
- **Phase 6** app starters (ghostty, kitty, alacritty), Liquid hyprlock, hypridle, theme-derived colour files.
- **Phase 7** `install.sh` (backs up what it replaces, never touches files you edited), `boot.sh`, packages.
- **Phase 8** `fluidity-update` (pull, migrations once, re-install), `fluidity-doctor`.
- **Phase 9 (ready, not run)** `fluidity-switch on` moves this PC over (backups first), `fluidity-switch back` undoes it.

Not verified / not done:
- Never run on the live desktop (on purpose: the user was away). Real Wayland behaviour is unchecked:
  layer-shell keyboard focus and input masks, blur on the island layers, the `hyprctl eval` calls in
  fluidity-display / fluidity-hw, wl-kbptr's config keys. Typed keys in the island weren't driven (no xdotool).
- The Lua config is checked against a stub `hl`, not real Hyprland 0.56.
- Not pushed: creating the GitHub repo was blocked by the permission system, so CI never ran and
  `boot.sh`'s clone URL (Fs1lyric/fluidity) doesn't exist yet. shellcheck isn't installed here.
- Login chain branding (Plymouth/Limine/SDDM) not done; your lyric Plymouth clock stays.
- Calendio recurring events (rrule) don't show on the desktop card; Alt+Tab keeps upstream's cycle
  (the island switcher is on leader `a`, glyph cards, no live thumbnails).

## Next session
1. With the user at the screen: `~/claude/fluidity/bin/fluidity-switch on`, check every key and view,
   fix what real Hyprland/Wayland shows; `fluidity-switch back` if anything is badly off.
2. Push to a private GitHub repo (needs the user's OK for `gh repo create`), let CI run.
3. Login chain branding, live Alt+Tab thumbnails (ScreencopyView), Calendio recurring events.

## Status 2026-11-18 evening: Fluidity is LIVE on this PC
- `fluidity-switch on` ran (backups in ~/.local/state/fluidity/backup/switch-20261118-164248). `fluidity-doctor`
  is green except wl-kbptr. Your autostart extras (hyprlock at boot, Proton VPN, cursor, toolkit daemon) were
  carried into ~/.config/hypr/autostart.lua; monitors.lua and input.lua were kept.
- Live fixes: `qs -c fluid` matched `qs -c fluidity` (bar was hidden), Hyprland 0.57 wants Lua dispatch
  strings, layer blur rules (Fluidity + mac mode), the island's glow ring looked muddy (off).
- Checked on the real screen: bar, idle island with song, desktop clock + Calendio cards, launcher (real apps,
  icons, key hints), power, Liquid window borders. Not yet driven by hand: typing in the island, leader keys,
  emoji paste, clipboard, cheat sheet, wallpaper picker, mac mode switch.
- Needs your password (sudo): `fluidity-install wl-kbptr` (click hints), `fluidity-boot install` (the Fluidity
  boot screen replacing the lyric clock; preview in boot/plymouth/fluidity).
- Cheat sheet can't replay a bind (Hyprland's Lua binds report function refs); Enter just closes it.

## Next: the Fluid showcase apps in the Fluidity bar (asked 2026-11-18)
User: "the video had so many showcased custom apps i want those too and easily accessible in my top bar",
"that motherfucker has so many apps just look at the video". Source = his repo's folders (the video shows these):
ilyamiro/nixos-configuration src/quickshell (`gh api repos/ilyamiro/nixos-configuration/git/trees/HEAD?recursive=1`).
Rebuild in Fluidity's own shell (default/quickshell/fluidity, the live `qs -c fluidity`), our look, keyboard-first.
Each app: an island view, a key, a button in the bar app row. Render test first (tools/render.py scenario +
tests/render.test.sh, Xvfb off-screen; never a window on the live screen). One commit per app.

Already in Fluidity: launcher, emoji, clipboard, wallpaper, screenshot, notifications, power, control,
focus timer, volume OSD, switcher, cheat sheet, layouts, desktop clock + Calendio cards.
Step 1 DONE: bar app row (BarView apps/appIndex/appClicked, BarWindow apps list), buttons for the views that exist.

Build approach (2026-11-18, second pass): each app is a pure view `views/<Name>App.qml` on `AppBase.qml`
(pal, d = the app's data, sel = selected index); IslandView loads it by view name (`appFiles`) and holds its size;
the shell side is one singleton `Apps.qml` (data, polling while open, keys), Island.qml delegates to it.
Keys: bar app row, leader `;` `u` = apps row (a letter per app). render.py fails on an unknown island view.

His apps still to build, in this order:
2. calendar: month grid + today's Calendio blocks + sun arc; clock click opens it.
3. media: music player (art, title, seek, prev/play/next, cava strip; lyrics via lrclib.net later).
4. network: Wi-Fi list + connect (nmcli). 5. bluetooth: devices + connect (bluetoothctl).
6. syspanel: CPU/RAM/temp/disk/battery + brightness/volume sliders. 7. quickactions: grid of toggles
   (night light, DND, caffeine, VPN, mic, airplane) + power.
8. guide: an in-shell settings/help app (pages: bar, display, notifications, screenshot, theme, wallpaper, wellbeing).
9. wellbeing: screen time per app today (from hyprland focus log), break reminders.
10. bar faces in the right pill: weather (wttr.in), sysmon, visualizer, tray, keyboard layout, bluetooth, battery.
11. desktop widgets (DesktopView, fluidity-widgets toggles each): clock, weather, github contribution graph,
    music, visualizer, usage, timer, notes (~/.local/share/fluidity/notes.md), battery, image, text, user card.
12. notifications extras: battery low/charged + weather alerts as island notifications.
13. polkit agent (password prompt in the island), lock redactor (hyprlock blurs/redacts), idle screen.
14. dock: Fluid-theme only, bottom, keyboard reachable (user said include it).
