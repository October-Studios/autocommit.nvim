-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local autocommit_require = require('autocommit_require')
local modules = autocommit_require.lazy_require {
  file_diff = 'autocommit.git.file_diff',
  utils = 'autocommit.utils.utils',
}
local M = autocommit_require.require('autocommit.component'):extend()

function M:init()
  M.super.init(self)
  modules.file_diff.init()
end

function M:update_status()
  local file_diff = modules.file_diff.get_sign_count((vim.api.nvim_get_current_buf()))
  if file_diff == nil then
    return ''
  end

  return ''
end

return M
