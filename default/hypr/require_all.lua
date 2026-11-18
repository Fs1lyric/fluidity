-- Require every *.lua file in a folder of the Fluidity defaults, in sorted order.
--   files("bindings", "hypr.bindings")
local M = {}

function M.files(dir, module_prefix)
  local base = FLUIDITY .. "/default/hypr/"
  local quoted = "'" .. (base .. dir):gsub("'", "'\\''") .. "'"
  local handle = io.popen("find " .. quoted .. " -maxdepth 1 -name '*.lua' -printf '%f\\n' 2>/dev/null | sort")
  if not handle then return end
  for filename in handle:lines() do
    require(module_prefix .. "." .. filename:gsub("%.lua$", ""))
  end
  handle:close()
end

return M
