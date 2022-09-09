-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local Ui = require('autocommit.lib.ui')
local Component = require('autocommit.lib.ui.component')
local util = require('autocommit.lib.util')
local common = require('autocommit.buffers.common')

local col = Ui.col
local row = Ui.row
local text = Ui.text

local map = util.map

local List = common.List

local M = {}

local RemoteHeader = Component.new(function(props)
  return row {
    text(props.name),
    text(': '),
    text(props.branch),
    text(' '),
    text(props.msg or '(no commits)'),
  }
end)

local Section = Component.new(function(props)
  return col {
    row {
      text(props.title),
      text(' ('),
      text(#props.items),
      text(')'),
    },
    col(props.items),
  }
end)

function M.Status(state)
  return {
    List {
      separator = ' ',
      items = {
        col {
          RemoteHeader {
            name = 'Head',
            branch = state.head.branch,
            msg = state.head.commit_message,
          },
          state.upstream.branch and RemoteHeader {
            name = 'Upstream',
            branch = state.upstream.branch,
            msg = state.upstream.commit_message,
          },
        },
        #state.stashes > 0 and Section {
          title = 'Stashes',
          items = map(state.stashes, function(s)
            return row {
              text.hightlight('Comment')('stash@{', s.idx, '}: '),
              text(s.message),
            }
          end),
        },
      },
    },
  }
end

return M
