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

zle -N ci-single-quote
zle -N ci-double-quote
zle -N ci-bracket
zle -N ci-paren

bindkey -M vicmd "ci'" ci-single-quote
bindkey -M vicmd 'ci"' ci-double-quote
bindkey -M vicmd 'ci[' ci-bracket
bindkey -M vicmd 'ci(' ci-paren
