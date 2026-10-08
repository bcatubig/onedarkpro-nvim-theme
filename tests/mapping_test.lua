-- The Mapping, observed through the built Theme. Expected values are
-- Upstream's onedark Palette literals from upstream/lua/onedarkpro/themes/onedark.lua
-- (and, for Derived Colours, the committed palettes/onedark.json).
local h = require("helpers")

test("walking-skeleton Mapping fills the editor surface with Upstream's bg and fg", function()
  local style = h.theme_family().themes[1].style
  h.eq(style["background"], "#282c34", "background <- bg")
  h.eq(style["editor.background"], "#282c34", "editor.background <- bg")
  h.eq(style["editor.foreground"], "#abb2bf", "editor.foreground <- fg")
end)

-- The full Syntax Key Mapping of ticket #3, grouped by Palette colour:
-- { Palette colour, its onedark literal, the Syntax Keys it fills }.
local GROUPS = {
  { "red", "#e06c75", {
    "variable", "variable.parameter", "variable.member", "property", "tag",
    "string.special.symbol", "diff.minus", "title",
  } },
  { "yellow", "#e5c07b", {
    "variable.special", "type", "type.builtin", "constructor", "namespace", "enum",
    "punctuation.list_marker",
  } },
  { "purple", "#c678dd", {
    "keyword", "label", "punctuation.bracket", "constant.builtin", "link_uri", "emphasis",
  } },
  { "blue", "#61afef", {
    "function", "function.method", "string.special", "link_text", "attribute",
  } },
  { "cyan", "#56b6c2", {
    "function.builtin", "operator", "string.escape", "variant", "selector.pseudo",
  } },
  { "green", "#98c379", {
    "string", "string.regex", "text.literal", "diff.plus",
  } },
  { "orange", "#d19a66", {
    "number", "boolean", "constant", "emphasis.strong", "selector",
  } },
  { "comment", "#7f848e", {
    "comment", "comment.doc", "punctuation.markup", "preproc",
  } },
  { "fg", "#abb2bf", {
    "punctuation", "punctuation.delimiter", "punctuation.special", "punctuation.embedded",
    "embedded", "primary",
  } },
  { "inlay_hint", "#4c525c", { "hint" } },
  { "gray", "#5c6370", { "predictive" } },
}

for _, group in ipairs(GROUPS) do
  local colour, hex, keys = group[1], group[2], group[3]
  test(string.format("Syntax Keys Upstream colours %s are %s in OneDarkPro Onedark", colour, hex), function()
    local syntax = h.theme_family().themes[1].style.syntax
    for _, key in ipairs(keys) do
      local entry = syntax[key]
      assert(entry, "syntax." .. key .. " is missing from the Theme")
      h.eq(entry.color, hex, "syntax." .. key .. " <- " .. colour)
    end
  end)
end
