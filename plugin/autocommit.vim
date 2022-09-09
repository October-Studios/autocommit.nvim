if exists('g:neovim_loaded')
  finish
endif
let g:neovim_loaded = 1

if !luaeval("require 'autocommit.bootstrap'")
  finish
endif

function! autocommit#refresh_manually(file)
  call luaeval('(function() require "autocommit.status".refresh_manually(_A) end)()', a:file)
endfunction

function! s:refresh(file)
  if match(bufname(), "^\\(Autocommit.*\\|.git/COMMIT_EDITMSG\\)$") == 0
    return
  endif
  call luaeval('(function() require "autocommit.status".refresh_viml_compat(_A) end)()', a:file)
endfunction

augroup Autocommit
  au!
  au BufWritePost,BufEnter,FocusGained,ShellCmdPost,VimResume * call <SID>refresh(expand('<afile>'))
  au BufWritePost * lua require'autocommit'.open({'autocommit'})
  au DirChanged * lua vim.defer_fn(function() require 'autocommit.status'.dispatch_reset() end, 0)
  au ColorScheme * lua require'autocommit.lib.hl'.setup()
augroup END

function! autocommit#complete(arglead, ...)
  return luaeval('require("autocommit").complete')(a:arglead)
endfunction

command! -nargs=* -complete=customlist,autocommit#complete
      \ Autocommit lua require'autocommit'.open(require'autocommit.lib.util'.parse_command_args(<f-args>))<CR>
