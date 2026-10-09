-- Oracle: how a sample looks in nvim and in Zed, and where the two differ.
--
-- Renders one file twice under this headless nvim and prints every run of
-- text whose colour differs:
--
--   nvim side: Upstream from the submodule plus the nvim-treesitter parsers
--              and queries installed for this user (stdpath("data")/site,
--              or $ORACLE_NVIM_SITE), with Upstream's after/queries, resolved
--              by nvim's own priority and dot-fallback rules.
--   Zed side:  Zed's highlights.scm for the language, run over the same tree
--              and resolved by Zed's rules through the built Theme Family's
--              Syntax Keys: captures stack in query order and the top wins,
--              so the innermost node decides, then the later pattern; a
--              capture with no Syntax Key is not pushed, so the enclosing one
--              shows; a capture name resolves to its longest dot-prefix Syntax
--              Key (Zed 1.23.2, crates/language/src/buffer.rs, BufferChunks).
--
-- The Zed queries are fetched with curl on first run into
-- scripts/dev/.zed-queries/<tag>/ (gitignored), pinned below. They are not
-- vendored: Zed's built-in queries are under Zed's GPL licence. The nvim side
-- reflects this machine's nvim-treesitter, so the output is a description of
-- the user's two editors, not a test; docs/sign-off.md was derived from it.
-- Not a build or test input.
--
--   nvim --clean -l scripts/dev/oracle.lua <file> <lang> [--all]
--
-- <lang> is the nvim parser: go, python, bash, yaml, markdown or terraform.
-- Injected languages (markdown_inline, the Go in a Markdown fence) are
-- handled. --all prints the agreeing runs too.

local script = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(script)))
package.path = root .. "/scripts/?.lua;" .. package.path
local json = require("lib.json")
local util = require("lib.util")

local ZED_TAG = "v1.23.2"
local TERRAFORM_REF = "99bcfa52db879b6f71b803307a9640e04e336623" -- zed-extensions/terraform main, 2026-10-09
local CACHE = root .. "/scripts/dev/.zed-queries/" .. ZED_TAG
local THEME = "OneDarkPro Onedark"
local COLORSCHEME = "onedark"

local file, lang = arg[1], arg[2]
local show_all = arg[3] == "--all"
if not file or not lang then
  util.fail("usage: nvim --clean -l scripts/dev/oracle.lua <file> <lang> [--all]")
end

local site = os.getenv("ORACLE_NVIM_SITE") or (vim.fn.stdpath("data") .. "/site")
vim.opt.rtp:prepend(site) -- nvim-treesitter's parsers and queries
vim.opt.rtp:prepend(root .. "/upstream")
vim.opt.rtp:append(root .. "/upstream/after") -- Upstream's `; extends` queries, after the base ones

require("onedarkpro").setup({ options = { transparency = false, cursorline = true } })
vim.cmd.colorscheme(COLORSCHEME)

-- Zed's query for an nvim parser language, fetched on first use.
local ZED_QUERY = {
  go = "go", python = "python", bash = "bash", yaml = "yaml", markdown = "markdown",
  markdown_inline = "markdown-inline", terraform = "terraform", hcl = "terraform",
}
local function zed_query_text(name)
  local path = CACHE .. "/" .. name .. ".scm"
  if vim.fn.filereadable(path) == 0 then
    local url
    if name == "terraform" then
      url = "https://raw.githubusercontent.com/zed-extensions/terraform/" .. TERRAFORM_REF .. "/languages/terraform/highlights.scm"
    else
      url = "https://raw.githubusercontent.com/zed-industries/zed/" .. ZED_TAG .. "/crates/grammars/src/" .. name .. "/highlights.scm"
    end
    vim.fn.mkdir(CACHE, "p")
    local result = vim.system({ "curl", "-fsSL", url, "-o", path }, { text = true }):wait()
    if result.code ~= 0 then
      util.fail("cannot fetch " .. url .. ": " .. result.stderr)
    end
    io.stderr:write("fetched " .. url .. "\n")
  end
  return util.read(path)
end

-- Palette: hex -> name, preferring fg and bg over white and black.
local palette = json.decode(util.read(root .. "/palettes/" .. COLORSCHEME .. ".json"))
local hex2name = {}
for _, name in ipairs({ "fg", "bg" }) do hex2name[palette.base[name]:lower()] = name end
for _, group in ipairs({ palette.base, palette.derived, palette.bright }) do
  for name, hex in pairs(group) do
    if not hex2name[hex:lower()] then hex2name[hex:lower()] = name end
  end
end
local function pname(hex)
  if not hex or hex == "" then return "fg" end
  return hex2name[hex:lower()] or hex
end

-- The Theme's Syntax Keys, and Zed's longest-dot-prefix resolution.
local syntax
for _, t in ipairs(json.decode(util.read(root .. "/themes/onedarkpro.json")).themes) do
  if t.name == THEME then syntax = t.style.syntax end
end
assert(syntax, "the Theme Family has no Theme named " .. THEME)
local function zed_resolve(capture)
  local key = capture
  while key do
    local s = syntax[key]
    if s then
      return pname(s.color) .. (s.font_weight == 700 and " bold" or "") .. (s.font_style == "italic" and " italic" or ""), key
    end
    key = key:match("^(.+)%.[^.]+$")
  end
  return "fg", "(undefined)"
end

vim.cmd.edit(file)
local buf = vim.api.nvim_get_current_buf()
local parser = vim.treesitter.get_parser(buf, lang)
parser:parse(true)

-- nvim's resolution of a capture: link following and @a.b.c -> @a.b fallback.
local hl_cache = {}
local function nvim_hl(name)
  if hl_cache[name] == nil then
    local final = vim.fn.synIDtrans(vim.api.nvim_get_hl_id_by_name(name))
    local fg = vim.fn.synIDattr(final, "fg#")
    hl_cache[name] = {
      fg = fg ~= "" and fg or nil,
      bold = vim.fn.synIDattr(final, "bold") == "1",
      italic = vim.fn.synIDattr(final, "italic") == "1",
      final = vim.fn.synIDattr(final, "name"),
    }
  end
  return hl_cache[name]
end

local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
local nvim_caps, zed_caps = {}, {} -- captures bucketed by row
for r = 1, #lines do nvim_caps[r], zed_caps[r] = {}, {} end
local function bucket(t, cap)
  for r = cap.srow, cap.erow do
    if t[r + 1] then table.insert(t[r + 1], cap) end
  end
end

local order = 0
parser:for_each_tree(function(tree, ltree)
  local tlang = ltree:lang()
  local tree_root = tree:root()
  local q = vim.treesitter.query.get(tlang, "highlights")
  if q then
    for id, node, metadata in q:iter_captures(tree_root, buf, 0, -1) do
      local srow, scol, erow, ecol = node:range()
      order = order + 1
      local prio = tonumber((metadata[id] and metadata[id].priority) or metadata.priority) or 100
      bucket(nvim_caps, { srow = srow, scol = scol, erow = erow, ecol = ecol, name = q.captures[id], lang = tlang, prio = prio, order = order })
    end
  end
  local zq = ZED_QUERY[tlang]
  if not zq then
    print("(no Zed query for injected language " .. tlang .. ")")
    return
  end
  local ok, zquery = pcall(vim.treesitter.query.parse, tlang, zed_query_text(zq))
  if not ok then
    print("Zed query for " .. tlang .. " does not parse against this nvim parser: " .. tostring(zquery))
    return
  end
  for id, node, _, match in zquery:iter_captures(tree_root, buf, 0, -1) do
    local name = zquery.captures[id]
    if not name:match("^_") then
      local srow, scol, erow, ecol = node:range()
      local _, _, sbyte = node:start()
      local _, _, ebyte = node:end_()
      -- match:info() returns the match id first and the pattern index second.
      local pattern = match and select(2, match:info()) or 0
      bucket(zed_caps, { srow = srow, scol = scol, erow = erow, ecol = ecol, name = name, lang = tlang, size = ebyte - sbyte, pattern = pattern })
    end
  end
end)

local function covers(cap, row, col)
  if row < cap.srow or row > cap.erow then return false end
  if row == cap.srow and col < cap.scol then return false end
  if row == cap.erow and col >= cap.ecol then return false end
  return true
end

-- nvim applies captures in priority order, later ones on top; a capture with
-- no fg leaves the fg beneath it.
local function nvim_at(row, col)
  local cands = {}
  for _, cap in ipairs(nvim_caps[row + 1]) do
    if covers(cap, row, col) then cands[#cands + 1] = cap end
  end
  table.sort(cands, function(a, b)
    if a.prio ~= b.prio then return a.prio < b.prio end
    return a.order < b.order
  end)
  local fg, bold, italic, why = nil, false, false, {}
  for _, cap in ipairs(cands) do
    local hl = nvim_hl("@" .. cap.name .. "." .. cap.lang)
    if hl.fg then fg = hl.fg; why = { cap.name, hl.final } end
    if hl.bold then bold = true end
    if hl.italic then italic = true end
  end
  return pname(fg) .. (bold and " bold" or "") .. (italic and " italic" or ""), why[1] or "-", why[2] or "-"
end

-- Zed: innermost node, then the later pattern; unmapped captures are skipped.
local function zed_at(row, col)
  local cands = {}
  for _, cap in ipairs(zed_caps[row + 1]) do
    if covers(cap, row, col) then cands[#cands + 1] = cap end
  end
  table.sort(cands, function(a, b)
    if a.size ~= b.size then return a.size < b.size end
    return a.pattern > b.pattern
  end)
  for _, cap in ipairs(cands) do
    local colour, key = zed_resolve(cap.name)
    if key ~= "(undefined)" then return colour, cap.name, key end
  end
  if cands[1] then return "fg", cands[1].name, "(undefined)" end
  return "fg", "-", "-"
end

local diffs, total = 0, 0
for r, line in ipairs(lines) do
  local row = r - 1
  local runs = {}
  local col = 0
  while col < #line do
    local b = line:byte(col + 1)
    local n, z, ncap, nfinal, zcap, zkey
    if b ~= 32 and b ~= 9 then
      n, ncap, nfinal = nvim_at(row, col)
      z, zcap, zkey = zed_at(row, col)
    end
    local key = n and (n .. "|" .. z .. "|" .. (ncap or "") .. "|" .. (zcap or "")) or " "
    local last = runs[#runs]
    if last and last.key == key then
      last.e = col + 1
    else
      runs[#runs + 1] = { key = key, s = col, e = col + 1, n = n, z = z, ncap = ncap, nfinal = nfinal, zcap = zcap, zkey = zkey }
    end
    local step = 1 -- advance one UTF-8 character
    if b >= 0xF0 then step = 4 elseif b >= 0xE0 then step = 3 elseif b >= 0xC0 then step = 2 end
    col = col + step
  end
  local out = {}
  for _, run in ipairs(runs) do
    if run.n then
      total = total + 1
      local same = run.n == run.z
      if not same then diffs = diffs + 1 end
      if show_all or not same then
        out[#out + 1] = string.format("  %s %-28s nvim=%-16s (%s -> %s)  zed=%-16s (%s -> %s)",
          same and "  " or "!!", string.format("%q", line:sub(run.s + 1, run.e)), run.n, run.ncap, run.nfinal, run.z, run.zcap, run.zkey)
      end
    end
  end
  if #out > 0 then
    print(string.format("%3d: %s", r, line))
    for _, o in ipairs(out) do print(o) end
  end
end
print(string.format("\n%s: %d runs, %d differ", file:match("[^/]+$"), total, diffs))
