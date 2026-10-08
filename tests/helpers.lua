-- Shared helpers for the tests. Everything here reads the project's outputs
-- or runs its commands; nothing reaches into the scripts' internals.
local json = require("lib.json")
local util = require("lib.util")

local M = {}

M.read = util.read

M.root = (function()
  local script = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
  return vim.fs.dirname(vim.fs.dirname(script))
end)()

-- The built Theme Family.
function M.theme_family(path)
  return json.decode(util.read(path or (M.root .. "/themes/onedarkpro.json")))
end

-- A committed Palette file.
function M.palette(variant)
  return json.decode(util.read(M.root .. "/palettes/" .. variant .. ".json"))
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

-- Run the build command with extra arguments; returns { code, stdout, stderr }.
function M.run_build(args)
  local cmd = { "nvim", "--clean", "-l", M.root .. "/scripts/build.lua" }
  vim.list_extend(cmd, args or {})
  return vim.system(cmd, { text = true }):wait()
end

return M
