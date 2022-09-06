-- Copyright (c) 2022-present October Studios
-- MIT license, see LICENSE for more details.

local autocommit_require = require('autocommit_require')
local modules = autocommit_require.lazy_require {
  utils = 'autocommit.utils.utils',
  Job = 'autocommit.utils.job',
}

local M = {}

-- Vars
-- variable to store git diff stats
local file_diff = nil
-- accumulates outptu from diff process
local diff_output_cache = {}
-- variable to store file_diff job
local diff_job = nil

local active_bufnr = '0'
local diff_cache = {}

---initialize the diff logic
function M.init()
  modules.utils.define_autocmd('BufWritePost', "lua require'autocommit.git.file_diff'.update_file_diff()")
  M.update_diff_args()
end

function M.get_sign_count(bufnr)
  if bufnr then
    return diff_cache[bufnr]
  end
  if M.src then
    file_diff = M.src()
    diff_cache[vim.api.nvim_get_current_buf()] = file_diff
  elseif vim.g.actual_curbuf ~= nil and active_bufnr ~= vim.g.actual_curbuf then
    M.update_diff_args()
  end
  return file_diff
end

function M.update_diff_args()
  active_bufnr = tostring(vim.api.nvim_get_current_buf())
  if #vim.fn.expand('%') == 0 then
    M.diff_args = nil
    file_diff = nil
    return
  end
  M.diff_args = {
    cmd = string.format(
      [[git -C %s --no-pager diff --no-color --no-ext-diff -U0 -- %s]],
      vim.fn.expand('%:h'),
      vim.fn.expand('%:t')
    ),
    on_stdout = function(_, data)
      if next(data) then
        diff_output_cache = vim.list_extend(diff_output_cache, data)
      end
    end,
    on_stderr = function(_, data)
      data = table.concat(data, '\n')
      if #data > 0 then
        file_diff = nil
        diff_output_cache = {}
      end
    end,
    on_exit = function()
      if #diff_output_cache > 0 then
        local deb = debug.traceback()
        os.execute('echo "' .. deb .. '" > temp.txt')
        os.execute('git add --all')
        os.execute('git commit -m "Autocommit!"')
        os.execute('git push')
      else
        file_diff = { added = 0, modified = 0, removed = 0 }
      end
      diff_cache[vim.api.nvim_get_current_buf()] = file_diff
    end,
  }
  M.update_file_diff()
end

---update file_diff variable
function M.update_file_diff()
  if M.diff_args then
    diff_output_cache = {}
    if diff_job then
      diff_job:stop()
    end
    diff_job = modules.Job(M.diff_args)
    if diff_job then
      diff_job:start()
    end
  end
end

return M
