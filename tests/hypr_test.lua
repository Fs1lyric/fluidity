-- Loads the whole default/hypr/init.lua against a stub `hl` and checks the Liquid look and the motion rules.
local root = arg[1]
local fails = 0
local function ok(n) print("  ok    " .. n) end
local function fail(n, why) print("  FAIL  " .. n); if why then print("        " .. why) end; fails = fails + 1 end

local config, anims, curves = {}, {}, {}
local function merge(dst, src) for k, v in pairs(src) do if type(v) == "table" and type(dst[k]) == "table" and not v.colors then merge(dst[k], v) else dst[k] = v end end end
local function stub(path)
  return setmetatable({}, { __index = function(_, k) return stub(path .. "." .. k) end, __call = function() return { dsp = path } end })
end
hl = stub("hl")
hl.dsp = stub("dsp")
hl.dsp.exec_cmd = function(cmd) return { cmd = cmd } end
hl.bind = function() end
hl.on = function() end
hl.exec_cmd = function() end
hl.env = function() end
hl.window_rule = function() end
hl.layer_rule = function() end
hl.config = function(t) merge(config, t) end
hl.curve = function(name, c) curves[name] = c end
hl.animation = function(a) anims[a.leaf] = a end

package.path = root .. "/default/?.lua;" .. package.path
FLUIDITY = root
local good, err = pcall(require, "hypr.init")
if good then ok("init.lua loads") else fail("init.lua loads", err) end

local d, g = config.decoration or {}, config.general or {}
if d.rounding == 22 then ok("windows are round (22 px)") else fail("windows are round (22 px)", tostring(d.rounding)) end
local ab = g.col and g.col.active_border
if type(ab) == "table" and ab.colors and #ab.colors >= 3 then ok("focused border is a gradient") else fail("focused border is a gradient") end
if d.blur and d.blur.enabled then ok("glass blur is on") else fail("glass blur is on") end
local ba = anims.borderangle
if ba and ba.style == "loop" then ok("border gradient turns (borderangle loop)") else fail("border gradient turns (borderangle loop)") end
if curves.liquid and curves.liquid.points[1][2] > 1 then ok("liquid curve overshoots") else fail("liquid curve overshoots") end

-- keyboard-first rule: nothing slower than 300 ms, except the looping border
local slow = {}
for leaf, a in pairs(anims) do
  if leaf ~= "borderangle" and a.enabled ~= false and (a.speed or 0) > 3 then slow[#slow + 1] = leaf .. "=" .. a.speed end
end
if #slow == 0 then ok("no animation slower than 300 ms") else fail("no animation slower than 300 ms", table.concat(slow, ", ")) end

os.exit(fails == 0 and 0 or 1)
