local Color = require('autocommit.lib.color').Color
local api = vim.api
local hl_store
local M = {}

function M.hi(group, opt)
  vim.cmd(
    string.format(
      'hi %s %s guifg=%s guibg=%s gui=%s guisp=%s blend=%s',
      opt.default and 'default' or '',
      group,
      opt.fg or 'NONE',
      opt.bg or 'NONE',
      opt.gui or 'NONE',
      opt.sp or 'NONE',
      opt.blend or 'NONE'
    )
  )
end

function M.hi_link(from, to, opt)
  vim.cmd(string.format('hi%s %s link %s %s', opt.force and '!' or '', opt.default and 'default' or '', from, to or ''))
end

---@param trans boolean Translate the syntax group (follows links).
function M.get_hl_attr(name, attr, trans)
  local id = api.nvim_get_hl_id_by_name(name)
  if id and trans then
    id = vim.fn.synIDtrans(id)
  end
  if not id then
    return
  end

  local value = vim.fn.synIDattr(id, attr)
  if not value or value == '' then
    return
  end

  return value
end

---@param group_name string Syntax group name.
---@param trans boolean Translate the syntax group (follows links). True by default.
function M.get_fg(group_name, trans)
  if type(trans) ~= 'boolean' then
    trans = true
  end
  return M.get_hl_attr(group_name, 'fg', trans)
end

---@param group_name string Syntax group name.
---@param trans boolean Translate the syntax group (follows links). True by default.
function M.get_bg(group_name, trans)
  if type(trans) ~= 'boolean' then
    trans = true
  end
  return M.get_hl_attr(group_name, 'bg', trans)
end

---@param group_name string Syntax group name.
---@param trans boolean Translate the syntax group (follows links). True by default.
function M.get_gui(group_name, trans)
  if type(trans) ~= 'boolean' then
    trans = true
  end
  local hls = {}
  local attributes = {
    'bold',
    'italic',
    'reverse',
    'standout',
    'underline',
    'undercurl',
    'strikethrough',
  }

  for _, attr in ipairs(attributes) do
    if M.get_hl_attr(group_name, attr, trans) == '1' then
      table.insert(hls, attr)
    end
  end

  if #hls > 0 then
    return table.concat(hls, ',')
  end
end

local function get_cur_hl()
  return {
    AutocommitHunkHeader = { bg = M.get_bg('AutocommitHunkHeader', false) },
    AutocommitHunkHeaderHighlight = { bg = M.get_bg('AutocommitHunkHeaderHighlight', false) },
    AutocommitDiffContextHighlight = { bg = M.get_bg('AutocommitDiffContextHighlight', false) },
    AutocommitDiffAddHighlight = {
      bg = M.get_bg('AutocommitDiffAddHighlight', false),
      fg = M.get_fg('AutocommitDiffAddHighlight', false),
      gui = M.get_gui('AutocommitDiffAddHighlight', false),
    },
    AutocommitDiffDeleteHighlight = {
      bg = M.get_bg('AutocommitDiffDeleteHighlight', false),
      fg = M.get_fg('AutocommitDiffDeleteHighlight', false),
      gui = M.get_gui('AutocommitDiffDeleteHighlight', false),
    },
  }
end

local function is_hl_cleared(hl_map)
  local keys = { 'fg', 'bg', 'gui', 'sp', 'blend' }
  for _, hl in pairs(hl_map) do
    for _, k in ipairs(keys) do
      if hl[k] then
        return false
      end
    end
  end
  return true
end

function M.setup()
  local cur_hl = get_cur_hl()
  if not is_hl_cleared(cur_hl) and not vim.deep_equal(hl_store or {}, cur_hl) then
    -- Highlights have been modified somewhere else. Return.
    return
  end

  local bg = vim.o.bg
  local hl_fg_normal = M.get_fg('Normal') or (bg == 'dark' and '#eeeeee' or '#111111')
  local hl_bg_normal = M.get_bg('Normal') or (bg == 'dark' and '#111111' or '#eeeeee')

  -- Generate highlights by lightening for dark color schemes, and darkening
  -- for light color schemes.
  local bg_normal = Color.from_hex(hl_bg_normal)
  local sign = bg_normal.lightness >= 0.5 and -1 or 1

  local bg_hunk_header_hl = bg_normal:shade(0.15 * sign)
  local bg_diff_context_hl = bg_normal:shade(0.075 * sign)

  hl_store = {
    AutocommitHunkHeader = { bg = bg_diff_context_hl:to_css() },
    AutocommitHunkHeaderHighlight = { bg = bg_hunk_header_hl:to_css() },
    AutocommitDiffContextHighlight = { bg = bg_diff_context_hl:to_css() },
    AutocommitDiffAddHighlight = {
      bg = M.get_bg('DiffAdd', false) or bg_diff_context_hl:to_css(),
      fg = M.get_fg('DiffAdd', false) or M.get_fg('diffAdded') or hl_fg_normal,
      gui = M.get_gui('DiffAdd', false),
    },
    AutocommitDiffDeleteHighlight = {
      bg = M.get_bg('DiffDelete', false) or bg_diff_context_hl:to_css(),
      fg = M.get_fg('DiffDelete', false) or M.get_fg('diffRemoved') or hl_fg_normal,
      gui = M.get_gui('DiffDelete', false),
    },
  }

  for group, hl in pairs(hl_store) do
    M.hi(group, hl)
  end
end

return M
