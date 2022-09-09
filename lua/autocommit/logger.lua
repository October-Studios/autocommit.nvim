-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local log = require('plenary.log')

return log.new {
  plugin = 'autocommit',
  highlights = false,
  use_console = false,
  level = 'debug',
}
