augroup autocommit
  autocmd!
  autocmd BufWritePost * lua require('autocommit').setup().autocommit()
augroup END
