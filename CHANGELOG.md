# Changelog

All notable changes to this extension. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- **OneDarkPro Onedark Dark**, **OneDarkPro Onedark Vivid** and **OneDarkPro Vaporwave** themes, all dark, built from the plugin's three remaining colourschemes by the same rules as the first two. On Onedark Dark's black background the plugin's own derived colours put popups and pickers flush with the editor, edged by a hairline border, and lift the status bar, tab bar and panels a shade above the editor instead of below it.

## [0.1.1] - 2026-10-09

### Changed

- Project panel indent guides are quieter. They take the panel's border colour (`#3d4350` on Onedark, `#e1e1e1` on Onelight) instead of gray, and a hovered guide brightens to gray. Zed draws these guides as solid full-height lines, so the plugin's tree-marker gray read louder than it does in nvim. ([#21](https://github.com/bcatubig/onedarkpro-nvim-theme/pull/21))

## [0.1.0] - 2026-10-09

First release, generated from [onedarkpro.nvim](https://github.com/olimorris/onedarkpro.nvim) at 24c806c.

### Added

- **OneDarkPro Onedark** (dark) and **OneDarkPro Onelight** (light) themes.
- Syntax colours from the plugin's treesitter and LSP highlight groups, checked against nvim on Go, Terraform, YAML, Python, shell, Markdown, Lua, JSON and TOML samples.
- UI colours drawn only from the plugin's palette: tabs, panels, status bar, popups, selections, diagnostics, git status, diff hunks and the vim mode indicator. The project panel sits on the same darker surface as the tab and status bars.
- Terminal colours matching the plugin's ghostty, kitty and wezterm exports slot for slot.
- Known differences from nvim listed in `docs/sign-off.md`, with sample files for comparing the two editors.

[Unreleased]: https://github.com/bcatubig/onedarkpro-nvim-theme/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/bcatubig/onedarkpro-nvim-theme/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bcatubig/onedarkpro-nvim-theme/releases/tag/v0.1.0
