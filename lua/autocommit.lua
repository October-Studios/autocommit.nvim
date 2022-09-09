-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/autocommit.nvim
local config = require('autocommit.config')
local lib = require('autocommit.lib')
local signs = require('autocommit.lib.signs')
local hl = require('autocommit.lib.hl')
local status = require('autocommit.status')

local autocommit = {
  lib = require('autocommit.lib'),
  popups = require('autocommit.popups'),
  config = config,
  status = status,
  get_repo = function()
    return status.get_repo
  end,
  cli = lib.git.cli,
  get_log_file_path = function()
    return vim.fn.stdpath('cache') .. '/autocommit.log'
  end,
  notif = require('autocommit.lib.notification'),
  open = function(opts)
    opts = opts or {}
    if opts[1] ~= nil then
      local popup_name = opts[1]
      local has_pop, popup = pcall(require, 'autocommit.popups.' .. popup_name)

      if not has_pop then
        vim.api.nvim_err_writeln("Invalid popup '" .. popup_name .. "'")
      else
        popup.create()
      end
    else
      status.create(opts.kind, opts.cwd)
    end
  end,
  reset = status.reset,
  get_cofig = function()
    return config.values
  end,
  dispatch_reset = status.dispatch_reset,
  refresh = status.refresh,
  refresh_manually = status.refresh_manually,
  dispatch_refresh = status.dispatch_refresh,
  refresh_viml_compat = status.refresh_viml_compat,
  close = status.close,
  setup = function(opts)
    if opts ~= nil then
      config.values = vim.tbl_deep_extend('force', config.values, opts)
    end
    if not config.values.disable_signs then
      signs.setup()
    end
    if config.values.use_keybindings then
      config.values.mappings.status['F'] = 'PullPopup'
      config.values.mappings.status['p'] = ''
    end
    hl.setup()
  end,
  complete = function(arglead)
    if arglead:find('^kind=') then
      return { 'kind=replace', 'kind=tab', 'kind=split', 'kind=split_above', 'kind=vsplit', 'kind=floating' }
    end
    return vim.tbl_filter(function(arg)
      return arg:match('^' .. arglead)
    end, { 'kind=', 'cwd=', 'commit' })
  end,
}

autocommit.setup()

return autocommit
