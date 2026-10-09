-- The Variants the Theme Family ships, in Theme order, each with its Theme
-- name and the Palette literals the tests expect. The literals are copied
-- from Upstream, never computed: base colours from
-- upstream/lua/onedarkpro/themes/<variant>.lua, Derived Colours and Bright
-- Colours from the committed palettes/<variant>.json, which stage one wrote
-- by running Upstream's own code (ADR-0002, ADR-0003). Every literal is
-- typed lowercase, as stage one writes it; Upstream spells vaporwave's base
-- colours in uppercase.
--
-- The Theme names are pinned, in this order, by tests/shape_test.lua.
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
    variant = "onedark_dark",
    name = "OneDarkPro Onedark Dark",
    literal = {
      -- base
      bg = "#000000", fg = "#abb2bf", red = "#ef596f", orange = "#d19a66", yellow = "#e5c07b",
      green = "#89ca78", cyan = "#2bbac5", blue = "#61afef", purple = "#d55fde", white = "#abb2bf",
      black = "#000000", gray = "#434852", highlight = "#e2be7d", comment = "#7f848e",
      -- derived
      bg_statusline = "#0e0e0e", cursorline = "#171717", float_bg = "#000000", selection = "#212121",
      fg_gutter = "#181818", line_number = "#495162", indentline = "#1f1f1f", fold = "#121212",
      inlay_hint = "#33373e", diff_add = "#10180e", diff_change = "#17130c", diff_delete = "#1d0b0d",
      diff_text = "#0b2f31", diff_text_delete = "#3c161c", git_add = "#356728", git_change = "#a67821",
      git_delete = "#880d1f",
      -- bright
      bright_fg = "#c8cdd5",
    },
  },
  {
    variant = "onedark_vivid",
    name = "OneDarkPro Onedark Vivid",
    literal = {
      -- base
      bg = "#282c34", fg = "#abb2bf", red = "#ef596f", orange = "#d19a66", yellow = "#e5c07b",
      green = "#89ca78", cyan = "#2bbac5", blue = "#61afef", purple = "#d55fde", white = "#abb2bf",
      black = "#282c34", gray = "#5c6370", highlight = "#e2be7d", comment = "#7f848e",
      -- derived
      bg_statusline = "#22252c", cursorline = "#2e333c", float_bg = "#22252c", selection = "#3a404c",
      fg_gutter = "#3d434f", line_number = "#495162", indentline = "#3b4048", fold = "#2f333d",
      inlay_hint = "#4c525c", diff_add = "#343f3c", diff_change = "#3b3b3b", diff_delete = "#40313b",
      diff_text = "#295058", diff_text_delete = "#5a3743", git_add = "#356728", git_change = "#a67821",
      git_delete = "#880d1f",
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
  {
    variant = "vaporwave",
    name = "OneDarkPro Vaporwave",
    literal = {
      -- base
      bg = "#222435", fg = "#b4b7cf", red = "#e16765", orange = "#eaa041", yellow = "#eae852",
      green = "#75be78", cyan = "#46a3af", blue = "#25abe4", purple = "#c678dd", white = "#b4b7cf",
      black = "#222435", gray = "#585b89", highlight = "#e2be7d", comment = "#7679a7",
      -- derived
      bg_statusline = "#1d1f2d", cursorline = "#2a2c41", float_bg = "#1c1e2c", selection = "#2e3148",
      fg_gutter = "#353853", line_number = "#545983", indentline = "#30334b", fold = "#2a2c41",
      inlay_hint = "#4a4d73", diff_add = "#2c363d", diff_change = "#363838", diff_delete = "#392c3b",
      diff_text = "#2b4454", diff_text_delete = "#523541", git_add = "#29572b", git_change = "#919012",
      git_delete = "#7b1a18",
      -- bright
      bright_fg = "#d3d5e3",
    },
  },
}
