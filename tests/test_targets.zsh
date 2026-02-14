#!/usr/bin/env zsh

# Test suite for targets.zsh
# Tests vim-style commands for shell vi-mode

# Source the targets file
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/../zsh/targets.zsh"

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test helper function
test_command() {
  local test_buffer="$1"
  local test_cursor="$2"
  local expected_buffer="$3"
  local expected_cursor="$4"
  local command="$5"
  local test_name="$6"
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  
  BUFFER="$test_buffer"
  CURSOR="$test_cursor"
  
  # Call the command
  $command
  
  # Check results
  if [[ "$BUFFER" == "$expected_buffer" ]] && [[ "$CURSOR" == "$expected_cursor" ]]; then
    echo "✓ $test_name"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo "✗ $test_name"
    echo "  Expected: BUFFER='$expected_buffer' CURSOR=$expected_cursor"
    echo "  Got:      BUFFER='$BUFFER' CURSOR=$CURSOR"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
}

echo "=== Testing ci' (change inside single quotes) ==="
test_command "echo 'hello world'" 7 "echo ''" 6 ci-single-quote "Cursor inside single quotes"
test_command "echo 'hello' 'world'" 2 "echo '' 'world'" 6 ci-single-quote "Cursor before first quote pair"
test_command "ls | grep 'test'" 12 "ls | grep ''" 11 ci-single-quote "Cursor inside quotes at end"
test_command "echo 'hello' world" 13 "echo '' world" 6 ci-single-quote "Cursor after quote pair"

echo "\n=== Testing ci\" (change inside double quotes) ==="
test_command 'echo "hello world"' 7 'echo ""' 6 ci-double-quote "Cursor inside double quotes"
test_command 'echo "hello" "world"' 2 'echo "" "world"' 6 ci-double-quote "Cursor before first quote pair"

echo "\n=== Testing ci[ (change inside brackets) ==="
test_command "echo [hello world]" 7 "echo []" 6 ci-bracket "Cursor inside brackets"
test_command "test [foo] [bar]" 2 "test [] [bar]" 6 ci-bracket "Cursor before first bracket pair"

echo "\n=== Testing ci( (change inside parens) ==="
test_command "echo (hello world)" 7 "echo ()" 6 ci-paren "Cursor inside parens"
test_command "func (foo) (bar)" 2 "func () (bar)" 6 ci-paren "Cursor before first paren pair"

echo "\n=== Testing fi- (find dash right) ==="
test_command "docker -p 8080 --name test" 0 "docker -p 8080 --name test" 8 fi-dash "From start, jump after single -"
test_command "docker -p 8080 --name test" 10 "docker -p 8080 --name test" 17 fi-dash "From middle, jump after -- in --name"
test_command "git commit --message test" 0 "git commit --message test" 13 fi-dash "Jump after -- (second dash)"
test_command "no dashes here" 0 "no dashes here" 0 fi-dash "No dashes, should not move"

echo "\n=== Testing Fi- (find dash left) ==="
test_command "docker -p 8080 --name test" 25 "docker -p 8080 --name test" 17 fi-underscore "From end, jump to --name"
test_command "docker -p 8080 --name test" 17 "docker -p 8080 --name test" 8 fi-underscore "At --name, skip to -p"
test_command "docker -p 8080 --name test" 8 "docker -p 8080 --name test" 8 fi-underscore "At first dash, no previous"

echo "\n=== Testing fi= (find equals right) ==="
test_command "export A=1 B=2 C=3" 0 "export A=1 B=2 C=3" 9 fi-equals "From start, jump after first ="
test_command "export A=1 B=2 C=3" 10 "export A=1 B=2 C=3" 13 fi-equals "From middle, jump after next ="
test_command "no equals here" 0 "no equals here" 0 fi-equals "No equals, should not move"

echo "\n=== Testing Fi= (find equals left) ==="
test_command "export A=1 B=2 C=3" 17 "export A=1 B=2 C=3" 13 fi-plus "From end, jump to last ="
test_command "export A=1 B=2 C=3" 13 "export A=1 B=2 C=3" 9 fi-plus "At B=, skip to A="
test_command "no equals here" 10 "no equals here" 10 fi-plus "No equals, should not move"

echo "\n=== Testing fip (find pipe right) ==="
test_command "ls -al | grep ivo" 0 "ls -al | grep ivo" 9 fi-pipe "From start, jump to grep"
test_command "ls -al |  grep ivo" 0 "ls -al |  grep ivo" 10 fi-pipe "With 2 spaces, jump to grep"
test_command "cmd1 | cmd2 | cmd3" 0 "cmd1 | cmd2 | cmd3" 7 fi-pipe "Multiple pipes, jump to cmd2"
test_command "cmd1 | cmd2 | cmd3" 8 "cmd1 | cmd2 | cmd3" 14 fi-pipe "From cmd2, jump to cmd3"
test_command "no pipes here" 0 "no pipes here" 0 fi-pipe "No pipe, should not move"

echo "\n=== Testing Fip (find pipe left) ==="
test_command "ls -al | grep ivo" 16 "ls -al | grep ivo" 9 fi-pipe-left "From end, jump to grep"
test_command "cmd1 | cmd2 | cmd3" 18 "cmd1 | cmd2 | cmd3" 7 fi-pipe-left "From end, skip cmd3, jump to cmd2"
test_command "cmd1 | cmd2 | cmd3" 14 "cmd1 | cmd2 | cmd3" 7 fi-pipe-left "From cmd3, skip to cmd2"
test_command "cmd1 | cmd2 | cmd3" 7 "cmd1 | cmd2 | cmd3" 0 fi-pipe-left "At first piped cmd, go to BOL"
test_command "ls -al | grep ivo" 9 "ls -al | grep ivo" 0 fi-pipe-left "At first piped cmd, go to BOL"
test_command "no pipes here" 10 "no pipes here" 10 fi-pipe-left "No pipe, should not move"

echo "\n=== Testing count support ==="
# Test with NUMERIC set
NUMERIC=2 test_command "a -b -c -d" 0 "a -b -c -d" 6 fi-dash "2fi- should jump to 2nd dash"
NUMERIC=3 test_command "a -b -c -d" 0 "a -b -c -d" 9 fi-dash "3fi- should jump to 3rd dash"
NUMERIC=2 test_command "a=1 b=2 c=3" 0 "a=1 b=2 c=3" 6 fi-equals "2fi= should jump to 2nd equals"
NUMERIC=2 test_command "cmd1 | cmd2 | cmd3 | cmd4" 0 "cmd1 | cmd2 | cmd3 | cmd4" 14 fi-pipe "2fip should jump to 2nd pipe"
NUMERIC=2 test_command "a -b -c -d" 10 "a -b -c -d" 6 fi-underscore "2Fi- from end should jump to 2nd-last dash"
NUMERIC=2 test_command "a=1 b=2 c=3" 12 "a=1 b=2 c=3" 6 fi-plus "2Fi= from end should jump to 2nd-last equals"
NUMERIC=2 test_command "cmd1 | cmd2 | cmd3 | cmd4" 25 "cmd1 | cmd2 | cmd3 | cmd4" 7 fi-pipe-left "2Fip from end should jump to 2nd-last pipe"
unset NUMERIC

# Print summary
echo "\n=========================================="
echo "Test Summary:"
echo "  Total:  $TOTAL_TESTS"
echo "  Passed: $PASSED_TESTS"
echo "  Failed: $FAILED_TESTS"
echo "=========================================="

if [[ $FAILED_TESTS -gt 0 ]]; then
  echo "TESTS FAILED"
  exit 1
else
  echo "ALL TESTS PASSED"
  exit 0
fi
