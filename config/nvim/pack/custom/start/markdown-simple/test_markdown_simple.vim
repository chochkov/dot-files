" Test suite for markdown-simple plugin
" Run with: vim -u NONE -S test_markdown_simple.vim

" Load the plugin
source ftplugin/markdown.vim

" Test counter
let s:tests_run = 0
let s:tests_passed = 0

" Helper function to run a test
function! s:Test(description, line_before, line_after, action)
  let s:tests_run += 1
  
  " Set up the line
  call setline('.', a:line_before)
  
  " Execute the action
  if a:action == '#'
    call MarkdownSimpleIncreaseHeading()
  elseif a:action == '@'
    call MarkdownSimpleDecreaseHeading()
  endif
  
  " Check the result
  let result = getline('.')
  if result == a:line_after
    let s:tests_passed += 1
    echo "✓ " . a:description
  else
    echo "✗ " . a:description
    echo "  Expected: " . a:line_after
    echo "  Got:      " . result
  endif
endfunction

" Create a temporary buffer
enew!
setfiletype markdown

echo "Testing markdown-simple plugin"
echo "================================"
echo ""

" Test # (increase heading level)
echo "Testing # (increase heading level):"
call s:Test("Regular line → H1", "Hello World", "# Hello World", "#")
call s:Test("H1 → H2", "# Hello World", "## Hello World", "#")
call s:Test("H2 → H3", "## Hello World", "### Hello World", "#")
call s:Test("H3 → H4", "### Hello World", "#### Hello World", "#")
call s:Test("H4 → H5", "#### Hello World", "##### Hello World", "#")
call s:Test("H5 → H6", "##### Hello World", "###### Hello World", "#")
call s:Test("H6 → Regular", "###### Hello World", "Hello World", "#")

echo ""
echo "Testing @ (decrease heading level):"
call s:Test("Regular line → H6", "Hello World", "###### Hello World", "@")
call s:Test("H6 → H5", "###### Hello World", "##### Hello World", "@")
call s:Test("H5 → H4", "##### Hello World", "#### Hello World", "@")
call s:Test("H4 → H3", "#### Hello World", "### Hello World", "@")
call s:Test("H3 → H2", "### Hello World", "## Hello World", "@")
call s:Test("H2 → H1", "## Hello World", "# Hello World", "@")
call s:Test("H1 → Regular", "# Hello World", "Hello World", "@")

echo ""
echo "Testing edge cases:"
call s:Test("Line with extra spaces after #", "# Hello World", "## Hello World", "#")
call s:Test("Line with text but no # prefix", "Some text here", "# Some text here", "#")

echo ""
echo "================================"
echo printf("Tests run: %d", s:tests_run)
echo printf("Tests passed: %d", s:tests_passed)
echo printf("Tests failed: %d", s:tests_run - s:tests_passed)

if s:tests_passed == s:tests_run
  echo "All tests passed! ✓"
  quit!
else
  echo "Some tests failed! ✗"
  cquit!
endif
