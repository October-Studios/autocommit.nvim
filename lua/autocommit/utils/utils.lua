-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details
local M = {}

local function autocmd_is_defined(event, pattern, command_str)
  return vim.api.nvim_exec(string.format('au autocommit %s %s', event, pattern), true):find(command_str) ~= nil
end

function M.define_autocmd(event, pattern, cmd, group)
  if not cmd then
    cmd = pattern
    pattern = '*'
  end
  if not autocmd_is_defined(event, pattern, cmd) then
    vim.cmd(string.format('autocmd %s %s %s %s', group or 'autocommit', event, pattern, cmd))
  end
end

function M.is_focused()
  return tonumber(vim.g.actual_curwin) == vim.api.nvim_get_current_win()
end

local function cycle_aware_copy(t, cache)
  if type(t) ~= 'table' then
    return t
  end
  if cache[t] then
    return cache[t]
  end
  local res = {}
  cache[t] = res
  local mt = getmetatable(t)
  for k, v in pairs(t) do
    k = cycle_aware_copy(k, cache)
    v = cycle_aware_copy(v, cache)
    res[k] = v
  end
  setmetatable(res, mt)
  return res
end

function M.deepcopy(t)
  return cycle_aware_copy(t, {})
end

function M.is_component(comp)
  if type(comp) ~= 'table' then
    return false
  end
  local mt = getmetatable(comp)
  return mt and mt.__is_autocommit_component == true
end

function M.retry_call(fn)
  return fn(unpack())
end

-- luacheck: push no unused args
function M.retry_call_wrap(fn)
  return function(...)
    return M.retry_call(fn)
  end
end
-- luacheck: pop

function M.stl_escape(str)
  if type(str) ~= 'string' then
    return str
  end
  return str:gsub('%%', '%%%%')
end

function M.timer_call(timer, augroup, fn, max_err, err_msg)
  local err_cnt, ret = 0, nil
  max_err = max_err or 3
  return vim.schedule_wrap(function(...)
    if err_cnt > max_err then
      vim.loop.timer_stop(timer)
      if augroup then
        vim.cmd(string.format([[augroup %s | exe "autocmd!" | augroup END]], augroup))
      end
      error(err_msg .. ':\n' .. tostring(ret))
    end
    local ok
    ok, ret = pcall(fn, ...)
    if ok then
      err_cnt = 0
    else
      err_cnt = err_cnt + 1
    end
    return ret
  end)
end

return M
