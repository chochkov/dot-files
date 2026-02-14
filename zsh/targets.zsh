# Inspired by targets.vim, but acts on normal mode in the shell.

# Change inside paired characters (quotes, brackets, parens)
# Similar behaviour like targets.vim
change-inside() {
  local char="$1"
  local open="$2"
  local close="$3"
  local pos=$((CURSOR + 1))
  local line="$BUFFER"
  local len=${#line}

  local start=-1
  local end=-1
  local i

  # For quotes (where open == close), use simpler pair matching
  if [[ "$open" == "$close" ]]; then
    # Find all occurrences of the quote
    local -a positions=()
    for ((i = 1; i <= len; i++)); do
      if [[ "${line:$i-1:1}" == "$open" ]]; then
        positions+=($i)
      fi
    done

    # Find the pair containing or nearest to cursor
    local idx
    for ((idx = 1; idx <= ${#positions[@]} - 1; idx += 2)); do
      local p1=${positions[$idx]}
      local p2=${positions[$((idx + 1))]}
      # Check if cursor is inside this pair or before the next pair
      if ((pos >= p1 && pos <= p2)); then
        start=$p1
        end=$p2
        break
      elif ((pos < p1)); then
        start=$p1
        end=$p2
        break
      fi
    done
    
    # If not found and cursor is after all pairs, use the last pair
    if ((start < 0 && ${#positions[@]} >= 2)); then
      start=${positions[${#positions[@]} - 1]}
      end=${positions[${#positions[@]}]}
    fi
  else
    # For brackets/parens (where open != close), use depth tracking
    local depth=0
    
    # Check if we're inside a pair by scanning backwards
    for ((i = pos - 1; i >= 1; i--)); do
      local c="${line:$i-1:1}"
      if [[ "$c" == "$close" ]]; then
        ((depth++))
      elif [[ "$c" == "$open" ]]; then
        if ((depth == 0)); then
          start=$i
          break
        fi
        ((depth--))
      fi
    done

    if ((start > 0)); then
      depth=0
      for ((i = start + 1; i <= len; i++)); do
        local c="${line:$i-1:1}"
        if [[ "$c" == "$open" ]]; then
          ((depth++))
        elif [[ "$c" == "$close" ]]; then
          if ((depth == 0)); then
            end=$i
            break
          fi
          ((depth--))
        fi
      done
    fi

    # If not found, search right for next pair
    if ((start < 0 || end < 0 || pos > end)); then
      start=-1
      end=-1
      depth=0
      for ((i = pos; i <= len; i++)); do
        local c="${line:$i-1:1}"
        if [[ "$c" == "$open" ]]; then
          if ((depth == 0)); then
            start=$i
          fi
          ((depth++))
        elif [[ "$c" == "$close" ]]; then
          ((depth--))
          if ((depth == 0 && start > 0)); then
            end=$i
            break
          fi
        fi
      done
    fi
  fi

  if ((start > 0 && end > 0 && start < end)); then
    # Delete content between delimiters
    BUFFER="${line:0:$start}${line:$end-1}"
    CURSOR=$start
    if zle; then
      zle vi-insert
    fi
  fi
}

ci-single-quote() {
  change-inside "'" "'" "'"
}
ci-double-quote() {
  change-inside '"' '"' '"'
}
ci-bracket() {
  change-inside "[" "[" "]"
}
ci-paren() {
  change-inside "(" "(" ")"
}
fi-dash() {
  jump-after-char-right "-"
}
fi-underscore() {
  jump-after-char-left "-"
}
fi-equals() {
  jump-after-char-right "="
}
fi-plus() {
  jump-after-char-left "="
}
fi-pipe() {
  jump-to-command-after-pipe-right
}
fi-pipe-left() {
  jump-to-command-after-pipe-left
}

# Jump cursor to position after next occurrence of character (search right only)
jump-after-char-right() {
  local target="$1"
  local line="$BUFFER"
  local len=${#line}
  local pos=$((CURSOR + 1))
  local count=${NUMERIC:-1}
  local found_count=0
  local found_pos=-1
  
  # Search right from cursor, counting occurrences
  for ((i = pos; i <= len; i++)); do
    if [[ "${line:$i-1:1}" == "$target" ]]; then
      # Special handling for dash: if we found -- count as one occurrence at second dash
      if [[ "$target" == "-" ]] && ((i < len)) && [[ "${line:$i:1}" == "-" ]]; then
        ((found_count++))
        if ((found_count == count)); then
          found_pos=$((i + 1))
          break
        fi
        # Skip the second dash
        ((i++))
      else
        ((found_count++))
        if ((found_count == count)); then
          found_pos=$i
          break
        fi
      fi
    fi
  done
  
  # Move cursor to after the character (or EOL if at EOL)
  if ((found_pos > 0)); then
    if ((found_pos >= len)); then
      CURSOR=$len
    else
      CURSOR=$found_pos
    fi
  fi
}

# Jump cursor to position after next occurrence of character (search left only)
jump-after-char-left() {
  local target="$1"
  local line="$BUFFER"
  local len=${#line}
  local pos=$((CURSOR + 1))
  local count=${NUMERIC:-1}
  local found_pos=-1
  local skip_count=0
  local found_count=0
  
  # If we're right after the target character, we need to skip it
  # For dashes: if we're after --, we need to skip both dashes
  if ((CURSOR > 0)) && [[ "${line:$CURSOR-1:1}" == "$target" ]]; then
    skip_count=1
    # Check if it's -- (two dashes in a row before cursor)
    if [[ "$target" == "-" ]] && ((CURSOR > 1)) && [[ "${line:$CURSOR-2:1}" == "-" ]]; then
      skip_count=2
    fi
  fi
  
  # Search left from cursor
  for ((i = pos - 1; i >= 1; i--)); do
    if [[ "${line:$i-1:1}" == "$target" ]]; then
      # Skip the required number of occurrences at current position
      if ((skip_count > 0)); then
        ((skip_count--))
        continue
      fi
      
      # Found an occurrence
      local this_pos=-1
      # Special handling for dash: check if this is part of --
      if [[ "$target" == "-" ]] && ((i > 1)) && [[ "${line:$i-2:1}" == "-" ]]; then
        # We found the second dash of --, position after it
        this_pos=$i
        # Also skip the first dash
        ((i--))
      elif [[ "$target" == "-" ]] && ((i < len)) && [[ "${line:$i:1}" == "-" ]]; then
        # We found the first dash of --, position after the second
        this_pos=$((i + 1))
      else
        # Single dash or not a dash at all
        this_pos=$i
      fi
      
      ((found_count++))
      if ((found_count == count)); then
        found_pos=$this_pos
        break
      fi
    fi
  done
  
  # Move cursor to after the character (or EOL if at EOL)
  if ((found_pos > 0)); then
    if ((found_pos >= len)); then
      CURSOR=$len
    else
      CURSOR=$found_pos
    fi
  fi
}

# Jump to start of command after next pipe (search right)
jump-to-command-after-pipe-right() {
  local line="$BUFFER"
  local len=${#line}
  local pos=$((CURSOR + 1))
  local count=${NUMERIC:-1}
  local found_count=0
  local pipe_pos=-1
  
  # Search right for pipes, counting occurrences
  for ((i = pos; i <= len; i++)); do
    if [[ "${line:$i-1:1}" == "|" ]]; then
      ((found_count++))
      if ((found_count == count)); then
        pipe_pos=$i
        break
      fi
    fi
  done
  
  # If found, skip whitespace after pipe and position at start of command
  if ((pipe_pos > 0)); then
    local cmd_start=$((pipe_pos + 1))
    while ((cmd_start <= len)) && [[ "${line:$cmd_start-1:1}" == " " ]]; do
      ((cmd_start++))
    done
    
    if ((cmd_start <= len)); then
      CURSOR=$((cmd_start - 1))
    else
      CURSOR=$len
    fi
  fi
}

# Jump to start of command after next pipe (search left)
jump-to-command-after-pipe-left() {
  local line="$BUFFER"
  local len=${#line}
  local pos=$((CURSOR + 1))
  local count=${NUMERIC:-1}
  local pipe_pos=-1
  local skip_first=0
  local did_skip=0
  local found_count=0
  
  # Check if we're currently within a command that starts after a pipe
  local check_pos=$pos
  
  # Skip backwards to start of current word/command
  while ((check_pos > 1)) && [[ "${line:$check_pos-2:1}" != " " ]] && [[ "${line:$check_pos-2:1}" != "|" ]]; do
    ((check_pos--))
  done
  
  # Now skip any whitespace
  while ((check_pos > 1)) && [[ "${line:$check_pos-2:1}" == " " ]]; do
    ((check_pos--))
  done
  
  # Check if there's a pipe immediately before
  if ((check_pos > 0)) && [[ "${line:$check_pos-2:1}" == "|" ]]; then
    skip_first=1
  fi
  
  # Search left for pipe
  for ((i = pos - 1; i >= 1; i--)); do
    if [[ "${line:$i-1:1}" == "|" ]]; then
      # If we need to skip the first pipe, do so
      if ((skip_first > 0)); then
        skip_first=0
        did_skip=1
        continue
      fi
      
      # Found a pipe
      ((found_count++))
      if ((found_count == count)); then
        pipe_pos=$i
        break
      fi
    fi
  done
  
  # If found, skip whitespace after pipe and position at start of command
  if ((pipe_pos > 0)); then
    local cmd_start=$((pipe_pos + 1))
    while ((cmd_start <= len)) && [[ "${line:$cmd_start-1:1}" == " " ]]; do
      ((cmd_start++))
    done
    
    if ((cmd_start <= len)); then
      CURSOR=$((cmd_start - 1))
    else
      CURSOR=$len
    fi
  elif ((did_skip == 1 && pipe_pos < 0 && count == 1)); then
    # We skipped a pipe but found no previous pipe (only for count=1), go to beginning of line
    CURSOR=0
  fi
}

zle -N ci-single-quote
zle -N ci-double-quote
zle -N ci-bracket
zle -N ci-paren
zle -N fi-dash
zle -N fi-equals
zle -N fi-underscore
zle -N fi-plus
zle -N fi-pipe
zle -N fi-pipe-left

bindkey -M vicmd "ci'" ci-single-quote
bindkey -M vicmd 'ci"' ci-double-quote
bindkey -M vicmd 'ci(' ci-paren
bindkey -M vicmd 'cib' ci-paren
bindkey -M vicmd 'ci[' ci-bracket
bindkey -M vicmd 'ciB' ci-bracket
bindkey -M vicmd 'fi-' fi-dash
bindkey -M vicmd 'Fi-' fi-underscore
bindkey -M vicmd 'fi=' fi-equals
bindkey -M vicmd 'Fi=' fi-plus
bindkey -M vicmd 'fip' fi-pipe
bindkey -M vicmd 'Fip' fi-pipe-left
