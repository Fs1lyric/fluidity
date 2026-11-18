# Fluidity

My own system: Arch + Hyprland, one repo, one install command, one set of `fluidity-*` commands.
Liquid look: every popup grows out of the bar. Keyboard first, 49 themes, mac mode one key away.

- Switch this machine over: `bin/fluidity-switch on` (undo: `fluidity-switch back`)
- Fresh Arch: `boot.sh` (clones, then `install.sh`)
- Update: `fluidity-update` · Check: `fluidity-doctor` · Theme: `fluidity-theme set NAME`
- Plan, decisions, status: `PLAN.md` · Look: `mockups/`
- Tests: `bash tests/run.sh` · Renders: `/usr/bin/python3 -I tools/render.py OUT`
