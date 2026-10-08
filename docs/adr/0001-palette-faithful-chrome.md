# Palette-faithful Chrome by written rules, not borrowed from Zed One Dark

Zed's own One Dark theme (`assets/themes/one/one.json` in the Zed repository) shares an ancestor with Upstream and would have been a quick source for the Chrome: the Style Keys with no Highlight Group counterpart. Its colours, though, are not in Upstream's Palette and were never computed from it. We decided that every Chrome colour is a Palette colour of its Variant, alpha permitted, chosen by rules written down in the Mapping, and that the build enforces this: a colour outside the Palette fails the build and names the key. The rules apply to any Variant's Palette, so each Variant gets consistent Chrome without a second design pass, and the whole Theme stays recognisably Upstream's rather than a blend of two theme lineages.

## Consequences

- Some Zed surfaces will not match Zed One Dark's look. Tints come from alpha over Palette colours, never from new hex values.
- A Chrome colour that looks wrong is fixed by changing a rule, not by adding a colour.
