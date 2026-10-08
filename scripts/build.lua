-- Stage two: build.
--
-- Reads the committed Palette files, applies the Mapping and writes the Theme
-- Family to themes/onedarkpro.json with a stable, insertion-ordered key order.
-- Every emitted colour must be Palette-faithful: alpha stripped, it must be a
-- Palette colour of its Variant, or the build fails naming the key and colour.
--
--   nvim --clean -l scripts/build.lua [--mapping FILE] [--out FILE]

local root = vim.fs.dirname(vim.fs.dirname(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")))
package.path = root .. "/scripts/?.lua;" .. package.path

local json = require("lib.json")
local util = require("lib.util")

local PALETTES = root .. "/palettes"
local SCHEMA = "https://zed.dev/schema/themes/v0.2.0.json"
local FAMILY = "OneDarkPro"
local AUTHOR = "Brandon Catubig"
-- Upstream's `transparency = false`: the window background is opaque.
local APPEARANCE = "opaque"

local opts = {
  mapping = root .. "/scripts/mapping.lua",
  out = root .. "/themes/onedarkpro.json",
}
do
  local i = 1
  while i <= #arg do
    local flag = arg[i]:match("^%-%-(.+)$")
    if flag and opts[flag] ~= nil and arg[i + 1] then
      opts[flag] = arg[i + 1]
      i = i + 2
    else
      util.fail("usage: nvim --clean -l scripts/build.lua [--mapping FILE] [--out FILE]")
    end
  end
end

local mapping = dofile(opts.mapping)

-- onedark -> "OneDarkPro Onedark", onedark_vivid -> "OneDarkPro Onedark Vivid"
local function theme_name(variant)
  local words = {}
  for word in variant:gmatch("[^_]+") do
    words[#words + 1] = word:sub(1, 1):upper() .. word:sub(2)
  end
  return FAMILY .. " " .. table.concat(words, " ")
end

local function load_palettes(dir)
  local files = {}
  for name, kind in vim.fs.dir(dir) do
    if kind == "file" and name:match("%.json$") then
      files[#files + 1] = name
    end
  end
  table.sort(files)
  local palettes = {}
  for _, file in ipairs(files) do
    palettes[#palettes + 1] = json.decode(util.read(dir .. "/" .. file))
  end
  return palettes
end

-- The colours of a Variant's Palette (base colours, Derived Colours and
-- Bright Colours): by name, and as a set for the Palette-faithful check.
local function palette_colours(palette)
  local by_name, set = {}, {}
  for _, group in ipairs({ palette.base, palette.derived, palette.bright }) do
    for name, colour in pairs(group) do
      by_name[name] = colour
      set[colour:lower()] = true
    end
  end
  return by_name, set
end

local function build_theme(palette)
  local by_name, palette_set = palette_colours(palette)
  local name = theme_name(palette.variant)

  -- Resolve a Mapping value for `key`. A value names a Palette colour
  -- ("purple"), optionally with alpha ({ "purple", alpha = "33" }, two hex
  -- digits), or is a literal "#rrggbb[aa]". Either way the result must be
  -- Palette-faithful.
  local function colour_for(key, spec)
    local colour_name, alpha = spec, nil
    if type(spec) == "table" then
      colour_name, alpha = spec[1], spec.alpha
    end
    if type(colour_name) ~= "string" then
      util.fail(string.format("Mapping: %s %s has no Palette colour", name, key))
    end
    local colour = colour_name
    if colour_name:sub(1, 1) ~= "#" then
      colour = by_name[colour_name]
      if not colour then
        util.fail(string.format("Mapping: %s %s names an unknown Palette colour %s", name, key, colour_name))
      end
    end
    if alpha then
      if type(alpha) ~= "string" or not alpha:match("^%x%x$") then
        util.fail(string.format("Mapping: %s %s has alpha %s, not two hex digits", name, key, vim.inspect(alpha)))
      end
      colour = colour .. alpha
    end
    if not palette_set[colour:sub(1, 7):lower()] then
      util.fail(string.format("Palette-faithful: %s %s = %s is not in the %s Palette", name, key, colour, palette.variant))
    end
    return colour
  end

  local theme = json.object()
  theme:set("name", name)
  theme:set("appearance", palette.appearance)

  -- Style Keys are filled by Chrome Rules { name, colour-spec, { keys } }:
  -- every key in a rule takes the rule's one colour. A key may be filled by
  -- one rule only, so a rule cannot silently override an earlier one.
  local style = json.object()
  style:set("background.appearance", APPEARANCE)
  for _, rule in ipairs(mapping.style) do
    local label, spec, keys = rule[1], rule[2], rule[3]
    if type(label) ~= "string" or type(keys) ~= "table" then
      util.fail(string.format("Mapping: %s Chrome Rule %s is not { name, colour, { keys } }", name, vim.inspect(label)))
    end
    for _, key in ipairs(keys) do
      if style:has(key) then
        util.fail(string.format("Mapping: %s %s is filled twice, last by the Chrome Rule %q", name, key, label))
      end
      style:set(key, colour_for(key, spec))
    end
  end

  -- Players are { cursor, background, selection } colour-specs; accents are
  -- colour-specs. Both are arrays in the Theme, so their keys in messages
  -- are written as Zed's JSON paths, players[0].cursor and accents[0].
  local players = {}
  for i, player in ipairs(mapping.players or {}) do
    local colours = json.object()
    for _, field in ipairs({ "cursor", "background", "selection" }) do
      colours:set(field, colour_for(string.format("players[%d].%s", i - 1, field), player[field]))
    end
    players[#players + 1] = colours
  end
  style:set("players", players)

  local accents = {}
  for i, spec in ipairs(mapping.accents or {}) do
    accents[#accents + 1] = colour_for(string.format("accents[%d]", i - 1), spec)
  end
  style:set("accents", accents)

  -- A Syntax Key entry is { key, colour-spec, font_style = ..., font_weight = ... };
  -- the font fields are optional and are the only ones Zed reads besides color.
  local syntax = json.object()
  for _, entry in ipairs(mapping.syntax) do
    local key, spec = entry[1], entry[2]
    local syntax_style = json.object()
    syntax_style:set("color", colour_for("syntax." .. key, spec))
    for _, field in ipairs({ "font_style", "font_weight" }) do
      if entry[field] ~= nil then
        syntax_style:set(field, entry[field])
      end
    end
    syntax:set(key, syntax_style)
  end
  style:set("syntax", syntax)

  theme:set("style", style)
  return theme
end

local family = json.object()
family:set("$schema", SCHEMA)
family:set("name", FAMILY)
family:set("author", AUTHOR)
local themes = {}
for _, palette in ipairs(load_palettes(PALETTES)) do
  themes[#themes + 1] = build_theme(palette)
end
family:set("themes", themes)

util.write(opts.out, json.encode(family))
print("built " .. #themes .. " Theme(s) -> " .. (vim.fs.relpath(root, opts.out) or opts.out))
