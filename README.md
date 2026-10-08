# OneDarkPro for Zed

A Zed theme extension that reproduces the colours of [olimorris/onedarkpro.nvim](https://github.com/olimorris/onedarkpro.nvim) (Upstream). It ships one Theme Family, **OneDarkPro**, with two Themes:

| Theme               | Appearance | Upstream Variant |
| ------------------- | ---------- | ---------------- |
| OneDarkPro Onedark  | dark       | `onedark`        |
| OneDarkPro Onelight | light      | `onelight`       |

The Themes are generated, not hand-written. Upstream's Palette and its syntax Mapping are copied; the Zed UI surfaces that nvim has no equivalent for are filled from the same Palette by written Chrome Rules; the build fails if any colour is not in the Palette. The capitalised terms used here are defined in the glossary, [CONTEXT.md](CONTEXT.md).

## Not the other One Dark Pro

Zed's registry lists ten One Dark themes, among them `one-dark-pro` and `one-dark-pro-enhanced`. Those descend from binaryify's VS Code theme, a different project with a different palette that shares only an ancestor with Upstream. This extension is derived from Upstream alone, so that nvim, the terminals that take Upstream's exports (ghostty, kitty, wezterm) and Zed all show one family of colours. Nothing here is taken from the binaryify lineage or from Zed's own One Dark ([ADR-0001](docs/adr/0001-palette-faithful-chrome.md)).

## Install as a dev extension

The Theme Family, `themes/onedarkpro.json`, is committed, so installing needs only Zed and a clone. nvim is needed only to rebuild.

1. Clone the repository: `git clone https://github.com/bcatubig/onedarkpro-nvim-theme.git`.
2. In Zed, open the Extensions page (`zed: extensions` in the command palette), click **Install Dev Extension** and select the clone. Zed symlinks it into `~/Library/Application Support/Zed/extensions/installed/onedarkpro-nvim-theme` and reads `extension.toml`.
3. Pick a Theme with `theme selector: toggle`, or set the dark/light pair in `~/.config/zed/settings.json` so that system appearance switching stays within the family:

```json
{
  "theme": {
    "mode": "system",
    "light": "OneDarkPro Onelight",
    "dark": "OneDarkPro Onedark"
  }
}
```

`mode` is `"system"`, `"light"` or `"dark"`.

Two facts about Zed worth knowing:

- Zed does not hot-reload theme JSON. After a rebuild, quit Zed and relaunch it.
- Zed's extension index is rebuilt at launch only when the `installed/` directory is newer than the index. The theme file itself is loaded whole at every launch, so a rebuilt Theme shows up after a restart, but a Theme with a *new name* needs `touch "$HOME/Library/Application Support/Zed/extensions/installed"` before the restart to appear in the theme selector.

Zed's hosted theme schema lags Zed's real key set (it lacks `version_control`, `vim`, `minimap` and some editor keys). Zed loads those keys regardless; editor-side schema validation may warn on them.

To try a one-off change on top of the finished Theme, italic comments for example, use Zed's `theme_overrides` setting, which takes the same shape as a Theme's `style`. Nothing in the repository needs to change.

## Build and test

Requires nvim 0.11 or newer (the build runs on 0.12) and the Upstream submodule:

```sh
git submodule update --init
make
```

`make` runs three stages, each a Lua script under headless nvim. Any failing stage stops it.

- `make extract`, stage one (`scripts/extract.lua`): loads Upstream from the submodule and asks it for each Variant's Palette: the base colours, every Derived Colour exactly as nvim computes it with `cursorline = true`, and the Bright Colours by Upstream's own `lighten`. It writes `palettes/<variant>.json`, which records the Upstream commit it came from ([ADR-0002](docs/adr/0002-derived-colours-from-upstream-code.md), [ADR-0003](docs/adr/0003-bright-colours-from-upstream-lighten.md)).
- `make build`, stage two (`scripts/build.lua`): reads every committed Palette file, applies the Mapping in `scripts/mapping.lua` and writes `themes/onedarkpro.json` with a stable key order. It exits non-zero, naming the key and the colour, on any colour outside the Variant's Palette.
- `make test`: runs `tests/*_test.lua` through `tests/run.lua`. Tests read only the built Theme Family, the build command, the committed Palette files and Upstream's committed exports; never the Mapping.

Both outputs are committed. Regenerating from an unchanged Upstream leaves the tree clean, so a diff in `palettes/` or `themes/` is always a real change.

## Re-sync Upstream

Upstream is pinned as a git submodule at `upstream/`. To move to a newer Upstream:

```sh
git -C upstream fetch origin
git -C upstream checkout <commit>   # e.g. the commit your nvim lock file pins
make
git diff palettes/ themes/
```

Read the Palette diff first: it shows every colour Upstream changed, by name. The Theme diff follows from it. The terminal oracle test compares each Theme's sixteen ANSI colours with Upstream's committed ghostty export for the Variant, so a change in Upstream's Bright Colour recipe fails `make` instead of drifting. Commit the submodule pointer, the Palette files and the Theme Family together.

## How colours are chosen

**Palette-faithful.** Every colour in a Theme is a Palette colour of its Variant, with alpha permitted where a Chrome Rule grants it (search matches, scrollbar thumbs, diagnostic backgrounds). No colour appears in a Theme that does not appear in the Palette: no hand-picked greys, nothing borrowed from Zed's One Dark. The build enforces it, so a Chrome colour that looks wrong is fixed by changing a Chrome Rule, never by adding a colour.

**Syntax Keys are copied from Upstream's Highlight Groups**: the treesitter table first, then vim syntax groups and LSP semantic tokens where treesitter has no entry. Each entry in the Mapping names the Highlight Group it was copied from. Sub-keys not listed inherit by Zed's longest-dot-prefix rule, so `keyword.control` is `keyword` and `function.decorator` is `function`.

**Filetype Override rule.** Upstream scopes some Highlight Groups to one language (`@punctuation.bracket.python` is orange where brackets are purple elsewhere). Zed has no per-language colours, so one global value must be chosen for each Syntax Key. The global Upstream value wins unless no language the user writes would ever show it; in that case the value from the emitting language with the most files in the user's code wins. Applied once, this makes `function.builtin` cyan (Go's `@function.builtin.go`) and leaves every other conflict at the global value. Markdown-only Syntax Keys (`title`, `emphasis`, `text.literal`, `link_text`, `link_uri`, `punctuation.list_marker` and so on) take Upstream's Markdown override, because Zed emits them only from the Markdown grammars.

**Chrome Rules.** Every Style Key is filled by a named rule in `scripts/mapping.lua`: "Editor surface" is `bg`, "Current line" is `cursorline`, "Search match" is `highlight` at 30%. A rule names a Palette colour, never a literal, so the same rules fill every Variant without a second design pass. Where a rule echoes an nvim Highlight Group (CursorLine, Visual, LineNr, Pmenu, DiffAdd) its comment says so.

## Deviations

A Deviation is a Syntax Key whose Zed colour differs from what nvim shows in some language, because the global value won. Each is recorded beside the Mapping with the Filetype Override it loses to.

1. **Python, YAML and TypeScript brackets** are purple (`punctuation.bracket`); nvim shows orange.
2. **Go builtin types** (`int`, `string`, `error`, `any`) are yellow (`type.builtin`); nvim shows purple.
3. **Go constants** are orange (`constant`); nvim shows red.
4. **Python builtin functions** are cyan (`function.builtin`), and the type constructors `str()`, `list()`, `range()` yellow (`type.builtin`); nvim shows all of them blue.
5. **Python `None`** is purple (`constant.builtin`); nvim shows orange.
6. **JSON braces and brackets** are purple; nvim shows cyan braces and orange brackets.
7. **TOML keys** are red (`property`); nvim shows purple.
8. **Python splat operators** in `*args` and `**kwargs` are cyan (`operator`); nvim shows fg.
9. **Python f-string braces** are fg (`punctuation.special`); nvim shows purple.
10. **Python decorator names** are blue (`function.decorator`); nvim shows the `@` blue and the name after it purple, except builtins such as `@property` and dotted calls such as `@a.b()`, which are blue too.

Zed and nvim also differ where Zed's highlight query and nvim-treesitter's capture the same token under different names, or Zed's captures nothing. Those are Query Differences, not Deviations: no Filetype Override is involved and the Mapping cannot reach them. They are listed per language in the sign-off checklist.

## Sign-off kit

`samples/` holds one file per sign-off language: Go, Terraform, YAML in Ansible shapes, Markdown, Python and shell. Each exercises the token classes the Mapping colours. [docs/sign-off.md](docs/sign-off.md) walks through opening each sample in nvim and Zed side by side, with the expected colour for every token class, the Deviations and Query Differences that apply to that language, and the Chrome and terminal checks. The samples are not inputs to the build or the tests.

## Adding a Variant

Upstream has three more Variants: `onedark_vivid`, `onedark_dark` and `vaporwave`. To ship one:

1. Add its name to `VARIANTS` in `scripts/extract.lua`.
2. Run `make`. Stage one writes `palettes/<variant>.json`; stage two builds a Theme from it with the unchanged Mapping, named "OneDarkPro " plus the Variant in title case with underscores as spaces ("OneDarkPro Onedark Vivid"). Themes are ordered by Palette filename.
3. Give the tests the Variant's Upstream literals in `tests/variants.lua`, and its Theme name and the new count in `tests/shape_test.lua`.

No rule or Mapping change is needed. The Chrome Rules name Derived Colours such as `cursorline` and `float_bg`, whichever way Upstream computes them for the Variant.

## Layout

```
extension.toml           Zed extension manifest
themes/onedarkpro.json   the Theme Family (generated, committed)
palettes/*.json          one Palette per Variant (generated, committed)
scripts/extract.lua      stage one
scripts/build.lua        stage two
scripts/mapping.lua      the Mapping: Chrome Rules, players, accents, Syntax Keys, Deviations
tests/                   plain Lua tests, run by nvim
samples/                 the sign-off samples
docs/sign-off.md         the sign-off checklist
docs/adr/                decisions
CONTEXT.md               glossary
upstream/                olimorris/onedarkpro.nvim, pinned as a submodule
```

## Credits and licence

The colours and the syntax mapping are Upstream's: [olimorris/onedarkpro.nvim](https://github.com/olimorris/onedarkpro.nvim), copyright Oli Morris, MIT licence. This repository is MIT as well (see [LICENSE](LICENSE)).

The decisions behind the build are recorded in three ADRs:

- [ADR-0001](docs/adr/0001-palette-faithful-chrome.md): Palette-faithful Chrome by written rules, not borrowed from Zed One Dark.
- [ADR-0002](docs/adr/0002-derived-colours-from-upstream-code.md): Derived Colours by running Upstream's code under nvim.
- [ADR-0003](docs/adr/0003-bright-colours-from-upstream-lighten.md): Bright Colours by calling Upstream's `lighten` helper with its export recipe.

Publishing to Zed's registry and contributing an `extra/zed` generator to Upstream are out of scope; nothing here is meant to make either harder.
