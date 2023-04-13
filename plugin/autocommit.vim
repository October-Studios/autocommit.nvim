augroup autocommit
autocmd!
autocmd BufWritePost * lua require('autocommit').autocommit()
augroup END
