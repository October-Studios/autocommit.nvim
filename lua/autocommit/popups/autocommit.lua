local popup = require('autocommit.lib.popup')
local notif = require('autocommit.lib.notification')
local status = require('autocommit.status')
local cli = require('autocommit.lib.git.cli')
local a = require('plenary.async')
local split = require('autocommit.lib.util').split
local uv_utils = require('autocommit.lib.uv')
local CommitEditorBuffer = require('autocommit.buffers.commit')

local M = {}

local function get_commit_file()
  return cli.git_dir_path_sync() .. '/' .. 'AUTOCOMMIT_COMMIT_EDITMSG'
end

local get_commit_message = a.wrap(function(content, cb)
  CommitEditorBuffer.new(content, get_commit_file(), cb):open()
end, 2)

local function prompt_commit_message(args, msg, skip_gen)
  local msg_template_path = cli.config.get('commit.template').show_popup(false).call()[1]
  local output = {}

  if msg and #msg > 0 then
    for _, line in ipairs(msg) do
      table.insert(output, line)
    end
  elseif not skip_gen and not msg_template_path then
    table.insert(output, '')
  end

  if not skip_gen then
    if msg_template_path then
      a.util.scheduler()
      local expanded_path = vim.fn.glob(msg_template_path)
      if expanded_path == '' then
        return
      end
      local msg_template = uv_utils.read_file_sync(expanded_path)
      for _, line in pairs(msg_template) do
        table.insert(output, line)
      end
      table.insert(output, '')
    end
    local lines = cli.commit.dry_run.args('').call()
    for _, line in ipairs(lines) do
      table.insert(output, '# ' .. line)
    end
  end

  a.util.scheduler()
  return get_commit_message(output)
end

-- luacheck: push no unused args
local function do_commit(popup_, data, cmd, skip_gen)
  a.util.scheduler()
  local commit_file = get_commit_file()
  if data then
    local ok = prompt_commit_message('', data, skip_gen)
    if not ok then
      return
    end
  end
  a.util.scheduler()
  local notification = notif.create('Committing...', vim.log.levels.INFO, 9999)
  local result = cli.interactive_git_cmd(cmd)
  a.util.scheduler()
  if notification then
    notification:delete()
  end

  if result.code == 0 then
    notif.create('Successfully committed!')
    a.uv.fs_unlink(commit_file)
    status.refresh(true)
    vim.cmd([[do <nomodeline> User AutocommitCommitComplete]])
  end
end
-- luacheck: pop

function M.create()
  local p = popup
    .builder()
    :name('AutocommitCommitPopup')
    :action('y', ' - Commit and push?', function(popup)
      a.util.scheduler()
      local commit_file = get_commit_file()
      local _, data = uv_utils.read_file(commit_file)
      local skip_gen = data ~= nil
      data = data or ''
      -- we need \r? to support windows
      data = split(data, '\r?\n')
      do_commit(popup, data, 'test', skip_gen)
    end)
    :action('n', ' - Cancel and continue saving', function()
      -- noop
    end)
    :build()

  p:show()

  return p
end

return M
