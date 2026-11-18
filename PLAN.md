# Fluidity

Your own system, built the way Omarchy is built: one repo, one install command, one set of `fluidity-*`
commands, one update command. Made for you only.

## Decisions (from you, 2026-11-18)

- **Name:** Fluidity.
- **Fresh desktop layer, nothing of yours lost.** New repo, clean code written for it. Your files, apps and
  data stay exactly where they are (see "Never touched").
- **Default look:** the `fluid` theme (charcoal `#111417`, pistachio `#d7e59b`, blush `#f2a7a7`,
  off-white `#e3e4da`). Keyboard mode, square windows, slim top bar, snappy motion.
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
