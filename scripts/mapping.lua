-- The Mapping: which Palette colour fills each Style Key and Syntax Key.
--
-- Entry order here is the key order in the Theme Family, so keep it
-- deliberate. A value names a Palette colour ("purple"), or
-- { "purple", alpha = "33" } to append alpha. The build also accepts a literal
-- "#rrggbb[aa]" so the Palette-faithful check has teeth, but the committed
-- Mapping must name Palette colours: a literal is not a rule and does not
-- carry across Variants (ADR-0001).
return {
  -- Style Keys: the editor surface.
  style = {
    { "background", "bg" },
    { "editor.background", "bg" },
    { "editor.foreground", "fg" },
  },

  -- Syntax Keys, copied from Upstream's Highlight Groups.
  syntax = {
    { "keyword", "purple" }, -- Keyword, @keyword
    { "string", "green" }, -- String, @string
    { "comment", "comment" }, -- Comment, @comment
    { "variable", "red" }, -- Identifier, @variable
  },
}
