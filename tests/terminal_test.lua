-- The terminal, observed through the built Theme and checked against
-- Upstream's own output: the ghostty export Upstream commits for each
-- Variant (upstream/extras/ghostty/onedarkpro_<variant>), read from the
-- submodule. The export is the oracle for the Bright Colours, so they are
-- checked against Upstream's export helper as Upstream ran it, never against
-- a reimplementation. ghostty, kitty and wezterm all take the same colours.
local h = require("helpers")

-- Zed's ANSI Style Keys in the order of ghostty's palette slots 0 to 15.
local SLOTS = {
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

test("the sixteen ANSI colours of OneDarkPro Onedark equal, slot for slot, Upstream's ghostty export for onedark", function()
  local style = h.theme_family().themes[1].style
  local export = ghostty_export("onedark")
  for slot = 0, 15 do
    local key = "terminal.ansi." .. SLOTS[slot + 1]
    assert(export.palette[slot], "the ghostty export has no palette line for slot " .. slot)
    h.eq(style[key], export.palette[slot], key .. " <- palette " .. slot)
  end
end)

-- The normal ANSI colours, slots 0 to 7, each of which has a dim partner.
local NORMAL = { "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white" }

test("every dim ANSI colour and the dim foreground are their normal colour at 60% alpha", function()
  local style = h.theme_family().themes[1].style
  for _, name in ipairs(NORMAL) do
    h.eq(style["terminal.ansi.dim_" .. name], style["terminal.ansi." .. name] .. "99", "terminal.ansi.dim_" .. name)
  end
  h.eq(style["terminal.dim_foreground"], style["terminal.foreground"] .. "99", "terminal.dim_foreground")
end)

test("terminal background, ANSI background and foreground equal the ghostty export's background and foreground; bright foreground is its bright white", function()
  local style = h.theme_family().themes[1].style
  local export = ghostty_export("onedark")
  assert(export.background and export.foreground, "the ghostty export has no background or foreground line")
  h.eq(style["terminal.background"], export.background, "terminal.background <- background")
  h.eq(style["terminal.ansi.background"], export.background, "terminal.ansi.background <- background")
  h.eq(style["terminal.foreground"], export.foreground, "terminal.foreground <- foreground")
  h.eq(style["terminal.bright_foreground"], export.palette[15], "terminal.bright_foreground <- palette 15")
end)
