-- Loads default/hypr/helpers.lua + bindings/*.lua against a stub `hl` and checks the keymap.
-- Run: lua tests/keymap_test.lua ROOT
local root = arg[1]
local binds, fails = {}, 0

-- a stub that accepts any hl.x.y.z(...) call and returns a printable tag
local function stub(path)
  return setmetatable({}, {
    __index = function(_, k) return stub(path .. "." .. k) end,
    __call = function(_, ...) return { dsp = path, args = { ... } } end,
  })
end
hl = stub("hl")
hl.bind = function(keys, dispatcher, opts)
  binds[#binds + 1] = { keys = keys, dsp = dispatcher, opts = opts or {} }
end
hl.dsp = stub("dsp")
hl.dsp.exec_cmd = function(cmd) return { dsp = "exec", cmd = cmd } end
hl.on = function() end
hl.exec_cmd = function() end

local ORDER = { "SUPER", "CTRL", "ALT", "SHIFT" }
local ALIAS = { CONTROL = "CTRL", WIN = "SUPER", MOD4 = "SUPER" }
local MODS = { SUPER = true, CTRL = true, ALT = true, SHIFT = true, CONTROL = true, WIN = true, MOD4 = true }
local function norm(keys)
  local parts = {}
  -- "SUPER + SHIFT + X" or "SUPER SHIFT X"; a key may itself contain spaces ("switch:on:Lid Switch")
  local rest = keys:upper()
  while true do
    local word, tail = rest:match("^%s*([%w]+)%s*[+%s]%s*(.+)$")
    if word and MODS[word] then parts[#parts + 1] = ALIAS[word] or word; rest = tail else break end
  end
  parts[#parts + 1] = rest:gsub("^%s*%+?%s*", ""):gsub("%s+$", "")
  local key = table.remove(parts)
  local code = key:match("^CODE:(%d+)$")
  if code and tonumber(code) >= 10 and tonumber(code) <= 19 then key = tostring((tonumber(code) - 9) % 10) end
  if key == "CODE:61" then key = "SLASH" end
  local have = {}
  for _, m in ipairs(parts) do have[m] = true end
  local out = {}
  for _, m in ipairs(ORDER) do if have[m] then out[#out + 1] = m end end
  out[#out + 1] = key
  return table.concat(out, " + ")
end

local function ok(name) print("  ok    " .. name) end
local function fail(name, why) print("  FAIL  " .. name); if why then print("        " .. why) end; fails = fails + 1 end

dofile(root .. "/default/hypr/helpers.lua")
local h = io.popen("ls " .. root .. "/default/hypr/bindings/*.lua 2>/dev/null | sort")
local files = 0
for f in h:lines() do dofile(f); files = files + 1 end
h:close()
if files > 0 then ok("loaded " .. files .. " binding files") else fail("binding files exist", "none in default/hypr/bindings") end

-- index by chord, plus a flag signature so press/release/mouse variants of one chord can coexist
-- upstream itself puts two actions on these chords (cycle, then raise); both halves are kept
local DOUBLE = { ["ALT + TAB"] = true, ["ALT + SHIFT + TAB"] = true }
local by, dups = {}, {}
for _, b in ipairs(binds) do
  local c = norm(b.keys)
  local sig = c .. (b.opts.mouse and " [mouse]" or "") .. (b.opts.release and " [release]" or "")
  if by[sig] and not DOUBLE[sig] then dups[#dups + 1] = sig end
  by[sig] = b
  by[c] = by[c] or b
end
if #dups == 0 then ok("no chord is bound twice") else fail("no chord is bound twice", table.concat(dups, ", ")) end

-- every upstream chord exists
local missing = {}
for line in io.lines(root .. "/tests/fixtures/upstream-binds.txt") do
  if not line:match("^#") then
    local c, desc = line:match("^(.-)\t(.*)$")
    if not by[c] then missing[#missing + 1] = c .. " (" .. desc .. ")" end
  end
end
if #missing == 0 then ok("all upstream chords are bound") else fail(#missing .. " upstream chords missing", table.concat(missing, "\n        ")) end

-- the one-chord app keys, each open-or-focus
local apps = { A = "calendio", B = "zen", D = "vesktop", M = "spotify", N = "obsidian", H = "btop",
  E = "burrow", I = "claude", U = "flowday", Z = "code" }
for key, app in pairs(apps) do
  local b = by["SUPER + " .. key]
  local cmd = b and type(b.dsp) == "table" and b.dsp.cmd or ""
  if cmd:match("^fluidity%-launch focus") and cmd:lower():match(app) then ok("SUPER + " .. key .. " opens-or-focuses " .. app)
  else fail("SUPER + " .. key .. " opens-or-focuses " .. app, "got [" .. tostring(cmd) .. "]") end
end

-- Fluidity extras
local extras = { ["SUPER + Q"] = "fluidity%-hints", ["SUPER + SEMICOLON"] = "fluidity%-leader",
  ["SUPER + K"] = "fluidity%-island cheatsheet", ["SUPER + PERIOD"] = "fluidity%-island emoji" }
for c, pat in pairs(extras) do
  local cmd = by[c] and type(by[c].dsp) == "table" and by[c].dsp.cmd or ""
  if cmd:match(pat) then ok(c .. " runs " .. pat:gsub("%%", "")) else fail(c .. " runs " .. pat:gsub("%%", ""), "got [" .. cmd .. "]") end
end

-- no old helper names leak into Fluidity
local leaks = {}
for _, b in ipairs(binds) do
  local cmd = type(b.dsp) == "table" and b.dsp.cmd or ""
  if cmd:match("lyric%-") or cmd:match("omarchy") then leaks[#leaks + 1] = norm(b.keys) .. " -> " .. cmd end
end
if #leaks == 0 then ok("no lyric-/omarchy commands") else fail("no lyric-/omarchy commands", table.concat(leaks, "; ")) end

os.exit(fails == 0 and 0 or 1)
