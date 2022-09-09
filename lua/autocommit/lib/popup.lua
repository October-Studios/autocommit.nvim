local PopupBuilder = require('autocommit.lib.popup.builder')
local Buffer = require('autocommit.lib.buffer')
local common = require('autocommit.buffers.common')
local Ui = require('autocommit.lib.ui')
local logger = require('autocommit.logger')
local config = require('autocommit.config')

local col = Ui.col
local row = Ui.row
local text = Ui.text
local Component = Ui.Component
local List = common.List
local Grid = common.Grid

local M = {}

function M.builder()
  return PopupBuilder.new(M.new)
end

function M.new(state)
  local instance = {
    state = state,
    buffer = nil,
  }
  setmetatable(instance, { __index = M })
  return instance
end

function M:get_parse_arguments()
  local switches = {}
  for _, switch in pairs(self.state.switches) do
    if switch.enabled and switch.parse then
      switches[switch.cli] = switch.enabled
    end
  end
  return switches
end

function M:close()
  self.buffer:close()
  self.buffer = nil
end

local Actions = Component.new(function(props)
  return col {
    text.highlight('AutocommitPopupSectionTitle')('Confirmation'),
    Grid.padding_left(1) {
      items = props.state,
      gap = 1,
      render_item = function(item)
        if not item.callback then
          return row.highlight('AutocommitPopupActionDisabled') {
            text(item.key),
            text(' '),
            text(item.description),
          }
        end

        return row {
          text.highlight('AutocommitPopupActionKey')(item.key),
          text(' '),
          text(item.description),
        }
      end,
    },
  }
end)

function M:show()
  local mappings = {
    n = {
      ['q'] = function()
        self:close()
      end,
      ['<esc>'] = function()
        self:close()
      end,
      ['n'] = function()
        self:close()
      end,
    },
  }

  for _, group in pairs(self.state.actions) do
    for _, action in pairs(group) do
      if action.callback then
        mappings.n[action.key] = function()
          logger.debug(string.format("[POPUP]: Invoking action '%s' of %s", action.key, self.state.name))
          local ret = action.callback(self)
          self:close()
          if type(ret) == 'function' then
            ret()
          end
        end
      else
        mappings.n[action.key] = function()
          local notif = require('autocommit.lib.notification')
          notif.create(action.description .. ' has not been implemented yet', vim.log.levels.WARN)
        end
      end
    end
  end

  self.buffer = Buffer.create {
    name = self.state.name,
    filetype = 'AutocommitPopup',
    kind = config.values.popup.kind,
    mappings = mappings,
    render = function()
      return {
        List {
          separator = '',
          items = {
            Actions { state = self.state.actions },
          },
        },
      }
    end,
  }
end

M.deprecated_create = require('autocommit.lib.popup.lib').create

return M
