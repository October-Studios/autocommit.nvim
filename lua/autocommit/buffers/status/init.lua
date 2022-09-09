-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local Buffer = require('autocommit.lib.buffer')
local ui = require('autocommit.buffers.status.ui')

local M = {}

function M.new(state)
  local x = {
    is_open = false,
    state = state,
    buffer = nil,
  }
  setmetatable(x, { __index = M })
  return x
end

function M:open(kind)
  kind = kind or 'tab'

  self.buffer = Buffer.create {
    name = 'AutocommitStatusNew',
    filetype = 'AutocommitStatusNew',
    kind = kind,
    initialize = function()
      self.prev_autochdir = vim.o.autochdir

      vim.o.autochdir = false
    end,
    render = function()
      return ui.Status(self.state)
    end,
  }
end

return M
