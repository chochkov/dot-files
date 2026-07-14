set number
set relativenumber
set nocompatible
set scrolloff=10
syntax enable
set ruler
set et sw=2 ts=2 sts=2

" Delete whitespace at the end of the file without moving the cursor.
function! RestoreWindowState(view, cursor) abort
  call winrestview(a:view)
  call setpos('.', a:cursor)
endfunction

function! TrimTrailingWhitespace() abort
  if &buftype !=# '' || !&modifiable
    return
  endif

  let l:view = winsaveview()
  let l:cursor = getcurpos()
  let l:search = @/

  try
    silent! keepjumps keeppatterns lockmarks %s/\s\+$//e
  finally
    let @/ = l:search
    call RestoreWindowState(l:view, l:cursor)
  endtry
endfunction

augroup trim_trailing_whitespace
  autocmd!
  autocmd BufWritePre * call TrimTrailingWhitespace()
augroup END

" gist.vim
" let g:gist_clip_command = 'pbcopy'

" TODO
let g:copilot_filetypes = {
  \ 'markdown': v:true,
  \ }

" ctrlp.vim
" let g:ctrlp_use_caching = 0

" Spellcheck for Rmarkdown
autocmd FileType rmd setlocal spell

" Trigger configuration. You need to change this to something other than <tab>
" if you use one of the following:
" - https://github.com/Valloric/YouCompleteMe
" - https://github.com/nvim-lua/completion-nvim
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-b>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"
" " If you want :UltiSnipsEdit to split your window.
" let g:UltiSnipsEditSplit="vertical"

" let g:ycm_add_preview_to_completeopt=1
" let g:ycm_min_num_identifier_candidate_chars=99

let mapleader = ","

" Capitalize in insert mode.
inoremap <c-u> <esc>viwUwA
nnoremap -c ddO

" go to alternate file
nnoremap <leader>f :e#<cr>

" Better interface for netrw.
"
" https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
"
" Call netrw in the current file's directory.
nnoremap <leader>dd :Lexplore %:p:h<CR>
" Call netrw in the current working directory.
nnoremap <Leader>da :Lexplore<CR>

" ~/.vimrc
nnoremap <leader>sv :source ~/.vimrc<cr>
nnoremap <leader>ev :vsplit ~/.vimrc<cr>
nnoremap <leader>q :q!<cr>
nnoremap <leader>w :w<cr>
nnoremap <leader>wq :wq<cr>

" Copy to clipboard shortcuts
" Copy line
nnoremap <leader>ll 0"+y$ :echo 'Line copied'<cr>
" Copy paragraph
nnoremap <leader>ip "+yip :echo 'Paragraph copied'<cr>
" Copy file
nnoremap <leader>ff gg"+yG :echo 'File copied'<cr>
" Copy in Word
nnoremap <leader>iW "+yiW :echo 'Word copied'<cr>

" Abbreviation
iabbrev GROPU GROUP
iabbrev evnets events

" Ack plugin
let g:ackprg = 'ag --vimgrep --smart-case'
cnoreabbrev ag Ack
cnoreabbrev aG Ack
cnoreabbrev Ag Ack
cnoreabbrev AG Ack
