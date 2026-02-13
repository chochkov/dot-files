# Capture the directory of this zshrc file
ZSHRC_DIR="${${(%):-%x}:A:h}"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

if type brew &>/dev/null; then
  # This uses `brew --prefix` originally, but it's removed for performance
  FPATH=/opt/homebrew/share/zsh/site-functions:$FPATH
fi

autoload -Uz compinit && compinit

if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
    update_current_git_vars
    unset __EXECUTED_GIT_COMMAND
fi

set -o vi

bindkey -v
bindkey '^R' history-incremental-search-backward

# enable shift-tab for selection
bindkey '^[[Z' reverse-menu-complete

zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'   # formatting?
zstyle ':completion:*:default' select-prompt '%S%M matches%s' # do we want a select-prompt?
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' list-colors "${LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache true

zstyle ':vcs_info:*' formats '%F{blue}%s%f:%F{yellow}%b%f '
zstyle ':vcs_info:*' actionformats '%F{blue}%s%f:%F{yellow}%b%f:%F{cyan}%a%f '
zstyle ':vcs_info:*' enable git hg

precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )

# the format means branch + actions (i.e. rebase, etc.)
zstyle ':vcs_info:git:*' formats '%b%a'

setopt prompt_subst
autoload -Uz vcs_info
precmd() { vcs_info }
PROMPT=$'%F{cyan}%~ %f${vcs_info_msg_0_:+${vcs_info_msg_0_} }%F{green}$%f '

# -N shows line numbers; -X exists straight away on less-than-a-page; -i case
# insensitive search, -R color handling
export LESS=-WMXFiRx8

export HISTSIZE=10000
export HISTFILE=$HOME/.zsh_history
export SAVEHIST=$HISTSIZE

# Source additional configuration files
for file in $ZSHRC_DIR/zsh/*.zsh; do
  [ -f "$file" ] && source "$file"
done
