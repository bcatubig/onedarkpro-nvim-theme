-- The Mapping: which Palette colour fills each Style Key and Syntax Key.
--
-- Entry order here is the key order in the Theme Family, so keep it
-- deliberate. An entry is { key, value }; the value names a Palette colour
-- ("purple"), or is a table { "purple", alpha = "33" } to append alpha. A
-- Syntax Key entry may also carry font_style = "italic" or font_weight = 700
-- beside the value, as in { "title", "red", font_weight = 700 }; those are
-- the only font fields Zed reads. The build also accepts a literal
-- "#rrggbb[aa]" so the Palette-faithful check has teeth, but the committed
-- Mapping must name Palette colours: a literal is not a rule and does not
-- carry across Variants (ADR-0001).
--
-- Syntax Keys are copied from Upstream's Highlight Groups: the treesitter
-- table first (highlights/plugins/treesitter.lua), then vim syntax groups
-- (highlights/syntax.lua) and LSP semantic tokens
-- (highlights/plugins/lsp_semantic_tokens.lua) where treesitter has no entry.
-- Each entry's comment names the Highlight Group it was copied from. Sub-keys
-- not listed inherit by Zed's longest-dot-prefix rule, so `keyword.control`
-- is `keyword` and `function.decorator` is `function`.
--
-- Filetype Override rule. Upstream scopes some Highlight Groups to one
-- language (highlights/filetypes/*.lua); Zed has no per-language colours, so
-- one global value must be chosen. The global Upstream value wins unless no
-- language the user writes would ever show it; in that case the value from
-- the emitting language with the most files in the user's code wins. Applied
-- once, this makes `function.builtin` cyan (@function.builtin.go) and
-- `attribute` blue (@odp.decorator.python -> @function); every other conflict
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
return {
  -- Style Keys: the editor surface.
  style = {
    { "background", "bg" },
    { "editor.background", "bg" },
    { "editor.foreground", "fg" },
  },

  -- Syntax Keys, grouped by Palette colour.
  syntax = {
    -- red
    { "variable", "red" }, -- @variable
    { "variable.parameter", "red" }, -- @variable.parameter
    { "variable.member", "red" }, -- @variable.member
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
    { "link_text", "blue" }, -- @text.reference.markdown_inline (Markdown Filetype Override)
    { "attribute", "blue" }, -- @odp.decorator.python -> @function, by the Filetype Override rule over @attribute purple

    -- cyan
    { "function.builtin", "cyan" }, -- @function.builtin.go, by the Filetype Override rule over @function.builtin yellow (Deviation 4)
    { "operator", "cyan" }, -- Operator, @operator
    { "string.escape", "cyan" }, -- @string.escape
    { "variant", "cyan" }, -- @lsp.type.enumMember
    { "selector.pseudo", "cyan" }, -- @odp.pseudo_class.scss

    -- green
    { "string", "green" }, -- String, @string
    { "string.regex", "green" }, -- @string.regex
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
    { "punctuation.special", "fg" }, -- @punctuation.special (`$` and `$(` in shell)
    { "punctuation.embedded", "fg" }, -- @markup.raw.delimiter.markdown (Markdown Filetype Override): Zed emits this only for fenced-block fences and info strings; inline backticks are part of text.literal
    { "embedded", "fg" }, -- embedded code reads as plain text, as nvim shows it
    { "primary", "fg" }, -- Zed's catch-all for plain identifiers in some grammars

    -- editor text that is not code
    { "hint", "inlay_hint" }, -- LspInlayHint
    { "predictive", "gray" }, -- NonText: edit-prediction ghost text
  },
}
