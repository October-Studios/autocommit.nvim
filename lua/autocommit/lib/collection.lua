-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local M = {}

function M.new(tbl)
  return setmetatable(tbl, { __index = M })
end

function M.key_by(tbl, key)
  local result = {}
  for _, item in ipairs(tbl) do
    result[item[key]] = item
  end

  return result
end

function M.map(tbl, func)
  local result = {}

  for _, item in ipairs(tbl) do
    table.insert(result, func(item))
  end

  return M(result)
end

function M.filter(tbl, func)
  local result = {}

  for _, item in ipairs(tbl) do
    if func(item) then
      table.insert(result, item)
    end
  end

  return M(result)
end

function M.each(tbl, func)
  for _, item in ipairs(tbl) do
    func(item)
  end
end

function M.reduce(tbl, func, ...)
  local acc = { ... }
  tbl:each(function(item)
    acc = { func(item, unpack(acc)) }
  end)
  return unpack(acc)
end

function M.find(tbl, func)
  for _, item in ipairs(tbl) do
    if func(item) then
      return item
    end
  end
  return nil
end

return setmetatable(M, {
  __call = function(_, tbl)
    return M.new(tbl)
  end,
})
