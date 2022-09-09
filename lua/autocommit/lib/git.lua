-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local cli = require('autocommit.lib.git.cli')

return {
  status = require('autocommit.lib.git.status'),
  log = require('autocommit.lib.git.log'),
  branch = require('autocommit.lib.git.branch'),
  cli = cli,
  diff = require('autocommit.lib.git.diff'),
}
