-- The Syntax Key Mapping, observed through the built Theme. Expected values
-- are Upstream's Palette literals for each Variant: base colours from
-- upstream/lua/onedarkpro/themes/<variant>.lua and, for Derived Colours, the
-- committed palettes/<variant>.json. Every assertion runs against every
-- Theme the Theme Family ships. Style Keys are checked in chrome_test.lua.
local h = require("helpers")

-- The literal of each Palette colour the Syntax Mapping names, per Variant.
local LITERALS = {
  onedark = {
    red = "#e06c75", yellow = "#e5c07b", purple = "#c678dd", blue = "#61afef", cyan = "#56b6c2",
    green = "#98c379", orange = "#d19a66", comment = "#7f848e", fg = "#abb2bf",
    inlay_hint = "#4c525c", gray = "#5c6370",
  },
  onelight = {
    red = "#e05661", yellow = "#eea825", purple = "#9a77cf", blue = "#118dc3", cyan = "#56b6c2",
    green = "#1da912", orange = "#ee9025", comment = "#9b9fa6", fg = "#6a6a6a",
    inlay_hint = "#d8d8d8", gray = "#bebebe",
  },
}

-- The full Syntax Key Mapping of ticket #3, grouped by Palette colour:
-- { Palette colour, the Syntax Keys it fills }.
local GROUPS = {
  { "red", {
    "variable", "variable.parameter", "variable.member", "property", "tag",
    "string.special.symbol", "diff.minus", "title",
  } },
  { "yellow", {
    "variable.special", "type", "type.builtin", "constructor", "namespace", "enum",
    "punctuation.list_marker",
  } },
  { "purple", {
    "keyword", "label", "punctuation.bracket", "constant.builtin", "link_uri", "emphasis",
  } },
  { "blue", {
    "function", "function.method", "string.special", "link_text", "attribute",
  } },
  { "cyan", {
    "function.builtin", "operator", "string.escape", "variant", "selector.pseudo",
  } },
  { "green", {
    "string", "string.regex", "text.literal", "diff.plus",
  } },
  { "orange", {
    "number", "boolean", "constant", "emphasis.strong", "selector",
  } },
  { "comment", {
    "comment", "comment.doc", "punctuation.markup", "preproc",
  } },
  { "fg", {
    "punctuation", "punctuation.delimiter", "punctuation.special", "punctuation.embedded",
    "embedded", "primary",
  } },
  { "inlay_hint", { "hint" } },
  { "gray", { "predictive" } },
}

for _, t in ipairs(h.THEMES) do
  local literal = LITERALS[t.variant]
  for _, group in ipairs(GROUPS) do
    local colour, keys = group[1], group[2]
    test(string.format("Syntax Keys mapped to Palette %s are Upstream's %s in %s", colour, literal[colour], t.name), function()
      local syntax = h.theme(t.name).style.syntax
      for _, key in ipairs(keys) do
        local entry = syntax[key]
        assert(entry, "syntax." .. key .. " is missing from the Theme")
        h.eq(entry.color, literal[colour], "syntax." .. key .. " <- " .. colour)
      end
    end)
  end
end
