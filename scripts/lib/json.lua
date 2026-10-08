-- Ordered JSON encoding. Objects keep insertion order so that regenerating a
-- file with unchanged inputs is byte-identical. Plain Lua tables are encoded
-- as arrays; maps must be built with `object()` so their key order is explicit.
local M = {}

local Object = {}
Object.__index = Object

function M.object()
  return setmetatable({ keys = {}, present = {}, values = {} }, Object)
end

function M.is_object(value)
  return getmetatable(value) == Object
end

function Object:set(key, value)
  if not self.present[key] then
    self.keys[#self.keys + 1] = key
    self.present[key] = true
  end
  self.values[key] = value
  return self
end

local escapes = { ['"'] = '\\"', ["\\"] = "\\\\", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }

local function quote(s)
  local escaped = s:gsub('[%c"\\]', function(c)
    return escapes[c] or string.format("\\u%04x", c:byte())
  end)
  return '"' .. escaped .. '"'
end

local function encode(value, depth, out)
  local kind = type(value)
  local pad = string.rep("  ", depth + 1)
  local close = string.rep("  ", depth)
  if value == nil or value == vim.NIL then
    out[#out + 1] = "null"
  elseif kind == "boolean" then
    out[#out + 1] = tostring(value)
  elseif kind == "number" then
    out[#out + 1] = string.format("%.14g", value)
  elseif kind == "string" then
    out[#out + 1] = quote(value)
  elseif M.is_object(value) then
    if #value.keys == 0 then
      out[#out + 1] = "{}"
      return
    end
    out[#out + 1] = "{\n"
    for i, key in ipairs(value.keys) do
      out[#out + 1] = pad .. quote(key) .. ": "
      encode(value.values[key], depth + 1, out)
      out[#out + 1] = i < #value.keys and ",\n" or "\n"
    end
    out[#out + 1] = close .. "}"
  elseif kind == "table" then
    if next(value) ~= nil and #value == 0 then
      error("json: plain map tables have no key order; build them with json.object()")
    end
    if #value == 0 then
      out[#out + 1] = "[]"
      return
    end
    out[#out + 1] = "[\n"
    for i, item in ipairs(value) do
      out[#out + 1] = pad
      encode(item, depth + 1, out)
      out[#out + 1] = i < #value and ",\n" or "\n"
    end
    out[#out + 1] = close .. "]"
  else
    error("json: cannot encode a " .. kind)
  end
end

function M.encode(value)
  local out = {}
  encode(value, 0, out)
  return table.concat(out) .. "\n"
end

-- Reading does not need key order; nvim's decoder is fine.
function M.decode(text)
  return vim.json.decode(text)
end

return M
