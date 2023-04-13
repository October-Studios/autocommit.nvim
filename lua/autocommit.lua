-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/autocommit.nvim
local api = vim.api
local M

local function autocommit()
  -- Get the current buffer name
  local bufname = api.nvim_buf_get_name(0)

  -- Check if the buffer is in a Git repository
  local git_dir_cmd = 'git -C ' .. vim.fn.expand('%:p:h') .. ' rev-parse --git-dir'
  local git_dir_result = vim.fn.systemlist(git_dir_cmd)
  local git_dir = git_dir_result[1]
  if git_dir == nil or git_dir == '' then
    return
  end

  -- Get the relative file path
  local file_path = vim.fn.fnamemodify(bufname, ':.')

  -- Add changes to Git index
  local git_add_cmd = 'git -C ' .. vim.fn.expand('%:p:h') .. ' add ' .. file_path
  vim.fn.system(git_add_cmd)

  -- Commit changes with a message
  local commit_msg = string.format('Autocommit: %s', file_path)
  local git_commit_cmd = 'git -C ' .. vim.fn.expand('%:p:h') .. " commit -m '" .. commit_msg .. "'"
  vim.fn.system(git_commit_cmd)
end

M = {
  autocommit = autocommit,
}

return M
