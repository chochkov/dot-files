set number
set relativenumber
set nocompatible
set scrolloff=10
syntax enable
set ruler
set et sw=2 ts=2 sts=2

" Delete whitespace at the end of the file.
autocmd BufWritePre * %s/\s\+$//e

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


" My Plugin

function! AdjustTmuxPanes()
    " Determine the height of the tmux window
    let l:height = system("tmux display -p '#{pane_height}'")

    " Calculate 75% of the height for the top pane
    let l:top_height = float2nr(l:height * 0.75)

    " Resize the top pane
    call system("tmux resize-pane -y " . l:top_height)

    " The bottom pane will automatically adjust, but if you want
    " to explicitly set the bottom pane, you could calculate its
    " height and use the `resize-pane` command with the `-D` option.
endfunction


function! TmuxSplitSendKeys()
    " Check if we are within a tmux session
    if empty($TMUX)
        echo "Not in a tmux session."
        return
    endif

    " Check if the current tmux window is split in more than two panes
    let panes = system('tmux list-panes | wc -l')
    if panes > 1
        echo "More than one pane exists."
        return
    endif

    " Split tmux pane vertically
    if panes == 1
        call system('tmux split-window -v')
    endif

    " TODO: fix this to work with the current pane because now it resizes.
    " call AdjustTmuxPanes()

    " " Get the tmux prefix key
    " TODO: here we dont use this because the interpolation below doesnt work
    " let prefix = system("tmux show-options -g | grep '^prefix' | awk '{print $2}'")
    " let prefix = substitute(prefix, "\n$", "", "")

    " Send the specified key sequence to the lower pane using the obtained prefix key
    " Escape <prefix> k Enter
    call system('tmux send-keys -t .bottom Escape C-b k Enter')
endfunction

command! TmuxSplitSend :call TmuxSplitSendKeys()
" exectute this on file save for *.sql files
autocmd BufWritePost *.sql call TmuxSplitSendKeys()

"
"" autocmd BufWritePost * call TmuxSplitSendKeys()
