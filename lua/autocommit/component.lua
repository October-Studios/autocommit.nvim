--
--

local autocommit_require = require('autocommit_require')
local require = autocommit_require.require
local M = require('autocommit.utils.class'):extend()

M.status = ''

function M:init() end

function M:update_status() end

return M
