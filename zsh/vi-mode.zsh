# Move cursor to beginning of line after history navigation (like bash)
vi-up-line-or-beginning-search() {
  zle vi-up-line-or-history
  zle vi-first-non-blank
}
zle -N vi-up-line-or-beginning-search

vi-down-line-or-beginning-search() {
  zle vi-down-line-or-history
  zle vi-first-non-blank
}
zle -N vi-down-line-or-beginning-search

bindkey -M vicmd 'k' vi-up-line-or-beginning-search
bindkey -M vicmd 'j' vi-down-line-or-beginning-search

# Disable - and + default vim bindings (up/down history). They are quite
# annoying and I never use them productively (I use j or k)
bindkey -M vicmd -r -- '-'
bindkey -M vicmd -r -- '+'
