-- Oracle: how a sample looks in nvim and in Zed, and where the two differ.
--
-- Renders one file twice under this headless nvim and prints every run of
-- text whose colour differs:
--
--   nvim side: Upstream from the submodule plus the nvim-treesitter parsers
--              and queries installed for this user (stdpath("data")/site),
--              with Upstream's after/queries, resolved by nvim's own priority
--              and dot-fallback rules.
--   Zed side:  Zed's highlights.scm for the language, run over the same tree
--              and resolved by Zed's rules through the built Theme Family's
--              Syntax Keys: captures stack in query order and the top wins,
--              so the innermost node decides, then the later pattern; a
--              capture with no Syntax Key is not pushed, so the enclosing one
--              shows; a capture name resolves to its longest dot-prefix Syntax
--              Key (Zed 1.23.2, crates/language/src/buffer.rs, BufferChunks).
--
-- The Zed queries are fetched with curl on first run into
-- scripts/dev/.zed-queries/ (gitignored), one directory per pinned source:
-- Zed's built-in queries, which are under Zed's GPL licence and so are not
-- vendored here, and the Terraform extension's, Apache-2.0, pinned to a
-- commit of its own. The nvim side reflects this machine's nvim-treesitter,
-- so the output describes the user's two editors; it is not a test.
-- docs/sign-off.md was derived from it. Not a build or test input.
--
--   nvim --clean -l scripts/dev/oracle.lua <file> <lang> [--all]
--
-- <lang> is the nvim parser: go, python, bash, yaml, markdown or terraform.
-- Injected languages (markdown_inline, the Go in a Markdown fence) are
-- handled when a Zed query is known for them. --all prints the agreeing
-- runs too.

local script = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
local root = vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(script)))
package.path = root .. "/scripts/?.lua;" .. package.path
local json = require("lib.json")
local util = require("lib.util")

local USAGE = "usage: nvim --clean -l scripts/dev/oracle.lua <file> <lang> [--all]"
local VARIANT = "onedark" -- the Theme resolved through; both Themes share the Mapping
local THEME = "OneDarkPro Onedark"
local ZED_TAG = "v1.23.2"
local TERRAFORM_REF = "99bcfa52db879b6f71b803307a9640e04e336623" -- zed-extensions/terraform main, 2026-10-09
local CACHE = root .. "/scripts/dev/.zed-queries"

-- Zed's query for each nvim parser language: where to fetch it, and where
-- it is cached, keyed by the pin so that bumping a pin refetches.
local function zed_builtin(name)
  return {
    url = "https://raw.githubusercontent.com/zed-industries/zed/" .. ZED_TAG .. "/crates/grammars/src/" .. name .. "/highlights.scm",
    path = CACHE .. "/zed-" .. ZED_TAG .. "/" .. name .. ".scm",
  }
end
local ZED_QUERY = {
  go = zed_builtin("go"),
  python = zed_builtin("python"),
  bash = zed_builtin("bash"),
  yaml = zed_builtin("yaml"),
  markdown = zed_builtin("markdown"),
  markdown_inline = zed_builtin("markdown-inline"),
  terraform = {
    url = "https://raw.githubusercontent.com/zed-extensions/terraform/" .. TERRAFORM_REF .. "/languages/terraform/highlights.scm",
    path = CACHE .. "/terraform-" .. TERRAFORM_REF:sub(1, 7) .. "/terraform.scm",
  },
}

local file, lang = arg[1], arg[2]
local show_all = false
for i = 3, #arg do
  if arg[i] == "--all" then
    show_all = true
  else
    util.fail(USAGE)
  end
end
if not file or not lang then
  util.fail(USAGE)
end

vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site") -- nvim-treesitter's parsers and queries
vim.opt.rtp:prepend(root .. "/upstream")
vim.opt.rtp:append(root .. "/upstream/after") -- Upstream's `; extends` queries, after the base ones

require("onedarkpro").setup({ options = { transparency = false, cursorline = true } })
vim.cmd.colorscheme(VARIANT)

-- The text of Zed's query for `tlang`, fetched on first use. A download is
-- written beside its final name and renamed only when curl succeeds, so a
-- failed one is not mistaken for a cached query next time.
local function zed_query_text(tlang)
  local source = ZED_QUERY[tlang]
  if vim.fn.filereadable(source.path) == 0 then
    vim.fn.mkdir(vim.fs.dirname(source.path), "p")
    local partial = source.path .. ".part"
    local ok, result = pcall(function()
      return vim.system({ "curl", "-fsSL", source.url, "-o", partial }, { text = true }):wait()
    end)
    if not ok then
      util.fail("cannot run curl to fetch " .. source.url .. ": " .. tostring(result))
    end
    if result.code ~= 0 then
      os.remove(partial)
      util.fail("cannot fetch " .. source.url .. ": " .. result.stderr)
    end
    os.rename(partial, source.path)
    io.stderr:write("fetched " .. source.url .. "\n")
  end
  return util.read(source.path)
end

-- Palette: hex -> name, preferring fg and bg over white and black, which
-- share their values in onedark.
local palette = json.decode(util.read(root .. "/palettes/" .. VARIANT .. ".json"))
local hex_to_name = {}
for _, name in ipairs({ "fg", "bg" }) do hex_to_name[palette.base[name]:lower()] = name end
for _, group in ipairs({ palette.base, palette.derived, palette.bright }) do
  for name, hex in pairs(group) do
    if not hex_to_name[hex:lower()] then hex_to_name[hex:lower()] = name end
  end
end
local function palette_name(hex)
  if not hex or hex == "" then return "fg" end
  return hex_to_name[hex:lower()] or hex
end

local function describe(colour_name, bold, italic)
  return colour_name .. (bold and " bold" or "") .. (italic and " italic" or "")
end

-- The Theme's Syntax Keys, and Zed's longest-dot-prefix resolution of a
-- capture name to one of them.
local syntax
for _, theme in ipairs(json.decode(util.read(root .. "/themes/onedarkpro.json")).themes) do
  if theme.name == THEME then syntax = theme.style.syntax end
end
if not syntax then
  util.fail("the Theme Family has no Theme named " .. THEME)
end
local function zed_resolve(capture)
  local key = capture
  while key do
    local style = syntax[key]
    if style then
      return describe(palette_name(style.color), style.font_weight == 700, style.font_style == "italic"), key
    end
    key = key:match("^(.+)%.[^.]+$")
  end
  return nil
end

vim.cmd.edit(file)
local buf = vim.api.nvim_get_current_buf()
local ok, parser = pcall(vim.treesitter.get_parser, buf, lang)
if not ok then
  util.fail("no nvim parser for " .. lang .. ": " .. tostring(parser))
end
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
      group = vim.fn.synIDattr(final, "name"),
    }
  end
  return hl_cache[name]
end

-- Captures of both sides, bucketed by row. A capture records its range, its
-- name and language, and what decides precedence on its side: nvim's
-- priority and application order, Zed's node size and pattern index.
local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
local nvim_caps, zed_caps = {}, {}
for r = 1, #lines do nvim_caps[r], zed_caps[r] = {}, {} end
local function bucket(buckets, cap)
  for r = cap.srow, cap.erow do
    if buckets[r + 1] then table.insert(buckets[r + 1], cap) end
  end
end

local order = 0
parser:for_each_tree(function(tree, ltree)
  local tlang = ltree:lang()
  if not ZED_QUERY[tlang] then
    print("(skipping injected language " .. tlang .. ": no Zed query known for it)")
    return
  end
  local tree_root = tree:root()
  local nvim_query = vim.treesitter.query.get(tlang, "highlights")
  if nvim_query then
    for id, node, metadata in nvim_query:iter_captures(tree_root, buf, 0, -1) do
      local srow, scol, erow, ecol = node:range()
      order = order + 1
      local prio = tonumber((metadata[id] and metadata[id].priority) or metadata.priority) or 100
      bucket(nvim_caps, { srow = srow, scol = scol, erow = erow, ecol = ecol, name = nvim_query.captures[id], lang = tlang, prio = prio, order = order })
    end
  end
  local parsed, zed_query = pcall(vim.treesitter.query.parse, tlang, zed_query_text(tlang))
  if not parsed then
    util.fail("Zed's " .. tlang .. " query does not parse against this nvim parser: " .. tostring(zed_query))
  end
  for id, node, _, match in zed_query:iter_captures(tree_root, buf, 0, -1) do
    local name = zed_query.captures[id]
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

-- The captures covering a position, in the order the side applies them.
local function covering(buckets, row, col, before)
  local caps = {}
  for _, cap in ipairs(buckets[row + 1]) do
    if covers(cap, row, col) then caps[#caps + 1] = cap end
  end
  table.sort(caps, before)
  return caps
end

-- Both sides answer with a Rendering: the colour as shown (a Palette name
-- plus bold/italic), the capture that decided it, and what it resolved to.
local function rendering(colour, capture, resolved)
  return { colour = colour, capture = capture or "-", resolved = resolved or "-" }
end

-- nvim applies captures in priority order, later ones on top; a capture with
-- no fg leaves the fg beneath it, so bold and italic accumulate.
local function nvim_at(row, col)
  local caps = covering(nvim_caps, row, col, function(a, b)
    if a.prio ~= b.prio then return a.prio < b.prio end
    return a.order < b.order
  end)
  local fg, bold, italic, decider = nil, false, false, nil
  for _, cap in ipairs(caps) do
    local hl = nvim_hl("@" .. cap.name .. "." .. cap.lang)
    if hl.fg then fg = hl.fg; decider = { capture = cap.name, group = hl.group } end
    if hl.bold then bold = true end
    if hl.italic then italic = true end
  end
  return rendering(describe(palette_name(fg), bold, italic), decider and decider.capture, decider and decider.group)
end

-- Zed: the innermost node (smallest span; equal spans fall to the pattern
-- order), then the later pattern; a capture with no Syntax Key is skipped.
local function zed_at(row, col)
  local caps = covering(zed_caps, row, col, function(a, b)
    if a.size ~= b.size then return a.size < b.size end
    return a.pattern > b.pattern
  end)
  for _, cap in ipairs(caps) do
    local colour, key = zed_resolve(cap.name)
    if colour then return rendering(colour, cap.name, key) end
  end
  return rendering("fg", caps[1] and caps[1].name, caps[1] and "(no Syntax Key)")
end

local function is_blank(byte)
  return byte == 32 or byte == 9
end

local function utf8_step(byte)
  if byte >= 0xF0 then return 4 elseif byte >= 0xE0 then return 3 elseif byte >= 0xC0 then return 2 end
  return 1
end

local function format_side(r)
  return string.format("%-16s (%s -> %s)", r.colour, r.capture, r.resolved)
end

local diffs, total = 0, 0
for r, line in ipairs(lines) do
  local row = r - 1
  -- Runs: consecutive non-blank characters with the same Rendering on both sides.
  local runs = {}
  local col = 0
  while col < #line do
    local byte = line:byte(col + 1)
    local step = utf8_step(byte)
    local nvim_r, zed_r, signature
    if is_blank(byte) then
      signature = " "
    else
      nvim_r, zed_r = nvim_at(row, col), zed_at(row, col)
      signature = table.concat({ nvim_r.colour, nvim_r.capture, zed_r.colour, zed_r.capture }, "|")
    end
    local last = runs[#runs]
    if last and last.signature == signature then
      last.e = col + step
    else
      runs[#runs + 1] = { signature = signature, s = col, e = col + step, nvim = nvim_r, zed = zed_r }
    end
    col = col + step
  end
  local out = {}
  for _, run in ipairs(runs) do
    if run.nvim then
      total = total + 1
      local same = run.nvim.colour == run.zed.colour
      if not same then diffs = diffs + 1 end
      if show_all or not same then
        out[#out + 1] = string.format("  %s %-28s nvim=%s  zed=%s",
          same and "  " or "!!", string.format("%q", line:sub(run.s + 1, run.e)), format_side(run.nvim), format_side(run.zed))
      end
    end
  end
  if #out > 0 then
    print(string.format("%3d: %s", r, line))
    for _, o in ipairs(out) do print(o) end
  end
end
print(string.format("\n%s: %d runs, %d differ", file:match("[^/]+$"), total, diffs))
