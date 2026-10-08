-- Test runner: plain Lua assertions under headless nvim.
--
--   nvim --clean -l tests/run.lua
--
-- Loads every tests/*_test.lua, runs the cases they register with `test`,
-- and exits non-zero if any fail. Tests observe the project through its one
-- seam: the built Theme Family JSON (and the build command that produces it).

local root = (function()
  local script = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
  return vim.fs.dirname(vim.fs.dirname(script))
end)()
package.path = root .. "/scripts/?.lua;" .. root .. "/tests/?.lua;" .. package.path

local cases = {}
_G.test = function(name, fn)
  cases[#cases + 1] = { name = name, fn = fn }
end

local files = {}
for name, kind in vim.fs.dir(root .. "/tests") do
  if kind == "file" and name:match("_test%.lua$") then
    files[#files + 1] = name
  end
end
table.sort(files)
for _, file in ipairs(files) do
  dofile(root .. "/tests/" .. file)
end

local failed = 0
for _, case in ipairs(cases) do
  local ok, err = xpcall(case.fn, debug.traceback)
  if ok then
    print("ok   " .. case.name)
  else
    failed = failed + 1
    local detail = tostring(err):gsub("\n", "\n     ")
    print("FAIL " .. case.name .. "\n     " .. detail)
  end
end

print(string.format("\n%d tests, %d failed", #cases, failed))
if failed > 0 then
  os.exit(1)
end
