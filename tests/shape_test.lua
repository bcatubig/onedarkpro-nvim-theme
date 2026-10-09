-- Shape tests: the Theme Family has the names, appearance and schema Zed
-- expects, and every colour in it is well-formed.
local h = require("helpers")

test("Theme Family is named OneDarkPro and declares Zed's v0.2.0 theme schema", function()
  local family = h.theme_family()
  h.eq(family.name, "OneDarkPro", "family name")
  h.eq(family["$schema"], "https://zed.dev/schema/themes/v0.2.0.json", "schema")
end)

-- The Themes the Theme Family ships, in Theme order: Palette filename order,
-- which sorts the Variant names.
local THEMES_IN_ORDER = {
  { name = "OneDarkPro Onedark", appearance = "dark" },
  { name = "OneDarkPro Onedark Dark", appearance = "dark" },
  { name = "OneDarkPro Onedark Vivid", appearance = "dark" },
  { name = "OneDarkPro Onelight", appearance = "light" },
  { name = "OneDarkPro Vaporwave", appearance = "dark" },
}

test("Theme Family holds exactly five Themes in Palette filename order: Onedark, Onedark Dark, Onedark Vivid, Onelight, Vaporwave; only Onelight is light", function()
  local family = h.theme_family()
  h.eq(#family.themes, #THEMES_IN_ORDER, "number of Themes")
  for i, expected in ipairs(THEMES_IN_ORDER) do
    h.eq(family.themes[i].name, expected.name, string.format("themes[%d].name", i - 1))
    h.eq(family.themes[i].appearance, expected.appearance, string.format("themes[%d].appearance", i - 1))
  end
end)

-- One spelling across every Variant: Upstream writes some base colours in
-- uppercase hex (vaporwave's) and everything it computes in lowercase, and
-- stage one lowercases them all.
test("every colour in the Theme Family is well-formed lowercase hex, #rrggbb or #rrggbbaa", function()
  local count = 0
  h.each_colour(h.theme_family(), function(path, colour)
    count = count + 1
    assert(colour:match("^#[%da-f]+$") and (#colour == 7 or #colour == 9),
      path .. " has a malformed or uppercase colour " .. colour)
  end)
  assert(count > 0, "no colours found in the Theme Family")
end)

test("building twice produces a byte-identical Theme Family", function()
  local dir = h.tempdir()
  local first = h.run_build({ "--out", dir .. "/first.json" })
  local second = h.run_build({ "--out", dir .. "/second.json" })
  h.eq(first.code, 0, "first build exit code")
  h.eq(second.code, 0, "second build exit code")
  assert(h.read(dir .. "/first.json") == h.read(dir .. "/second.json"), "the two builds differ")
end)

test("the committed Theme Family is what the build produces", function()
  local dir = h.tempdir()
  local result = h.run_build({ "--out", dir .. "/fresh.json" })
  h.eq(result.code, 0, "build exit code")
  assert(h.read(dir .. "/fresh.json") == h.read(h.root .. "/themes/onedarkpro.json"),
    "themes/onedarkpro.json is stale; run make")
end)
