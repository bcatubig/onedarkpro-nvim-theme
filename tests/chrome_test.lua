-- The Chrome Rules, observed through the built Theme. Expected values are
-- Upstream's onedark Palette literals: base colours from
-- upstream/lua/onedarkpro/themes/onedark.lua, Derived Colours from the
-- committed palettes/onedark.json.
local h = require("helpers")

-- The Style Keys of ticket #4, grouped by Palette colour: { Palette colour,
-- its onedark literal, the Style Keys it fills }. Alpha-bearing keys are
-- checked separately.
local GROUPS = {
  { "bg", "#282c34", {
    "background", "editor.background", "editor.gutter.background", "surface.background",
    "panel.background", "toolbar.background", "tab.active_background", "terminal.background",
    -- the vim mode indicator's text sits on its mode colour
    "vim.normal.foreground", "vim.insert.foreground", "vim.replace.foreground", "vim.visual.foreground",
    "vim.visual_line.foreground", "vim.visual_block.foreground", "vim.helix_normal.foreground",
    "vim.helix_select.foreground",
  } },
  { "bg_statusline", "#22262d", {
    "status_bar.background", "title_bar.background", "title_bar.inactive_background",
    "tab_bar.background", "tab.inactive_background", "editor.subheader.background",
    "element.background",
  } },
  { "float_bg", "#21252b", { "elevated_surface.background", "panel.overlay_background" } },
  { "cursorline", "#2d313b", {
    "editor.active_line.background", "element.hover", "ghost_element.hover", "panel.overlay_hover",
  } },
  { "selection", "#414858", {
    "element.selected", "element.active", "ghost_element.selected", "ghost_element.active",
    "element.selection_background", "editor.document_highlight.read_background",
    "editor.document_highlight.write_background", "editor.document_highlight.bracket_background",
  } },
  { "purple", "#c678dd", {
    "editor.active_line_number", "border.focused", "border.selected", "panel.focused_border",
    "pane.focused_border", "drop_target.border", "debugger.accent",
    "vim.helix_normal.background", "vim.helix_select.background",
  } },
  { "blue", "#61afef", {
    "text.accent", "icon.accent", "link_text.hover", "editor.indent_guide_active",
    "panel.indent_guide_active",
    "info", "renamed", "conflict", "version_control.renamed", "version_control.conflict",
    "vim.insert.background",
  } },
  { "gray", "#5c6370", {
    "pane_group.border", "text.placeholder", "text.disabled", "icon.placeholder", "icon.disabled",
    "editor.invisible", "panel.indent_guide",
    "predictive", "ignored", "hidden", "unreachable", "version_control.ignored",
  } },
  { "fg_gutter", "#3d4350", { "border", "border.variant", "border.disabled", "scrollbar.track.border" } },
  { "fg", "#abb2bf", { "text", "icon", "editor.foreground", "editor.hover_line_number", "terminal.foreground" } },
  { "comment", "#7f848e", { "text.muted", "icon.muted", "editor.code_lens.foreground" } },
  { "line_number", "#495162", { "editor.line_number" } },
  { "indentline", "#3b4048", {
    "editor.indent_guide", "editor.wrap_guide", "editor.active_wrap_guide", "panel.indent_guide_hover",
  } },
  { "fold", "#30333d", { "editor.highlighted_line.background" } },
  { "diff_change", "#3b3b3b", { "editor.debugger_active_line.background", "modified.background" } },
  -- Diagnostics, file status, version control and diff hunks
  { "red", "#e06c75", {
    "error", "deleted", "version_control.deleted", "editor.diff_hunk.deleted.hollow_border",
    "vim.replace.background", "vim.helix_jump_label.foreground",
  } },
  { "yellow", "#e5c07b", {
    "warning", "modified", "version_control.modified",
    "vim.visual.background", "vim.visual_line.background", "vim.visual_block.background", "vim.yank.background",
  } },
  { "cyan", "#56b6c2", { "hint" } },
  { "green", "#98c379", {
    "success", "created", "version_control.added", "editor.diff_hunk.added.hollow_border",
    "vim.normal.background",
  } },
  { "diff_add", "#353e3c", {
    "created.background", "editor.diff_hunk.added.background", "editor.diff_hunk.added.hollow_background",
    "version_control.conflict_marker.ours",
  } },
  { "diff_delete", "#3e343c", {
    "deleted.background", "editor.diff_hunk.deleted.background", "editor.diff_hunk.deleted.hollow_background",
  } },
  { "git_add", "#405f2b", { "created.border" } },
  { "git_change", "#a67821", { "modified.border" } },
  { "git_delete", "#7f1b22", { "deleted.border" } },
  { "diff_text", "#344f58", { "version_control.word_added", "version_control.conflict_marker.theirs" } },
  { "diff_text_delete", "#563c44", { "version_control.word_deleted" } },
}

for _, group in ipairs(GROUPS) do
  local colour, hex, keys = group[1], group[2], group[3]
  test(string.format("Style Keys mapped to Palette %s are Upstream's %s in OneDarkPro Onedark", colour, hex), function()
    local style = h.theme_family().themes[1].style
    for _, key in ipairs(keys) do
      h.eq(style[key], hex, key .. " <- " .. colour)
    end
  end)
end

-- Alpha is granted to these Style Keys only; players' selections, checked in
-- their own test, are the other exception. Every other colour is #rrggbb.
local ALPHA = {
  -- Transparent: bg at 0%
  ["border.transparent"] = "#282c3400",
  ["ghost_element.background"] = "#282c3400",
  ["ghost_element.disabled"] = "#282c3400",
  ["element.disabled"] = "#282c3400",
  ["scrollbar.track.background"] = "#282c3400",
  ["scrollbar.thumb.border"] = "#282c3400",
  ["minimap.thumb.border"] = "#282c3400",
  -- Search: highlight at 30% and 55%
  ["search.match_background"] = "#e2be7d4d",
  ["search.active_match_background"] = "#e2be7d8c",
  -- Scrollbar and minimap thumbs: gray at 40%, 60% hovered, 80% active
  ["scrollbar.thumb.background"] = "#5c637066",
  ["minimap.thumb.background"] = "#5c637066",
  ["scrollbar.thumb.hover_background"] = "#5c637099",
  ["minimap.thumb.hover_background"] = "#5c637099",
  ["scrollbar.thumb.active_background"] = "#5c6370cc",
  ["minimap.thumb.active_background"] = "#5c6370cc",
  -- Drop target: selection at 50%
  ["drop_target.background"] = "#41485880",
  -- Diagnostics and status: the colour at 15% behind, at 50% as border
  ["error.background"] = "#e06c7526", ["error.border"] = "#e06c7580",
  ["warning.background"] = "#e5c07b26", ["warning.border"] = "#e5c07b80",
  ["info.background"] = "#61afef26", ["info.border"] = "#61afef80",
  ["hint.background"] = "#56b6c226", ["hint.border"] = "#56b6c280",
  ["success.background"] = "#98c37926", ["success.border"] = "#98c37980",
  ["predictive.background"] = "#5c637026", ["predictive.border"] = "#5c637080",
  -- File statuses without a diff tint take the same pattern
  ["renamed.background"] = "#61afef26", ["renamed.border"] = "#61afef80",
  ["conflict.background"] = "#61afef26", ["conflict.border"] = "#61afef80",
  ["ignored.background"] = "#5c637026", ["ignored.border"] = "#5c637080",
  ["hidden.background"] = "#5c637026", ["hidden.border"] = "#5c637080",
  ["unreachable.background"] = "#5c637026", ["unreachable.border"] = "#5c637080",
}

test("alpha-granted Style Keys carry their stated tint in OneDarkPro Onedark", function()
  local style = h.theme_family().themes[1].style
  for key, hex in pairs(ALPHA) do
    h.eq(style[key], hex, key)
  end
end)

test("no other Style Key has an 8-digit colour", function()
  local style = h.theme_family().themes[1].style
  for key, value in pairs(style) do
    if type(value) == "string" and #value == 9 then
      assert(ALPHA[key], key .. " = " .. value .. " carries alpha the rules do not grant")
    end
  end
end)

test("background.appearance is opaque, as Upstream's transparency = false", function()
  h.eq(h.theme_family().themes[1].style["background.appearance"], "opaque", "background.appearance")
end)

-- Players: { Palette colour, its onedark literal, the selection colour }.
-- Player one is the user: purple cursor, selection as Visual. Players two to
-- eight cycle Upstream's accent colours with the selection at 25%.
local PLAYERS = {
  { "purple", "#c678dd", "#414858" },
  { "blue", "#61afef", "#61afef40" },
  { "green", "#98c379", "#98c37940" },
  { "yellow", "#e5c07b", "#e5c07b40" },
  { "red", "#e06c75", "#e06c7540" },
  { "cyan", "#56b6c2", "#56b6c240" },
  { "orange", "#d19a66", "#d19a6640" },
  { "gray", "#5c6370", "#5c637040" },
}

test("players[0] is the purple cursor with Upstream's selection; players[1..7] cycle the accent colours with selection at 25%", function()
  local players = h.theme_family().themes[1].style.players
  assert(players, "players is missing from the Theme")
  h.eq(#players, #PLAYERS, "number of players")
  for i, expected in ipairs(PLAYERS) do
    local label = "players[" .. (i - 1) .. "]"
    h.eq(players[i].cursor, expected[2], label .. ".cursor <- " .. expected[1])
    h.eq(players[i].background, expected[2], label .. ".background <- " .. expected[1])
    h.eq(players[i].selection, expected[3], label .. ".selection")
  end
end)

test("accents are red, yellow, blue, orange, green, purple, cyan: Upstream's RainbowDelimiter order", function()
  local accents = h.theme_family().themes[1].style.accents
  assert(accents, "accents is missing from the Theme")
  local expected = { "#e06c75", "#e5c07b", "#61afef", "#d19a66", "#98c379", "#c678dd", "#56b6c2" }
  h.eq(#accents, #expected, "number of accents")
  for i, hex in ipairs(expected) do
    h.eq(accents[i], hex, "accents[" .. (i - 1) .. "]")
  end
end)
