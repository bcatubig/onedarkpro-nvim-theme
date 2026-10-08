local M = {}

-- Repository root, derived from the calling script's own path so that the
-- scripts work from any working directory.
function M.root_of(script_source)
  local script = vim.fn.fnamemodify(script_source:sub(2), ":p")
  return vim.fs.dirname(vim.fs.dirname(script))
end

function M.read(path)
  local f = assert(io.open(path, "r"), "cannot read " .. path)
  local text = f:read("*a")
  f:close()
  return text
end

function M.write(path, text)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local f = assert(io.open(path, "w"), "cannot write " .. path)
  f:write(text)
  f:close()
end

-- Print a message to stderr and exit non-zero.
function M.fail(message)
  io.stderr:write(message .. "\n")
  os.exit(1)
end

-- The Upstream commit the submodule is checked out at.
function M.upstream_commit(root)
  local ok, result = pcall(function()
    return vim.system({ "git", "-C", root .. "/upstream", "rev-parse", "HEAD" }, { text = true }):wait()
  end)
  if not ok or result.code ~= 0 then
    M.fail("cannot read the Upstream submodule commit: " .. (ok and result.stderr or tostring(result)))
  end
  return vim.trim(result.stdout)
end

return M
