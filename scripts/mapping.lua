-- The Mapping: which Palette colour fills each Style Key and Syntax Key.
--
-- Entry order here is the key order in the Theme Family, so keep it
-- deliberate. A value names a Palette colour ("purple"); { "purple", alpha = "33" }
-- appends alpha; a literal "#rrggbb[aa]" is allowed but must still be a
-- Palette colour or the build fails (Palette-faithful). Syntax entries may
-- also carry font_style and font_weight.
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
