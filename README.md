# OneDarkPro for Zed

The [onedarkpro.nvim](https://github.com/olimorris/onedarkpro.nvim) colours as a Zed theme: **OneDarkPro Onedark** and **OneDarkPro Onelight**.

The themes are generated from the plugin's own palette and highlight definitions. Syntax colours copy its treesitter groups; UI colours that nvim has no equivalent for are filled from the same palette by fixed rules. Every colour in the theme exists in the palette, and the build fails otherwise.

Not related to the "One Dark Pro" themes already in Zed's registry, which descend from binaryify's VS Code theme.

## Install

The theme is not in Zed's registry. Install it as a dev extension:

1. `git clone https://github.com/bcatubig/onedarkpro-nvim-theme.git`
2. In Zed, open **Extensions**, click **Install Dev Extension** and select the clone.
3. Pick a theme with `theme selector: toggle`, or set the pair in `settings.json`:

```json
{
  "theme": {
    "mode": "system",
    "light": "OneDarkPro Onelight",
    "dark": "OneDarkPro Onedark"
  }
}
```

The theme JSON is committed; nothing needs building to install.

## Building

Requires Neovim 0.11 or newer and the submodule:

```sh
git submodule update --init
make
```

`make` runs onedarkpro.nvim headlessly to extract each variant's palette into `palettes/`, builds `themes/onedarkpro.json` from it with the mapping in `scripts/mapping.lua`, and runs the tests. Zed does not reload theme files; restart it after building.

To update to a newer onedarkpro.nvim, check out the commit in `upstream/`, run `make`, and review the diff in `palettes/`.

## Differences from nvim

Zed has no per-language colours. Where onedarkpro.nvim overrides a highlight group for one filetype, the global colour is used instead:

1. Python, YAML and TypeScript brackets are purple (nvim: orange)
2. Go builtin types are yellow (nvim: purple)
3. Go constants are orange (nvim: red)
4. Python builtin functions are cyan (nvim: blue)
5. Python `None` is purple (nvim: orange)
6. JSON braces and brackets are purple (nvim: cyan and orange)
7. TOML keys are red (nvim: purple)
8. Python `*args` and `**kwargs` stars are cyan (nvim: foreground)
9. Python f-string braces are foreground (nvim: purple)

Other differences come from Zed's grammars capturing tokens differently from nvim-treesitter. They are listed per language in [docs/sign-off.md](docs/sign-off.md), along with sample files for comparing the two editors.

## Adding a variant

onedarkpro.nvim also ships `onedark_vivid`, `onedark_dark` and `vaporwave`. Add the name to `VARIANTS` in `scripts/extract.lua`, run `make`, and add the variant's expected values to `tests/variants.lua`.

## Licence

MIT. The colours and syntax mapping are from [onedarkpro.nvim](https://github.com/olimorris/onedarkpro.nvim) by Oli Morris, also MIT. Design decisions are recorded in [docs/adr](docs/adr); the project's vocabulary in [CONTEXT.md](CONTEXT.md); changes between releases in [CHANGELOG.md](CHANGELOG.md).
