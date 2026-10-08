-- Font styles: Upstream's default is no bold or italic anywhere, and its
-- Markdown Filetype Override is the one exception. Only three Syntax Keys may
-- carry a font_style or font_weight, and they must carry these.
local h = require("helpers")

local STYLED = {
  title = { font_weight = 700 }, -- @text.title.markdown bold
  ["emphasis.strong"] = { font_weight = 700 }, -- @markup.strong.markdown_inline bold
  emphasis = { font_style = "italic" }, -- @markup.italic.markdown_inline italic
}

test("title and emphasis.strong are weight 700, emphasis is italic, and no other Syntax Key carries a style or weight", function()
  local syntax = h.theme_family().themes[1].style.syntax
  for key, expected in pairs(STYLED) do
    assert(syntax[key], "syntax." .. key .. " is missing from the Theme")
    h.eq(syntax[key].font_weight, expected.font_weight, "syntax." .. key .. " font_weight")
    h.eq(syntax[key].font_style, expected.font_style, "syntax." .. key .. " font_style")
  end
  for key, entry in pairs(syntax) do
    if not STYLED[key] then
      h.eq(entry.font_weight, nil, "syntax." .. key .. " font_weight")
      h.eq(entry.font_style, nil, "syntax." .. key .. " font_style")
    end
  end
end)
