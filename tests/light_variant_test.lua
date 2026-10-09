-- The light Variant: the Chrome Rules name Derived Colours, and Upstream
-- computes those per Variant, so the same rule, unchanged, puts OneDarkPro
-- Onelight's current line, floating surfaces and statusline a shade darker
-- than its #fafafa editor. Where onedark lightens (its cursorline sits above
-- bg) onelight darkens, so the current line is the inversion the rules must
-- survive; float_bg and bg_statusline are darkened in both of these two
-- Variants (not in every Variant: onedark_dark's float_bg equals its bg).
-- Observed through the built Theme.
local h = require("helpers")

-- A luminance weighting of a #rrggbb colour, enough to order two greys.
local function luminance(hex)
  local r, g, b = hex:match("^#(%x%x)(%x%x)(%x%x)")
  assert(r, "not a #rrggbb colour: " .. tostring(hex))
  return 0.2126 * tonumber(r, 16) + 0.7152 * tonumber(g, 16) + 0.0722 * tonumber(b, 16)
end

-- The surfaces ticket #6 names, as the Derived Colour and the Style Key
-- that shows it.
local SURFACES = {
  { "cursorline", "editor.active_line.background" },
  { "float_bg", "elevated_surface.background" },
  { "bg_statusline", "status_bar.background" },
}

test("OneDarkPro Onelight has appearance light, and its cursorline, float_bg and bg_statusline surfaces are darker than its bg", function()
  local theme = h.theme("OneDarkPro Onelight")
  h.eq(theme.appearance, "light", "appearance")
  local bg = theme.style["editor.background"]
  for _, surface in ipairs(SURFACES) do
    local colour, key = surface[1], surface[2]
    local value = theme.style[key]
    assert(luminance(value) < luminance(bg),
      string.format("%s (%s) = %s is not darker than editor.background = %s", key, colour, value, bg))
  end
end)

test("OneDarkPro Onedark has appearance dark, and its cursorline surface is lighter than its bg: the one surface that inverts", function()
  local theme = h.theme("OneDarkPro Onedark")
  h.eq(theme.appearance, "dark", "appearance")
  local bg = theme.style["editor.background"]
  local value = theme.style["editor.active_line.background"]
  assert(luminance(value) > luminance(bg),
    string.format("editor.active_line.background (cursorline) = %s is not lighter than editor.background = %s", value, bg))
end)
