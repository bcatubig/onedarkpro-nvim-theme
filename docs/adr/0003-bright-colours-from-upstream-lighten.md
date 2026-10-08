# Bright Colours by calling Upstream's lighten helper with its export recipe

Upstream's terminal exports add the Bright Colours in `add_bright_colors`, a function local to its extra module, so stage one cannot ask Upstream for them the way it asks for the Derived Colours (ADR-0002). We considered running Upstream's export generator and parsing what it writes, which puts fourteen exports per Variant into nvim's cache directory for a handful of colours; reading the Bright Colours off Upstream's committed ghostty export, which would leave the terminal oracle test comparing that export with itself; and porting `lighten`, which ADR-0002 rules out. We chose to repeat the export's recipe, the ten base colours and the amount 10, as calls to Upstream's own `lighten`, so the colour maths stays Upstream's and only the recipe lives here. The Bright Colours are a third group of the Palette file, beside the base colours and the Derived Colours, so the file shows which of Upstream's code each colour came from.

## Consequences

- The recipe can drift from Upstream's without a build failure. The terminal oracle test, which reads Upstream's committed ghostty export from the submodule, fails on any such drift at the next `make`.
- Upstream's `bright_fg`, which lightens yellow by mistake, is not emitted. nvim's built-in terminal brightens by a different algorithm (`brighten` by 15) and is not used, because the user's terminals take the exports.
