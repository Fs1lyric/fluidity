-- Define terminal tag so themes and bindings can single terminals out.
-- fluidity-launch opens TUIs under fluidity.<name> app-ids (fluidity.btop, TUI.float, ...),
-- so match those too.
-- The class is matched in full, so foot's other app-id needs spelling out.
o.window(
  "(Alacritty|kitty|com.mitchellh.ghostty|foot|org\\.codeberg\\.dnkl\\.foot|wezterm|fluidity\\..*|TUI\\..*)",
  { tag = "+terminal" }
)

-- Terminals draw their own see-through background (kitty background_opacity),
-- so the window itself stays at full opacity and text stays solid.
o.window({ tag = "terminal" }, { tag = "-default-opacity" })
