-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local M = {}

function M:update()
  local status = {}
  local component = 'autocommit.git.file_diff'
  table.insert(status, component:refresh_diff())
end

return M
