-- The Variants the Theme Family ships, in Theme order, each with its Theme
-- name and the Palette literals the tests expect. The literals are copied
-- from Upstream, never computed: base colours from
-- upstream/lua/onedarkpro/themes/<variant>.lua, Derived Colours and Bright
-- Colours from the committed palettes/<variant>.json, which stage one wrote
-- by running Upstream's own code (ADR-0002, ADR-0003).
--
-- Adding a Variant to the tests is one entry here, with its literals, plus
-- the Theme name and count that tests/shape_test.lua pins.
return {
  {
    variant = "onedark",
    name = "OneDarkPro Onedark",
    literal = {
      -- base
      bg = "#282c34", fg = "#abb2bf", red = "#e06c75", orange = "#d19a66", yellow = "#e5c07b",
      green = "#98c379", cyan = "#56b6c2", blue = "#61afef", purple = "#c678dd", white = "#abb2bf",
      black = "#282c34", gray = "#5c6370", highlight = "#e2be7d", comment = "#7f848e",
      -- derived
      bg_statusline = "#22262d", cursorline = "#2d313b", float_bg = "#21252b", selection = "#414858",
      fg_gutter = "#3d4350", line_number = "#495162", indentline = "#3b4048", fold = "#30333d",
      inlay_hint = "#4c525c", diff_add = "#353e3c", diff_change = "#3b3b3b", diff_delete = "#3e343c",
      diff_text = "#344f58", diff_text_delete = "#563c44", git_add = "#405f2b", git_change = "#a67821",
      git_delete = "#7f1b22",
      -- bright
      bright_fg = "#c8cdd5",
    },
  },
  {
    variant = "onelight",
    name = "OneDarkPro Onelight",
    literal = {
      -- base
      bg = "#fafafa", fg = "#6a6a6a", red = "#e05661", orange = "#ee9025", yellow = "#eea825",
      green = "#1da912", cyan = "#56b6c2", blue = "#118dc3", purple = "#9a77cf", white = "#fafafa",
      black = "#6a6a6a", gray = "#bebebe", highlight = "#e2be7d", comment = "#9b9fa6",
      -- derived
      bg_statusline = "#f3f3f3", cursorline = "#f4f4f4", float_bg = "#efefef", selection = "#e9e9e9",
      fg_gutter = "#e1e1e1", line_number = "#cccccc", indentline = "#e7e7e7", fold = "#f2f2f2",
      inlay_hint = "#d8d8d8", diff_add = "#dff0de", diff_change = "#f9f2e5", diff_delete = "#f7e6e8",
      diff_text = "#d1e9ec", diff_text_delete = "#f3d1d4", git_add = "#85f17c", git_change = "#f9e1b3",
      git_delete = "#fcedee",
      -- bright
      bright_fg = "#848484",
    },
  },
}
