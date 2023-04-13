-- Organization: October Studios
-- Developer: Cameron Howell (@crhowell3)
-- License: MIT
-- Source: https://github.com/October-Studios/autocommit.nvim
local api = vim.api
local M

local function setup()
  -- Define Git commit message template
  local commit_template = "Auto-commit: Save %s"

  -- Define autocommit function
  local function autocommit()
    -- Get current buffer name
    local bufname = api.nvim_buf_get_name(0)

    -- Check if buffer is in a Git repository
    local git_dir = vim.fn.systemlist("git -C " .. vim.fn.expand("%:p:h") .. " rev-parse --git-dir")[1]
    if not git_dir or git_dir == "" then
      return
    end

    -- Get the relative file path
    local file_path = vim.fn.fnamemodify(bufname, ":.")

    -- Add changes to Git index
    vim.fn.system("git -C " .. vim.fn.expand("%:p:h") .. " add " .. file_path)

    -- Commit changes with a message
    local commit_msg = string.format(commit_template, file_path)
    vim.fn.system("git -C " .. vim.fn.expand("%:p:h") .. " commit -m '" .. commit_msg .. "'")
  end
end

M = {
  setup = setup
}

return M
