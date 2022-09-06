-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/autocommit.nvim
local M = {}

local autocommit_require = require('autocommit_require')
local modules = autocommit_require.lazy_require {
  loader = 'autocommit.utils.loader',
  utils_updater = 'autocommit.utils.updater',
  utils = 'autocommit.utils.utils',
}
local timers = {
  main_timer = vim.loop.new_timer(),
  halt_main_refresh = false,
}

local refresh_real_curwin

local default_refresh_events = 'BufWritePost'

local function status_dispatch()
  return function()
    local retval
    local current_ft = refresh_real_curwin
        and vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(refresh_real_curwin), 'filetype')
      or vim.bo.filetype
    retval = handler()
    return retval
  end
end

local function refresh() end

local handler = modules.utils.retry_call_wrap(function()
  local diff_data = modules.utils_updater.update()
end)

local function setup()
  vim.cmd([[augroup autocommit | exec "autocmd!" | augroup END]])
  modules.loader.load_table('git')
  vim.loop.timer_stop(timers.main_timer)
  timers.halt_main_refresh = true
  vim.cmd([[augroup autocommit_main_refresh | exec "autocmd!" | augroup END]])
  vim.loop.timer_start(
    timers.main_timer,
    0,
    1000,
    modules.utils.timer_call(timers.main_timer, 'autocommit_main_refresh', function()
      refresh {}
    end, 3, 'autocommit: failed to refresh tabline')
  )
  modules.utils.define_autocmd(
    default_refresh_events,
    '*',
    "call v:lua.require'autocommit'.refresh()",
    'autocommit_main_refresh'
  )
end

M = {
  setup = setup,
  handler = status_dispatch(),
  refresh = refresh,
}

return M
