# OneDarkPro for Zed

A Zed theme extension that reproduces the colour language of olimorris/onedarkpro.nvim. Upstream's palette and syntax mapping are copied; Zed UI surfaces that have no nvim equivalent are filled from the palette using Zed's own conventions.

## Language

### Upstream

**Upstream**:
The olimorris/onedarkpro.nvim project, the single source of truth for colours and syntax mapping.
_Avoid_: One Dark Pro, the nvim theme, Atom One Dark

**One Dark Pro (binaryify)**:
A different project: the VS Code theme by binaryify, and the Zed extensions derived from it (`one-dark-pro`, `one-dark-pro-enhanced`, and others). Not related to Upstream beyond a shared ancestor.
_Avoid_: calling it "One Dark Pro" without the qualifier when Upstream is in scope

**Variant**:
One of Upstream's five colourschemes: `onedark`, `onelight`, `onedark_vivid`, `onedark_dark`, `vaporwave`. Each has its own Palette.
_Avoid_: flavour, scheme, colorscheme

**Palette**:
The named colours a Variant defines. The fourteen base colours (bg, fg, red, orange, yellow, green, cyan, blue, purple, white, black, gray, highlight, comment) plus the Derived Colours.
_Avoid_: colours, theme colors

**Derived Colour**:
A Palette colour Upstream computes from a base colour by lighten, darken, brighten or blend (cursorline, selection, float_bg, fg_gutter, diff_add, git_change, and so on).
_Avoid_: generated colour, computed colour

**Highlight Group**:
An nvim styling target: a vim group (`Comment`), a treesitter capture (`@keyword`), or an LSP semantic token (`@lsp.type.class`). Upstream's side of the Mapping.
_Avoid_: scope, token

**Filetype Override**:
A Highlight Group Upstream scopes to one language (`@punctuation.bracket.python`), changing the colour for that language only. Zed has no equivalent, so a Filetype Override can only inform a global choice.
_Avoid_: language override, per-language rule

### Zed

**Theme Family**:
One Zed theme JSON file holding one or more Themes under `themes[]`. This extension ships one Theme Family.
_Avoid_: theme file, theme pack

**Theme**:
One entry in a Theme Family: a name, an appearance (light or dark), and a Style. One Theme per Variant.
_Avoid_: variant (that word is reserved for Upstream's colourschemes)

**Style Key**:
A Zed UI colour slot in a Theme's `style` object, such as `editor.background` or `tab.active_background`.
_Avoid_: UI colour, chrome key

**Syntax Key**:
A Zed code-token slot under `style.syntax`, such as `keyword` or `punctuation.bracket`. Zed resolves a capture to the longest dot-prefix Syntax Key defined.
_Avoid_: scope, highlight

**Chrome**:
The set of Style Keys with no Highlight Group counterpart: title bar, tabs, panels, status bar, scrollbars, players, and similar.
_Avoid_: UI, non-editor colours

### This project

**Mapping**:
The table assigning a Palette colour to each Syntax Key and Style Key. For Syntax Keys it is copied from Upstream's Highlight Groups. For Chrome it is this project's own.
_Avoid_: colour assignments, overrides

**Chrome Rule**:
A named entry in the Mapping that fills a list of Style Keys with one Palette colour, with alpha where the rule grants it. The unit in which Style Keys are specified, so the same rule fills every Variant.
_Avoid_: rule group, colour group, style group

**Palette-faithful**:
The invariant that every colour in a Theme is a Palette colour of its Variant, with alpha permitted. No colour appears in a Theme that does not appear in the Palette.
_Avoid_: pixel-faithful, exact match

**Deviation**:
A Syntax Key whose Zed colour differs from what nvim shows in some language, because a Filetype Override could not be expressed globally. Every Deviation is recorded with its reason.
_Avoid_: bug, mismatch, known issue
