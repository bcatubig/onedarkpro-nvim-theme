# Derived Colours by running Upstream's code under nvim

Upstream computes its Derived Colours (cursorline, selection, float_bg, the git and diff tints, the virtual text colours) in Lua with its own lighten, darken and blend functions. We considered porting that colour maths into the build, or hand-copying the resulting hex values, and chose instead to run Upstream itself: a headless nvim loads the pinned submodule, asks it for a Variant's Palette, and writes it to a committed Palette file. Nothing is reimplemented, so there is no rounding drift, and bumping the submodule regenerates every Derived Colour exactly as nvim will show it.

## Consequences

- nvim is a build-time dependency. Zed users need nothing extra: the Palette files and the Theme Family are committed.
- The build reads only the submodule, and each Palette file records the Upstream commit it came from.
