-- The current theme: ~/.config/fluidity/theme -> a folder in themes/. Its colours feed the Liquid border,
-- then its own hyprland.lua runs. Its hyprland-final.lua runs last, from ~/.config/hypr/hyprland.lua.
local M = {}
M.dir = os.getenv("HOME") .. "/.config/fluidity/theme/"

-- the few keys we need from colors.toml (key = "#rrggbb")
function M.colors()
  local c = { accent = "#d7e59b", cyan = "#c2e6d6", blue = "#a9b8e8", red = "#f2a7a7", background = "#111417" }
  local f = io.open(M.dir .. "colors.toml", "r")
  if f then
    for line in f:lines() do
      local k, v = line:match('^%s*([%w_]+)%s*=%s*"(#%x%x%x%x%x%x)"')
      if k then c[k] = v end
    end
    f:close()
  end
  return c
end

function M.load_own()
  local path = M.dir .. "hyprland.lua"
  if io.open(path, "r") then dofile(path) end
end

return M
