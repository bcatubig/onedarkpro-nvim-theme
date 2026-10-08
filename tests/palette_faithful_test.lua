-- Palette-faithful: every colour in a Theme, alpha stripped, is a Palette
-- colour of its Variant, and the build refuses anything else.
local h = require("helpers")

local function colour_set(palette)
  local set = {}
  for _, group in ipairs({ palette.base, palette.derived, palette.bright }) do
    for _, colour in pairs(group) do
      set[colour:lower()] = true
    end
  end
  return set
end

test("every colour in OneDarkPro Onedark, alpha stripped, is in the onedark Palette", function()
  local theme = h.theme_family().themes[1]
  local palette = colour_set(h.palette("onedark"))
  local count = 0
  h.each_colour(theme.style, function(path, colour)
    count = count + 1
    assert(palette[colour:sub(1, 7):lower()], path .. " = " .. colour .. " is not in the onedark Palette")
  end)
  assert(count > 0, "no colours found in the Theme")
end)

test("build fails, naming the key and the colour, when the Mapping introduces a colour outside the Palette", function()
  local dir = h.tempdir()
  local mapping = dir .. "/mapping.lua"
  local f = assert(io.open(mapping, "w"))
  f:write([[
return {
  style = { { "Editor surface", "bg", { "editor.background" } } },
  syntax = { { "keyword", "#ff0000" } },
}
]])
  f:close()

  local result = h.run_build({ "--mapping", mapping, "--out", dir .. "/out.json" })

  assert(result.code ~= 0, "build exited 0 although the Mapping holds a colour outside the Palette")
  assert(result.stderr:find("syntax.keyword", 1, true), "stderr does not name the key:\n" .. result.stderr)
  assert(result.stderr:find("#ff0000", 1, true), "stderr does not name the colour:\n" .. result.stderr)
end)

test("build fails, naming the key, when a Chrome Rule grants alpha that is not two hex digits", function()
  local dir = h.tempdir()
  local mapping = dir .. "/mapping.lua"
  local f = assert(io.open(mapping, "w"))
  f:write([[
return {
  style = { { "Search match", { "highlight", alpha = "4" }, { "search.match_background" } } },
  syntax = {},
}
]])
  f:close()

  local result = h.run_build({ "--mapping", mapping, "--out", dir .. "/out.json" })

  assert(result.code ~= 0, "build exited 0 although the alpha is malformed")
  assert(result.stderr:find("search.match_background", 1, true), "stderr does not name the key:\n" .. result.stderr)
end)
