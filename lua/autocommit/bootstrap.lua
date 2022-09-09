-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.
local res, err = pcall(require, 'plenary')
if not res then
  print('WARNING: Autocommit depends on `nvim-lua/plenary.nvim` to work, but loading the plugin failed!')
  print('Make sure you add `nvim-lua/plenary.nvim` to your plugin manager BEFORE autocommit for everything to work')
  print(err)
  return false
end

return true
