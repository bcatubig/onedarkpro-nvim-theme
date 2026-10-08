-- Shape tests: the Theme Family has the names, appearance and schema Zed
-- expects, and every colour in it is well-formed.
local h = require("helpers")

test("Theme Family is named OneDarkPro and declares Zed's v0.2.0 theme schema", function()
  local family = h.theme_family()
  h.eq(family.name, "OneDarkPro", "family name")
  h.eq(family["$schema"], "https://zed.dev/schema/themes/v0.2.0.json", "schema")
end)

test("Theme Family holds one Theme, OneDarkPro Onedark, with dark appearance", function()
  local family = h.theme_family()
  h.eq(#family.themes, 1, "number of Themes")
  h.eq(family.themes[1].name, "OneDarkPro Onedark", "Theme name")
  h.eq(family.themes[1].appearance, "dark", "appearance")
end)

test("every colour in the Theme Family is well-formed hex, #rrggbb or #rrggbbaa", function()
  local count = 0
  h.each_colour(h.theme_family(), function(path, colour)
    count = count + 1
    assert(colour:match("^#%x%x%x%x%x%x$") or colour:match("^#%x%x%x%x%x%x%x%x$"),
      path .. " has malformed colour " .. colour)
  end)
  assert(count > 0, "no colours found in the Theme Family")
end)

test("building twice produces a byte-identical Theme Family", function()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local first = h.run_build({ "--out", dir .. "/first.json" })
  local second = h.run_build({ "--out", dir .. "/second.json" })
  h.eq(first.code, 0, "first build exit code")
  h.eq(second.code, 0, "second build exit code")
  assert(h.read(dir .. "/first.json") == h.read(dir .. "/second.json"), "the two builds differ")
end)

test("the committed Theme Family is what the build produces", function()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  local result = h.run_build({ "--out", dir .. "/fresh.json" })
  h.eq(result.code, 0, "build exit code")
  assert(h.read(dir .. "/fresh.json") == h.read(h.root .. "/themes/onedarkpro.json"),
    "themes/onedarkpro.json is stale; run make")
end)
