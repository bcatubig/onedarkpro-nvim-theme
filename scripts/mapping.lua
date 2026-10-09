-- The Mapping: which Palette colour fills each Style Key and Syntax Key.
--
-- Entry order here is the key order in the Theme Family, so keep it
-- deliberate. A value names a Palette colour ("purple"), or is a table
-- { "purple", alpha = "33" } to append alpha. The build also accepts a
-- literal "#rrggbb[aa]" so the Palette-faithful check has teeth, but the
-- committed Mapping must name Palette colours: a literal is not a rule and
-- does not carry across Variants (ADR-0001).
--
-- Style Keys are filled by the Chrome Rules of spec #1. A Chrome Rule is
-- { name, value, { Style Keys... } }: every key in the rule takes the one
-- value, so a rule reads here as it was written and applies unchanged to any
-- Variant's Palette. A Style Key may appear in one Chrome Rule only. `players` and
-- `accents`, Zed's two array-valued Style Keys, have their own sections;
-- `background.appearance` is a constant of the build ("opaque", Upstream's
-- transparency = false).
--
-- A Syntax Key entry is { key, value }; it may also carry font_style =
-- "italic" or font_weight = 700 beside the value, as in
-- { "title", "red", font_weight = 700 }; those are the only font fields Zed
-- reads.
--
-- Syntax Keys are copied from Upstream's Highlight Groups: the treesitter
-- table first (highlights/plugins/treesitter.lua), then vim syntax groups
-- (highlights/syntax.lua) and LSP semantic tokens
-- (highlights/plugins/lsp_semantic_tokens.lua) where treesitter has no entry.
-- Each entry's comment names the Highlight Group it was copied from. Sub-keys
-- not listed inherit by Zed's longest-dot-prefix rule, so `keyword.control`
-- is `keyword` and `function.decorator` is `function`. Two entries copy the
-- Highlight Group nvim shows rather than Upstream's entry for the name,
-- because Upstream has none under the name Zed's query emits:
-- `function.kwargs`, a capture name only Zed's Python query uses, and
-- `string.regex`, whose Upstream entry is the pre-0.10 capture name
-- nvim-treesitter no longer emits (ticket #14).
--
-- Filetype Override rule. Upstream scopes some Highlight Groups to one
-- language (highlights/filetypes/*.lua); Zed has no per-language colours, so
-- one global value must be chosen. The global Upstream value wins unless no
-- language the user writes would ever show it; in that case the value from
-- the emitting language with the most files in the user's code wins. Applied
-- once, this makes `function.builtin` cyan (@function.builtin.go) and
-- `attribute` blue (Zed names only the builtin decorators `attribute`, and
-- nvim shows those blue through @attribute.builtin); every other conflict
-- keeps the global value. Markdown-only Syntax Keys (`title`, `emphasis`,
-- `emphasis.strong`, `text.literal`, `link_text`, `link_uri`,
-- `punctuation.list_marker`, `punctuation.markup`, `punctuation.embedded`)
-- take the Markdown Filetype Override's values, because Zed emits them only
-- from the Markdown grammars.
--
-- Deviations: where Zed shows a different colour from nvim in some language
-- because the global value won. Each names the Filetype Override it loses to.
--   1. Python, YAML and TypeScript brackets: `punctuation.bracket` is purple;
--      nvim shows orange from @punctuation.bracket.python,
--      @punctuation.bracket.yaml and @punctuation.bracket.typescript.
--   2. Go builtin types: `type.builtin` is yellow; nvim shows purple from
--      @type.builtin.go.
--   3. Go constants: `constant` is orange; nvim shows red from @constant.go.
--   4. Python builtin functions: `function.builtin` is cyan; nvim shows blue
--      from @odp.function.builtin.python -> @function.
--   5. Python `None`: `constant.builtin` is purple; nvim shows orange from
--      @constant.builtin.python.
--   6. JSON braces and brackets: `punctuation.bracket` is purple; nvim shows
--      cyan braces and orange brackets from @odp.braces.json and
--      @odp.brackets.json.
--   7. TOML keys: `property` is red; nvim shows purple from @property.toml.
--   8. Python splat operators: `operator` is cyan; nvim shows the `*` and `**`
--      of *args and **kwargs in fg from @odp.operator.splat.python.
--   9. Python f-string braces: `punctuation.special` is fg; nvim shows the `{`
--      and `}` of an interpolation purple from @odp.punctuation.special.python.
-- Deviations 8 and 9 were found by the sign-off kit (docs/sign-off.md), which
-- also lists the Query Differences: tokens Zed's queries capture under a
-- different name from nvim-treesitter's, which a Syntax Key of its own could
-- not close without opening another.
return {
  -- Style Keys, by Chrome Rule. A comment names the nvim Highlight Group a
  -- rule echoes where there is one.
  style = {
    -- Surfaces
    { "Editor surface", "bg", { -- Normal
      "background", "editor.background", "editor.gutter.background", "surface.background",
      "toolbar.background", "tab.active_background", "terminal.background",
      "terminal.ansi.background",
    } },
    { "Statusline surface", "bg_statusline", { -- StatusLine
      "status_bar.background", "title_bar.background", "title_bar.inactive_background",
      "tab_bar.background", "tab.inactive_background", "editor.subheader.background",
      "element.background",
      -- Every Panel joins the frame, so the editor is the one lit surface, as
      -- One Dark Pro (binaryify)'s sidebar is darker than its editor. Upstream's
      -- tree sits on bg; this is a Chrome choice, and one key fills all Panels.
      "panel.background",
    } },
    { "Floating surface", "float_bg", { "elevated_surface.background", "panel.overlay_background" } }, -- NormalFloat
    { "Current line", "cursorline", { -- CursorLine; the hovered row of a menu, as Pmenu
      "editor.active_line.background", "element.hover", "ghost_element.hover", "panel.overlay_hover",
    } },
    { "Selection", "selection", { -- Visual, PmenuSel; player one's selection is in `players`
      "element.selected", "element.active", "ghost_element.selected", "ghost_element.active",
      "element.selection_background", "editor.document_highlight.read_background",
      "editor.document_highlight.write_background", "editor.document_highlight.bracket_background",
    } },

    -- Accents
    { "Cursor and focus accent", "purple", { -- Cursor, CursorLineNr; player one's cursor is in `players`
      "editor.active_line_number", "border.focused", "border.selected", "panel.focused_border",
      "pane.focused_border", "drop_target.border", "debugger.accent",
    } },
    { "Link accent", "blue", { -- Directory; editor.indent_guide_active as SnacksIndentScope
      "text.accent", "icon.accent", "link_text.hover", "editor.indent_guide_active",
    } },

    -- Borders
    { "Pane splits", "gray", { "pane_group.border" } }, -- WinSeparator
    { "Quiet borders", "fg_gutter", {
      "border", "border.variant", "border.disabled", "scrollbar.track.border",
      -- Panel Guides as hairline borders, Zed's own fallback for the key
      -- (border.variant). Upstream's tree markers are gray, but Zed draws a
      -- Guide as a solid one-pixel line the full height of the row where
      -- neo-tree draws a glyph with gaps, so gray reads louder here. The
      -- active folder's Guide is no different, as Zed's bundled themes draw it.
      "panel.indent_guide", "panel.indent_guide_active",
    } },
    { "Transparent", { "bg", alpha = "00" }, { -- bg at 0%: the only transparent colour in the Palette
      "border.transparent", "ghost_element.background", "ghost_element.disabled", "element.disabled",
      "scrollbar.track.background", "scrollbar.thumb.border", "minimap.thumb.border",
    } },

    -- Text
    { "Text", "fg", { "text", "icon", "editor.foreground", "editor.hover_line_number", "terminal.foreground" } }, -- Normal
    { "Muted", "comment", { "text.muted", "icon.muted", "editor.code_lens.foreground" } }, -- Comment
    { "Faint", "gray", { -- NonText
      "text.placeholder", "text.disabled", "icon.placeholder", "icon.disabled", "editor.invisible",
      -- a hovered Panel Guide brightens one step: clicking it collapses the folder
      "panel.indent_guide_hover",
    } },

    -- Editor furniture
    { "Gutter", "line_number", { "editor.line_number" } }, -- LineNr
    { "Guides", "indentline", { -- IndentLine (snacks indent)
      "editor.indent_guide", "editor.wrap_guide", "editor.active_wrap_guide",
    } },
    { "Line flash", "fold", { "editor.highlighted_line.background" } }, -- Folded
    { "Debugger active line", "diff_change", { "editor.debugger_active_line.background" } }, -- DiffChange

    -- Tints
    { "Search match", { "highlight", alpha = "4d" }, { "search.match_background" } }, -- Search, as hlslens
    { "Search active match", { "highlight", alpha = "8c" }, { "search.active_match_background" } }, -- CurSearch
    { "Thumbs", { "gray", alpha = "66" }, { "scrollbar.thumb.background", "minimap.thumb.background" } },
    { "Thumbs hovered", { "gray", alpha = "99" }, { "scrollbar.thumb.hover_background", "minimap.thumb.hover_background" } },
    { "Thumbs active", { "gray", alpha = "cc" }, { "scrollbar.thumb.active_background", "minimap.thumb.active_background" } },
    { "Drop target", { "selection", alpha = "80" }, { "drop_target.background" } },

    -- Diagnostics and status: the colour, then its 15% tint behind and its
    -- 50% border. Diagnostic* in nvim.
    { "Error", "red", { "error" } },
    { "Error tint", { "red", alpha = "26" }, { "error.background" } },
    { "Error border", { "red", alpha = "80" }, { "error.border" } },
    { "Warning", "yellow", { "warning" } },
    { "Warning tint", { "yellow", alpha = "26" }, { "warning.background" } },
    { "Warning border", { "yellow", alpha = "80" }, { "warning.border" } },
    { "Info", "blue", { "info" } },
    { "Info tint", { "blue", alpha = "26" }, { "info.background" } },
    { "Info border", { "blue", alpha = "80" }, { "info.border" } },
    { "Hint", "cyan", { "hint" } },
    { "Hint tint", { "cyan", alpha = "26" }, { "hint.background" } },
    { "Hint border", { "cyan", alpha = "80" }, { "hint.border" } },
    { "Success", "green", { "success" } },
    { "Success tint", { "green", alpha = "26" }, { "success.background" } },
    { "Success border", { "green", alpha = "80" }, { "success.border" } },
    { "Predictive", "gray", { "predictive" } },
    { "Predictive tint", { "gray", alpha = "26" }, { "predictive.background" } },
    { "Predictive border", { "gray", alpha = "80" }, { "predictive.border" } },

    -- File status, version control and diff hunks, as neo-tree, gitsigns and
    -- diffview show them. Added, modified and deleted files are tinted with
    -- the diff colours and bordered with the git colours; the other statuses
    -- take the Diagnostics pattern so that no status key is left to Zed.
    { "Added", "green", { "created", "version_control.added", "editor.diff_hunk.added.hollow_border" } }, -- GitSignsAdd
    { "Added tint", "diff_add", { -- DiffAdd
      "created.background", "editor.diff_hunk.added.background", "editor.diff_hunk.added.hollow_background",
      "version_control.conflict_marker.ours",
    } },
    { "Added border", "git_add", { "created.border" } },
    { "Modified", "yellow", { "modified", "version_control.modified" } }, -- GitSignsChange
    { "Modified tint", "diff_change", { "modified.background" } }, -- DiffChange
    { "Modified border", "git_change", { "modified.border" } },
    { "Deleted", "red", { "deleted", "version_control.deleted", "editor.diff_hunk.deleted.hollow_border" } }, -- GitSignsDelete
    { "Deleted tint", "diff_delete", { -- DiffDelete
      "deleted.background", "editor.diff_hunk.deleted.background", "editor.diff_hunk.deleted.hollow_background",
    } },
    { "Deleted border", "git_delete", { "deleted.border" } },
    { "Renamed and conflict", "blue", { "renamed", "version_control.renamed", "conflict", "version_control.conflict" } }, -- NeoTreeGitRenamed, NeoTreeGitConflict
    { "Renamed and conflict tint", { "blue", alpha = "26" }, { "renamed.background", "conflict.background" } },
    { "Renamed and conflict border", { "blue", alpha = "80" }, { "renamed.border", "conflict.border" } },
    { "Ignored", "gray", { "ignored", "hidden", "unreachable", "version_control.ignored" } }, -- NeoTreeGitIgnored, NeoTreeDotfile
    { "Ignored tint", { "gray", alpha = "26" }, { "ignored.background", "hidden.background", "unreachable.background" } },
    { "Ignored border", { "gray", alpha = "80" }, { "ignored.border", "hidden.border", "unreachable.border" } },
    { "Changed text", "diff_text", { "version_control.word_added", "version_control.conflict_marker.theirs" } }, -- DiffText
    { "Deleted text", "diff_text_delete", { "version_control.word_deleted" } },

    -- Vim mode indicator, as lualine's mode section: the mode colour behind
    -- text in bg.
    { "Vim normal", "green", { "vim.normal.background" } },
    { "Vim insert", "blue", { "vim.insert.background" } },
    { "Vim visual", "yellow", { "vim.visual.background", "vim.visual_line.background", "vim.visual_block.background", "vim.yank.background" } },
    { "Vim replace", "red", { "vim.replace.background" } },
    { "Helix", "purple", { "vim.helix_normal.background", "vim.helix_select.background" } },
    { "Helix jump label", "red", { "vim.helix_jump_label.foreground" } },
    { "Vim mode text", "bg", {
      "vim.normal.foreground", "vim.insert.foreground", "vim.replace.foreground", "vim.visual.foreground",
      "vim.visual_line.foreground", "vim.visual_block.foreground", "vim.helix_normal.foreground",
      "vim.helix_select.foreground",
    } },

    -- Terminal, slot for slot as Upstream's ghostty, kitty and wezterm
    -- exports fill it (upstream/lua/onedarkpro/extra/ghostty.lua and its
    -- siblings): black and white are the Palette's `black` and `white`,
    -- magenta is purple, bright black is gray and slots 9 to 15 take the
    -- Bright Colours. The export's background and foreground, bg and
    -- fg, fill terminal.background, terminal.ansi.background (Zed's colour
    -- for a cell on the default background) and terminal.foreground above,
    -- by "Editor surface" and "Text".
    { "ANSI black", "black", { "terminal.ansi.black" } },
    { "ANSI red", "red", { "terminal.ansi.red" } },
    { "ANSI green", "green", { "terminal.ansi.green" } },
    { "ANSI yellow", "yellow", { "terminal.ansi.yellow" } },
    { "ANSI blue", "blue", { "terminal.ansi.blue" } },
    { "ANSI magenta", "purple", { "terminal.ansi.magenta" } },
    { "ANSI cyan", "cyan", { "terminal.ansi.cyan" } },
    { "ANSI white", "white", { "terminal.ansi.white" } },
    { "ANSI bright black", "gray", { "terminal.ansi.bright_black" } },
    { "ANSI bright red", "bright_red", { "terminal.ansi.bright_red" } },
    { "ANSI bright green", "bright_green", { "terminal.ansi.bright_green" } },
    { "ANSI bright yellow", "bright_yellow", { "terminal.ansi.bright_yellow" } },
    { "ANSI bright blue", "bright_blue", { "terminal.ansi.bright_blue" } },
    { "ANSI bright magenta", "bright_purple", { "terminal.ansi.bright_magenta" } },
    { "ANSI bright cyan", "bright_cyan", { "terminal.ansi.bright_cyan" } },
    { "ANSI bright white", "bright_white", { "terminal.ansi.bright_white" } },
    -- The lightened fg, the Bright Colour Upstream's exports meant by
    -- `bright_fg` (their helper lightens yellow by mistake, and only the rio
    -- export reads it). In onedark white equals fg, so this is bright_white;
    -- in onelight bright_white is #ffffff on a #fafafa terminal, and the
    -- lightened fg stays a readable grey.
    { "Bright foreground", "bright_fg", { "terminal.bright_foreground" } },
    -- Dim: the normal colour at 60%, where the exports darken by 10, so that
    -- faint text fades without a colour outside the Palette (ADR-0001).
    { "ANSI dim black", { "black", alpha = "99" }, { "terminal.ansi.dim_black" } },
    { "ANSI dim red", { "red", alpha = "99" }, { "terminal.ansi.dim_red" } },
    { "ANSI dim green", { "green", alpha = "99" }, { "terminal.ansi.dim_green" } },
    { "ANSI dim yellow", { "yellow", alpha = "99" }, { "terminal.ansi.dim_yellow" } },
    { "ANSI dim blue", { "blue", alpha = "99" }, { "terminal.ansi.dim_blue" } },
    { "ANSI dim magenta", { "purple", alpha = "99" }, { "terminal.ansi.dim_magenta" } },
    { "ANSI dim cyan", { "cyan", alpha = "99" }, { "terminal.ansi.dim_cyan" } },
    { "ANSI dim white", { "white", alpha = "99" }, { "terminal.ansi.dim_white" } },
    { "Dim foreground", { "fg", alpha = "99" }, { "terminal.dim_foreground" } },
  },

  -- Players: Zed's collaborator colours. Player one is the user: cursor and
  -- background purple (Cursor), selection as Visual. Players two to eight
  -- cycle Upstream's accent colours with the selection at 25%.
  players = {
    { cursor = "purple", background = "purple", selection = "selection" },
    { cursor = "blue", background = "blue", selection = { "blue", alpha = "40" } },
    { cursor = "green", background = "green", selection = { "green", alpha = "40" } },
    { cursor = "yellow", background = "yellow", selection = { "yellow", alpha = "40" } },
    { cursor = "red", background = "red", selection = { "red", alpha = "40" } },
    { cursor = "cyan", background = "cyan", selection = { "cyan", alpha = "40" } },
    { cursor = "orange", background = "orange", selection = { "orange", alpha = "40" } },
    { cursor = "gray", background = "gray", selection = { "gray", alpha = "40" } },
  },

  -- Accents: rainbow brackets, in the order of Upstream's RainbowDelimiter
  -- groups (highlights/plugins/rainbow_delimiters.lua).
  accents = { "red", "yellow", "blue", "orange", "green", "purple", "cyan" },

  -- Syntax Keys, grouped by Palette colour.
  syntax = {
    -- red
    { "variable", "red" }, -- @variable
    { "variable.parameter", "red" }, -- @variable.parameter
    { "variable.member", "red" }, -- @variable.member
    { "function.kwargs", "red" }, -- @variable.parameter: Zed's Python query names keyword-argument names function.kwargs, which would inherit function, blue; nvim-treesitter names the same token @variable.parameter
    { "property", "red" }, -- @property (Deviation 7)
    { "tag", "red" }, -- @tag
    { "string.special.symbol", "red" }, -- @string.special.symbol
    { "diff.minus", "red" }, -- removed lines in diffs; DiffDelete is a tint of red
    { "title", "red", font_weight = 700 }, -- @text.title.markdown (Markdown Filetype Override), bold

    -- yellow
    { "variable.special", "yellow" }, -- @variable.builtin (`self`, `this`)
    { "type", "yellow" }, -- Type, @type
    { "type.builtin", "yellow" }, -- @type.builtin -> @type (Deviation 2)
    { "constructor", "yellow" }, -- @constructor
    { "namespace", "yellow" }, -- @module
    { "enum", "yellow" }, -- @lsp.type.enum -> @type
    { "punctuation.list_marker", "yellow" }, -- @markup.list.markdown (Markdown Filetype Override)

    -- purple
    { "keyword", "purple" }, -- Keyword, @keyword; every keyword.* sub-key inherits
    { "label", "purple" }, -- Label, @label
    { "punctuation.bracket", "purple" }, -- @punctuation.bracket (Deviations 1 and 6)
    { "constant.builtin", "purple" }, -- @constant.builtin (Deviation 5)
    { "link_uri", "purple" }, -- @text.uri.markdown_inline (Markdown Filetype Override)
    { "emphasis", "purple", font_style = "italic" }, -- @markup.italic.markdown_inline (Markdown Filetype Override), italic

    -- blue
    { "function", "blue" }, -- Function, @function; function.call and function.decorator inherit
    { "function.method", "blue" }, -- @function.method
    { "string.special", "blue" }, -- @string.special -> Special
    { "string.regex", "blue" }, -- @string.regexp -> @string.special -> Special, what nvim shows: Upstream's @string.regex (green) is the pre-0.10 name, which nvim-treesitter no longer emits
    { "link_text", "blue" }, -- @text.reference.markdown_inline (Markdown Filetype Override)
    { "attribute", "blue" }, -- @attribute.builtin: Zed names only @property, @classmethod and @staticmethod `attribute`, and nvim shows those blue (Special), so blue by the Filetype Override rule over @attribute purple; plain decorator names reach Zed as function.decorator, a Query Difference

    -- cyan
    { "function.builtin", "cyan" }, -- @function.builtin.go, by the Filetype Override rule over @function.builtin yellow (Deviation 4)
    { "operator", "cyan" }, -- Operator, @operator (Deviation 8)
    { "string.escape", "cyan" }, -- @string.escape
    { "variant", "cyan" }, -- @lsp.type.enumMember
    { "selector.pseudo", "cyan" }, -- @odp.pseudo_class.scss

    -- green
    { "string", "green" }, -- String, @string
    { "text.literal", "green" }, -- @text.literal.markdown_inline (Markdown Filetype Override)
    { "diff.plus", "green" }, -- added lines in diffs; DiffAdd is a tint of green

    -- orange
    { "number", "orange" }, -- Number, @number
    { "boolean", "orange" }, -- Boolean, @boolean
    { "constant", "orange" }, -- Constant, @constant (Deviation 3)
    { "emphasis.strong", "orange", font_weight = 700 }, -- @markup.strong.markdown_inline (Markdown Filetype Override), bold
    { "selector", "orange" }, -- @odp.selector.scss

    -- comment
    { "comment", "comment" }, -- Comment, @comment
    { "comment.doc", "comment" }, -- @comment (Upstream has no documentation-comment group)
    { "punctuation.markup", "comment" }, -- @punctuation.special.markdown (Markdown Filetype Override)
    { "preproc", "comment" }, -- Zed's Go grammar captures `//go:` directives as preproc; nvim shows them as Comment

    -- fg
    { "punctuation", "fg" }, -- Delimiter
    { "punctuation.delimiter", "fg" }, -- @punctuation.delimiter -> Delimiter
    { "punctuation.special", "fg" }, -- @punctuation.special (`$` and `$(` in shell; Deviation 9)
    { "punctuation.embedded", "fg" }, -- @markup.raw.delimiter.markdown (Markdown Filetype Override): Zed emits this only for fenced-block fences and info strings; inline backticks are part of text.literal
    { "embedded", "fg" }, -- embedded code reads as plain text, as nvim shows it
    { "primary", "fg" }, -- Zed's catch-all for plain identifiers in some grammars

    -- editor text that is not code
    { "hint", "inlay_hint" }, -- LspInlayHint
    { "predictive", "gray" }, -- NonText: edit-prediction ghost text
  },
}
