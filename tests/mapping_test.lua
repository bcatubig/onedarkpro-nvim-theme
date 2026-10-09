-- The Syntax Key Mapping, observed through the built Theme. Expected values
-- are Upstream's Palette literals for each Variant (tests/variants.lua).
-- Every assertion runs against every Theme the Theme Family ships. Style
-- Keys are checked in chrome_test.lua.
local h = require("helpers")

-- The full Syntax Key Mapping of ticket #3, with #14's two entries, grouped by Palette colour:
-- { Palette colour, the Syntax Keys it fills }.
local GROUPS = {
  { "red", {
    "variable", "variable.parameter", "variable.member", "property", "tag",
    "string.special.symbol", "diff.minus", "title", "function.kwargs",
  } },
  { "yellow", {
    "variable.special", "type", "type.builtin", "constructor", "namespace", "enum",
    "punctuation.list_marker",
  } },
  { "purple", {
    "keyword", "label", "punctuation.bracket", "constant.builtin", "link_uri", "emphasis",
  } },
  { "blue", {
    "function", "function.method", "string.special", "link_text", "attribute", "string.regex",
  } },
  { "cyan", {
    "function.builtin", "operator", "string.escape", "variant", "selector.pseudo",
  } },
  { "green", {
    "string", "text.literal", "diff.plus",
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
  local literal = t.literal
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
