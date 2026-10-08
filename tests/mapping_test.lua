-- The Mapping, observed through the built Theme. Expected values are
-- Upstream's onedark Palette literals from upstream/lua/onedarkpro/themes/onedark.lua.
local h = require("helpers")

test("walking-skeleton Mapping fills the editor and four Syntax Keys with Upstream's onedark colours", function()
  local style = h.theme_family().themes[1].style
  h.eq(style["background"], "#282c34", "background <- bg")
  h.eq(style["editor.background"], "#282c34", "editor.background <- bg")
  h.eq(style["editor.foreground"], "#abb2bf", "editor.foreground <- fg")
  h.eq(style.syntax.keyword.color, "#c678dd", "syntax.keyword <- purple")
  h.eq(style.syntax.string.color, "#98c379", "syntax.string <- green")
  h.eq(style.syntax.comment.color, "#7f848e", "syntax.comment <- comment")
  h.eq(style.syntax.variable.color, "#e06c75", "syntax.variable <- red")
end)
