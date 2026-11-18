-- Runtime toggles written by fluidity-window (gaps, aspect ratio) and per-workspace layouts.
-- They live in ~/.local/state/fluidity and are re-applied on every config reload.
local state = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/fluidity"
for _, dir in ipairs({ "toggles", "workspace-layouts" }) do
  local quoted = "'" .. (state .. "/" .. dir):gsub("'", "'\\''") .. "'"
  local h = io.popen("find " .. quoted .. " -maxdepth 1 -name '*.lua' 2>/dev/null | sort")
  if h then
    for f in h:lines() do dofile(f) end
    h:close()
  end
end
