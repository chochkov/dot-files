" markdown-simple.vim
" Simple markdown heading navigation
" Only loaded for markdown files

if exists("b:did_markdown_simple_ftplugin")
  finish
endif
let b:did_markdown_simple_ftplugin = 1

" Function to increase heading level
function! MarkdownSimpleIncreaseHeading()
  let line = getline('.')
  let heading_match = matchstr(line, '^\(######\|#####\|####\|###\|##\|#\)\s')

  if heading_match == ''
    " Not a heading, make it H1
    call setline('.', '# ' . line)
  elseif heading_match == '###### '
    " Max level (H6), convert to regular line
    call setline('.', substitute(line, '^######\s\+', '', ''))
  else
    " Add one more # to increase level
    call setline('.', '#' . line)
  endif
endfunction

" Function to decrease heading level
function! MarkdownSimpleDecreaseHeading()
  let line = getline('.')
  let heading_match = matchstr(line, '^\(######\|#####\|####\|###\|##\|#\)\s')

  if heading_match == ''
    " Not a heading, make it H6 (max level)
    call setline('.', '###### ' . line)
  elseif heading_match == '# '
    " H1, convert to regular line
    call setline('.', substitute(line, '^#\s\+', '', ''))
  else
    " Remove one # to decrease level
    call setline('.', substitute(line, '^#', '', ''))
  endif
endfunction

" Map # to increase heading level
nnoremap <buffer> <silent> # :call MarkdownSimpleIncreaseHeading()<CR>

" Map @ to decrease heading level
nnoremap <buffer> <silent> @ :call MarkdownSimpleDecreaseHeading()<CR>
