-- The terminal, observed through the built Theme and checked against
-- Upstream's own output: the ghostty export Upstream commits for each
-- Variant (upstream/extras/ghostty/onedarkpro_<variant>), read from the
-- submodule. The export is the oracle for the sixteen ANSI slots, so the
-- Bright Colours in them are checked against Upstream's export helper as
-- Upstream ran it, never against a reimplementation. ghostty, kitty and
-- wezterm all take the same colours. The bright foreground, which the
-- exports do not have, is checked against Upstream's literal for the
-- lightened fg (tests/variants.lua). Every assertion runs against every
-- Theme the Theme Family ships.
local h = require("helpers")

-- Zed's ANSI Style Keys in the order of ghostty's palette slots 0 to 15.
local ANSI_KEYS_BY_SLOT = {
  "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white",
  "bright_black", "bright_red", "bright_green", "bright_yellow",
  "bright_blue", "bright_magenta", "bright_cyan", "bright_white",
}

-- Upstream's ghostty export for a Variant: `palette[0..15]` from its
-- `palette = N=#rrggbb` lines, plus `background` and `foreground`.
local function ghostty_export(variant)
  local text = h.read(h.root .. "/upstream/extras/ghostty/onedarkpro_" .. variant)
  local export = { palette = {} }
  for line in text:gmatch("[^\n]+") do
    local slot, colour = line:match("^palette = (%d+)=(#%x%x%x%x%x%x)$")
    if slot then
      export.palette[tonumber(slot)] = colour
    else
      local key, value = line:match("^([%a-]+) = (#%x%x%x%x%x%x)$")
      if key then
        export[key] = value
      end
    end
  end
  return export
end

-- The normal ANSI colours, slots 0 to 7, each of which has a dim partner.
local NORMAL = { "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white" }

-- The bright foreground is Upstream's `fg` lightened by 10, the Bright Colour
-- its exports meant to compute (their `bright_fg` lightens yellow by mistake,
-- so the export is no oracle for it). In onedark `white` equals `fg`, so it
-- is the export's bright white, palette 15. In onelight `black` equals `fg`,
-- so it is the lightened #6a6a6a, #848484, and not the export's bright white
-- #ffffff, which would be white text on a #fafafa terminal.

for _, t in ipairs(h.THEMES) do
  test(string.format("the sixteen ANSI colours of %s equal, slot for slot, Upstream's ghostty export for %s", t.name, t.variant), function()
    local style = h.theme(t.name).style
    local export = ghostty_export(t.variant)
    for slot = 0, 15 do
      local key = "terminal.ansi." .. ANSI_KEYS_BY_SLOT[slot + 1]
      assert(export.palette[slot], "the ghostty export has no palette line for slot " .. slot)
      h.eq(style[key], export.palette[slot], key .. " <- palette " .. slot)
    end
  end)

  test(string.format("every dim ANSI colour and the dim foreground of %s are their normal colour at 60%% alpha", t.name), function()
    local style = h.theme(t.name).style
    for _, name in ipairs(NORMAL) do
      h.eq(style["terminal.ansi.dim_" .. name], style["terminal.ansi." .. name] .. "99", "terminal.ansi.dim_" .. name)
    end
    h.eq(style["terminal.dim_foreground"], style["terminal.foreground"] .. "99", "terminal.dim_foreground")
  end)

  test(string.format("terminal background, ANSI background and foreground of %s equal the ghostty export's background and foreground", t.name), function()
    local style = h.theme(t.name).style
    local export = ghostty_export(t.variant)
    assert(export.background and export.foreground, "the ghostty export has no background or foreground line")
    h.eq(style["terminal.background"], export.background, "terminal.background <- background")
    h.eq(style["terminal.ansi.background"], export.background, "terminal.ansi.background <- background")
    h.eq(style["terminal.foreground"], export.foreground, "terminal.foreground <- foreground")
  end)

  test(string.format("bright foreground of %s is the lightened fg, %s", t.name, t.literal.bright_fg), function()
    local style = h.theme(t.name).style
    h.eq(style["terminal.bright_foreground"], t.literal.bright_fg, "terminal.bright_foreground <- bright_fg")
  end)
end

test("bright foreground of OneDarkPro Onedark is also the ghostty export's bright white, because onedark's white equals its fg", function()
  local style = h.theme("OneDarkPro Onedark").style
  h.eq(style["terminal.bright_foreground"], ghostty_export("onedark").palette[15], "terminal.bright_foreground <- palette 15")
end)

test("bright foreground of OneDarkPro Onelight is not the ghostty export's bright white, which is white on a white terminal", function()
  local style = h.theme("OneDarkPro Onelight").style
  local bright_white = ghostty_export("onelight").palette[15]
  assert(style["terminal.bright_foreground"] ~= bright_white,
    "terminal.bright_foreground is the export's bright white " .. bright_white)
end)
