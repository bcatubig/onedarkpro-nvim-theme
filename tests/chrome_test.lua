-- The Chrome Rules, observed through the built Theme. Expected values are
-- Upstream's Palette literals for each Variant: base colours from
-- upstream/lua/onedarkpro/themes/<variant>.lua, Derived Colours from the
-- committed palettes/<variant>.json. Every assertion runs against every
-- Theme the Theme Family ships; a Chrome Rule names a Palette colour, so the
-- same rule is checked against each Variant's literal for that colour.
local h = require("helpers")

-- The literal of each Palette colour the Chrome Rules name, per Variant.
local LITERALS = {
  onedark = {
    bg = "#282c34", bg_statusline = "#22262d", float_bg = "#21252b", cursorline = "#2d313b",
    selection = "#414858", purple = "#c678dd", blue = "#61afef", gray = "#5c6370",
    fg_gutter = "#3d4350", fg = "#abb2bf", comment = "#7f848e", line_number = "#495162",
    indentline = "#3b4048", fold = "#30333d", diff_change = "#3b3b3b", red = "#e06c75",
    yellow = "#e5c07b", cyan = "#56b6c2", green = "#98c379", orange = "#d19a66",
    diff_add = "#353e3c", diff_delete = "#3e343c", git_add = "#405f2b", git_change = "#a67821",
    git_delete = "#7f1b22", diff_text = "#344f58", diff_text_delete = "#563c44", highlight = "#e2be7d",
    black = "#282c34", white = "#abb2bf",
  },
  onelight = {
    bg = "#fafafa", bg_statusline = "#f3f3f3", float_bg = "#efefef", cursorline = "#f4f4f4",
    selection = "#e9e9e9", purple = "#9a77cf", blue = "#118dc3", gray = "#bebebe",
    fg_gutter = "#e1e1e1", fg = "#6a6a6a", comment = "#9b9fa6", line_number = "#cccccc",
    indentline = "#e7e7e7", fold = "#f2f2f2", diff_change = "#f9f2e5", red = "#e05661",
    yellow = "#eea825", cyan = "#56b6c2", green = "#1da912", orange = "#ee9025",
    diff_add = "#dff0de", diff_delete = "#f7e6e8", git_add = "#85f17c", git_change = "#f9e1b3",
    git_delete = "#fcedee", diff_text = "#d1e9ec", diff_text_delete = "#f3d1d4", highlight = "#e2be7d",
    black = "#6a6a6a", white = "#fafafa",
  },
}

-- The Style Keys of ticket #4, grouped by Palette colour: { Palette colour,
-- the Style Keys it fills }. Alpha-bearing keys, the terminal's dim colours
-- of ticket #5 among them, are checked separately below; the terminal's
-- other Style Keys are checked against Upstream's export in terminal_test.lua.
local GROUPS = {
  { "bg", {
    "background", "editor.background", "editor.gutter.background", "surface.background",
    "panel.background", "toolbar.background", "tab.active_background", "terminal.background",
    -- the vim mode indicator's text sits on its mode colour
    "vim.normal.foreground", "vim.insert.foreground", "vim.replace.foreground", "vim.visual.foreground",
    "vim.visual_line.foreground", "vim.visual_block.foreground", "vim.helix_normal.foreground",
    "vim.helix_select.foreground",
  } },
  { "bg_statusline", {
    "status_bar.background", "title_bar.background", "title_bar.inactive_background",
    "tab_bar.background", "tab.inactive_background", "editor.subheader.background",
    "element.background",
  } },
  { "float_bg", { "elevated_surface.background", "panel.overlay_background" } },
  { "cursorline", {
    "editor.active_line.background", "element.hover", "ghost_element.hover", "panel.overlay_hover",
  } },
  { "selection", {
    "element.selected", "element.active", "ghost_element.selected", "ghost_element.active",
    "element.selection_background", "editor.document_highlight.read_background",
    "editor.document_highlight.write_background", "editor.document_highlight.bracket_background",
  } },
  { "purple", {
    "editor.active_line_number", "border.focused", "border.selected", "panel.focused_border",
    "pane.focused_border", "drop_target.border", "debugger.accent",
    "vim.helix_normal.background", "vim.helix_select.background",
  } },
  { "blue", {
    "text.accent", "icon.accent", "link_text.hover", "editor.indent_guide_active",
    "panel.indent_guide_active",
    "info", "renamed", "conflict", "version_control.renamed", "version_control.conflict",
    "vim.insert.background",
  } },
  { "gray", {
    "pane_group.border", "text.placeholder", "text.disabled", "icon.placeholder", "icon.disabled",
    "editor.invisible", "panel.indent_guide",
    "predictive", "ignored", "hidden", "unreachable", "version_control.ignored",
  } },
  { "fg_gutter", { "border", "border.variant", "border.disabled", "scrollbar.track.border" } },
  { "fg", { "text", "icon", "editor.foreground", "editor.hover_line_number", "terminal.foreground" } },
  { "comment", { "text.muted", "icon.muted", "editor.code_lens.foreground" } },
  { "line_number", { "editor.line_number" } },
  { "indentline", {
    "editor.indent_guide", "editor.wrap_guide", "editor.active_wrap_guide", "panel.indent_guide_hover",
  } },
  { "fold", { "editor.highlighted_line.background" } },
  { "diff_change", { "editor.debugger_active_line.background", "modified.background" } },
  -- Diagnostics, file status, version control and diff hunks
  { "red", {
    "error", "deleted", "version_control.deleted", "editor.diff_hunk.deleted.hollow_border",
    "vim.replace.background", "vim.helix_jump_label.foreground",
  } },
  { "yellow", {
    "warning", "modified", "version_control.modified",
    "vim.visual.background", "vim.visual_line.background", "vim.visual_block.background", "vim.yank.background",
  } },
  { "cyan", { "hint" } },
  { "green", {
    "success", "created", "version_control.added", "editor.diff_hunk.added.hollow_border",
    "vim.normal.background",
  } },
  { "diff_add", {
    "created.background", "editor.diff_hunk.added.background", "editor.diff_hunk.added.hollow_background",
    "version_control.conflict_marker.ours",
  } },
  { "diff_delete", {
    "deleted.background", "editor.diff_hunk.deleted.background", "editor.diff_hunk.deleted.hollow_background",
  } },
  { "git_add", { "created.border" } },
  { "git_change", { "modified.border" } },
  { "git_delete", { "deleted.border" } },
  { "diff_text", { "version_control.word_added", "version_control.conflict_marker.theirs" } },
  { "diff_text_delete", { "version_control.word_deleted" } },
}

-- Alpha is granted to these Style Keys only, as { Palette colour, alpha };
-- players' selections, checked in their own test, are the other exception.
-- Every other colour is #rrggbb.
local ALPHA = {
  -- Transparent: bg at 0%
  ["border.transparent"] = { "bg", "00" },
  ["ghost_element.background"] = { "bg", "00" },
  ["ghost_element.disabled"] = { "bg", "00" },
  ["element.disabled"] = { "bg", "00" },
  ["scrollbar.track.background"] = { "bg", "00" },
  ["scrollbar.thumb.border"] = { "bg", "00" },
  ["minimap.thumb.border"] = { "bg", "00" },
  -- Search: highlight at 30% and 55%
  ["search.match_background"] = { "highlight", "4d" },
  ["search.active_match_background"] = { "highlight", "8c" },
  -- Scrollbar and minimap thumbs: gray at 40%, 60% hovered, 80% active
  ["scrollbar.thumb.background"] = { "gray", "66" },
  ["minimap.thumb.background"] = { "gray", "66" },
  ["scrollbar.thumb.hover_background"] = { "gray", "99" },
  ["minimap.thumb.hover_background"] = { "gray", "99" },
  ["scrollbar.thumb.active_background"] = { "gray", "cc" },
  ["minimap.thumb.active_background"] = { "gray", "cc" },
  -- Drop target: selection at 50%
  ["drop_target.background"] = { "selection", "80" },
  -- Diagnostics and status: the colour at 15% behind, at 50% as border
  ["error.background"] = { "red", "26" }, ["error.border"] = { "red", "80" },
  ["warning.background"] = { "yellow", "26" }, ["warning.border"] = { "yellow", "80" },
  ["info.background"] = { "blue", "26" }, ["info.border"] = { "blue", "80" },
  ["hint.background"] = { "cyan", "26" }, ["hint.border"] = { "cyan", "80" },
  ["success.background"] = { "green", "26" }, ["success.border"] = { "green", "80" },
  ["predictive.background"] = { "gray", "26" }, ["predictive.border"] = { "gray", "80" },
  -- File statuses without a diff tint take the same pattern
  ["renamed.background"] = { "blue", "26" }, ["renamed.border"] = { "blue", "80" },
  ["conflict.background"] = { "blue", "26" }, ["conflict.border"] = { "blue", "80" },
  ["ignored.background"] = { "gray", "26" }, ["ignored.border"] = { "gray", "80" },
  ["hidden.background"] = { "gray", "26" }, ["hidden.border"] = { "gray", "80" },
  ["unreachable.background"] = { "gray", "26" }, ["unreachable.border"] = { "gray", "80" },
  -- Terminal: the dim colours and the dim foreground at 60% of their normal
  -- colour. ANSI black and white are the Palette's black and white, which
  -- equal bg and fg in onedark and are the other way about in onelight.
  ["terminal.ansi.dim_black"] = { "black", "99" },
  ["terminal.ansi.dim_red"] = { "red", "99" },
  ["terminal.ansi.dim_green"] = { "green", "99" },
  ["terminal.ansi.dim_yellow"] = { "yellow", "99" },
  ["terminal.ansi.dim_blue"] = { "blue", "99" },
  ["terminal.ansi.dim_magenta"] = { "purple", "99" },
  ["terminal.ansi.dim_cyan"] = { "cyan", "99" },
  ["terminal.ansi.dim_white"] = { "white", "99" },
  ["terminal.dim_foreground"] = { "fg", "99" },
}

-- Players: { Palette colour, selection as { Palette colour, alpha } }.
-- Player one is the user: purple cursor, selection as Visual. Players two to
-- eight cycle Upstream's accent colours with the selection at 25%.
local PLAYERS = {
  { "purple", { "selection" } },
  { "blue", { "blue", "40" } },
  { "green", { "green", "40" } },
  { "yellow", { "yellow", "40" } },
  { "red", { "red", "40" } },
  { "cyan", { "cyan", "40" } },
  { "orange", { "orange", "40" } },
  { "gray", { "gray", "40" } },
}

-- Accents: Upstream's RainbowDelimiter order.
local ACCENTS = { "red", "yellow", "blue", "orange", "green", "purple", "cyan" }

for _, t in ipairs(h.THEMES) do
  local literal = LITERALS[t.variant]
  local function tinted(spec)
    return literal[spec[1]] .. (spec[2] or "")
  end

  for _, group in ipairs(GROUPS) do
    local colour, keys = group[1], group[2]
    test(string.format("Style Keys mapped to Palette %s are Upstream's %s in %s", colour, literal[colour], t.name), function()
      local style = h.theme(t.name).style
      for _, key in ipairs(keys) do
        h.eq(style[key], literal[colour], key .. " <- " .. colour)
      end
    end)
  end

  test(string.format("alpha-granted Style Keys carry their stated tint in %s", t.name), function()
    local style = h.theme(t.name).style
    for key, spec in pairs(ALPHA) do
      h.eq(style[key], tinted(spec), key .. " <- " .. spec[1] .. " at " .. spec[2])
    end
  end)

  test(string.format("no other Style Key of %s has an 8-digit colour", t.name), function()
    local style = h.theme(t.name).style
    for key, value in pairs(style) do
      if type(value) == "string" and #value == 9 then
        assert(ALPHA[key], key .. " = " .. value .. " carries alpha the rules do not grant")
      end
    end
  end)

  test(string.format("background.appearance of %s is opaque, as Upstream's transparency = false", t.name), function()
    h.eq(h.theme(t.name).style["background.appearance"], "opaque", "background.appearance")
  end)

  test(string.format("players[0] of %s is the purple cursor with Upstream's selection; players[1..7] cycle the accent colours with selection at 25%%", t.name), function()
    local players = h.theme(t.name).style.players
    assert(players, "players is missing from the Theme")
    h.eq(#players, #PLAYERS, "number of players")
    for i, expected in ipairs(PLAYERS) do
      local label = "players[" .. (i - 1) .. "]"
      h.eq(players[i].cursor, literal[expected[1]], label .. ".cursor <- " .. expected[1])
      h.eq(players[i].background, literal[expected[1]], label .. ".background <- " .. expected[1])
      h.eq(players[i].selection, tinted(expected[2]), label .. ".selection <- " .. expected[2][1])
    end
  end)

  test(string.format("accents of %s are red, yellow, blue, orange, green, purple, cyan: Upstream's RainbowDelimiter order", t.name), function()
    local accents = h.theme(t.name).style.accents
    assert(accents, "accents is missing from the Theme")
    h.eq(#accents, #ACCENTS, "number of accents")
    for i, colour in ipairs(ACCENTS) do
      h.eq(accents[i], literal[colour], "accents[" .. (i - 1) .. "] <- " .. colour)
    end
  end)
end
