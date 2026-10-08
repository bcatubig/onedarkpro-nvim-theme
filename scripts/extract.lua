-- Stage one: extract.
--
-- Runs Upstream (olimorris/onedarkpro.nvim, the git submodule under upstream/)
-- inside this headless nvim and asks it for a Variant's Palette: the base
-- colours and every Derived Colour, exactly as nvim computes them, and the
-- Bright Colours, exactly as Upstream's terminal exports compute them. No
-- colour maths is reimplemented here; see ADR-0002. The result is written to
-- palettes/<variant>.json.
--
--   nvim --clean -l scripts/extract.lua [variant ...]     (default: onedark)

local root = vim.fs.dirname(vim.fs.dirname(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")))
package.path = root .. "/scripts/?.lua;" .. package.path

local json = require("lib.json")
local util = require("lib.util")

vim.opt.rtp:prepend(root .. "/upstream")

-- Extract with cursorline on, as the user's nvim runs Upstream. At this
-- Upstream commit the option changes no Palette colour; it is set so that
-- extraction keeps tracking the user's configuration if that ever changes.
require("onedarkpro.config").setup({ options = { cursorline = true } })

-- Upstream's fourteen base colours, in the order its palette files list them.
local BASE_ORDER = {
  "bg", "fg", "red", "orange", "yellow", "green", "cyan",
  "blue", "purple", "white", "black", "gray", "highlight", "comment",
}

local function is_colour(value)
  return type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil
end

-- Colours from `colours` as an ordered object: `first` keys in that order,
-- then any remaining colour keys sorted. Non-colour entries (Upstream's
-- `none = "NONE"`) are not part of the Palette and are dropped.
local function ordered_colours(colours, first)
  local object = json.object()
  local seen = {}
  for _, key in ipairs(first or {}) do
    if is_colour(colours[key]) then
      object:set(key, colours[key])
      seen[key] = true
    end
  end
  local rest = {}
  for key, value in pairs(colours) do
    if not seen[key] and is_colour(value) then
      rest[#rest + 1] = key
    end
  end
  table.sort(rest)
  for _, key in ipairs(rest) do
    object:set(key, colours[key])
  end
  return object
end

-- Upstream's terminal exports (ghostty, kitty, wezterm and the rest) add the
-- Bright Colours by lightening these base colours by 10: `add_bright_colors`
-- in upstream/lua/onedarkpro/extra/init.lua. That function is local to
-- Upstream's extra module, so its recipe, the colours and the amount, is
-- repeated here as calls to Upstream's own `lighten`; the terminal oracle
-- test catches any drift from Upstream's export (ADR-0003). Its `bright_fg`,
-- which lightens yellow, is a typo in Upstream and is not emitted. Listed in
-- the order of the base colours.
local BRIGHT_FROM = { "red", "orange", "yellow", "green", "cyan", "blue", "purple", "white", "black", "gray" }
local BRIGHT_AMOUNT = 10

local function bright_colours(variant)
  local helpers = require("onedarkpro.helpers")
  local colours, order = {}, {}
  for _, base in ipairs(BRIGHT_FROM) do
    local name = "bright_" .. base
    colours[name] = helpers.lighten(base, BRIGHT_AMOUNT, variant)
    order[#order + 1] = name
  end
  return ordered_colours(colours, order)
end

local function extract(variant)
  local upstream_theme = require("onedarkpro.theme").load(variant)
  if type(upstream_theme) ~= "table" then
    util.fail("Upstream could not load the Variant " .. variant)
  end
  local palette = json.object()
  palette:set("variant", variant)
  palette:set("appearance", upstream_theme.meta.background)
  palette:set("upstream", util.upstream_commit(root))
  palette:set("base", ordered_colours(upstream_theme.palette, BASE_ORDER))
  palette:set("derived", ordered_colours(upstream_theme.generated))
  palette:set("bright", bright_colours(variant))

  local path = root .. "/palettes/" .. variant .. ".json"
  util.write(path, json.encode(palette))
  print("extracted " .. variant .. " -> " .. (vim.fs.relpath(root, path) or path))
end

local variants = #arg > 0 and arg or { "onedark" }
for _, variant in ipairs(variants) do
  extract(variant)
end
