-- Shared helpers for the tests. Everything here reads the project's outputs
-- or runs its commands; nothing reaches into the scripts' internals.
local json = require("lib.json")
local util = require("lib.util")

local M = {}

M.read = util.read

M.root = util.root_of(debug.getinfo(1, "S").source)

-- A fresh empty directory for a test's scratch files.
function M.tempdir()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  return dir
end

-- The built Theme Family.
function M.theme_family(path)
  return json.decode(util.read(path or (M.root .. "/themes/onedarkpro.json")))
end

-- A committed Palette file.
function M.palette(variant)
  return json.decode(util.read(M.root .. "/palettes/" .. variant .. ".json"))
end

-- The Themes the Theme Family ships, each with its Variant, for tests that
-- run the same assertions against every Theme.
M.THEMES = {
  { name = "OneDarkPro Onedark", variant = "onedark" },
  { name = "OneDarkPro Onelight", variant = "onelight" },
}

-- The Theme named `name` in the built Theme Family.
function M.theme(name, path)
  for _, theme in ipairs(M.theme_family(path).themes) do
    if theme.name == name then
      return theme
    end
  end
  error("the Theme Family has no Theme named " .. name, 2)
end

function M.eq(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s: expected %s, got %s", label, vim.inspect(expected), vim.inspect(actual)), 2)
  end
end

-- Call fn(path, colour) for every colour string anywhere under `value`.
function M.each_colour(value, fn, path)
  path = path or ""
  if type(value) == "string" then
    if value:sub(1, 1) == "#" then
      fn(path, value)
    end
  elseif type(value) == "table" then
    for key, child in pairs(value) do
      local step = type(key) == "number" and ("[" .. key .. "]") or key
      M.each_colour(child, fn, path == "" and step or (path .. "." .. step))
    end
  end
end

-- Run the build command, under the same nvim that runs the tests, with extra
-- arguments; returns { code, stdout, stderr }.
function M.run_build(args)
  local cmd = { vim.v.progpath, "--clean", "-l", M.root .. "/scripts/build.lua" }
  vim.list_extend(cmd, args or {})
  return vim.system(cmd, { text = true }):wait()
end

return M
