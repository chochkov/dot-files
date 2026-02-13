export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

# TODO optimize this by hardcoding the dir
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

autoload -Uz compinit && compinit

# [ -s "/Users/nikola/.scm_breeze/scm_breeze.sh" ] && source "/Users/nikola/.scm_breeze/scm_breeze.sh"

###

if [ -n "$__EXECUTED_GIT_COMMAND" ]; then
    update_current_git_vars
    unset __EXECUTED_GIT_COMMAND
fi

###

# # Initialize colors.
# autoload -U colors
# colors
#
# # Allow for functions in the prompt.
# setopt PROMPT_SUBST
#
# # Autoload zsh functions.
# fpath=(~/.zsh/functions $fpath)
# autoload -U /usr/local/share/zsh/site-functions/*(:t)
#
# # Enable auto-execution of functions.
# typeset -ga preexec_functions
# typeset -ga precmd_functions
# typeset -ga chpwd_functions
#
# # Append git functions needed for prompt.
# preexec_functions+='preexec_update_git_vars'
# precmd_functions+='precmd_update_git_vars'
# chpwd_functions+='chpwd_update_git_vars'
# */
#
# Set the prompt.
# PROMPT=$'%{${fg[cyan]}%}%B%~%b$(prompt_git_info)%{${fg[default]}%} '

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
PROMPT=$'%F{cyan}%~ %f${vcs_info_msg_0_} %F{green}$%f '

# -N shows line numbers; -X exists straight away on less-than-a-page; -i case
# insensitive search, -R color handling
export LESS=-WMXFiRx8

export HISTSIZE=10000
export HISTFILE=$HOME/.zsh_history
export SAVEHIST=$HISTSIZE

# aliases
alias ls='ls -laGh'
alias gpoh='git push origin HEAD'
alias gcmm='git commit -m'
alias d='docker'
alias dcmp='docker-compose'
alias grep="grep --color=auto"
alias t="tmux"
alias R="R --no-save"

# Decrypt ~/.pgpass.gpg into a tmp file.
pg_dump_safe() {
    local TMP_PGPASS=$(mktemp /tmp/.pgpass.XXXXXX)
    gpg -q -d ~/.pgpass.gpg > "$TMP_PGPASS"
    chmod 0600 "$TMP_PGPASS"
    ((sleep 2; rm -f "$TMP_PGPASS") & disown) > /dev/null 2>&1

    PGPASSFILE="$TMP_PGPASS" command pg_dump "$@"
}
alias pg_dump=pg_dump_safe

# Decrypt ~/.pgpass.gpg into a tmp file.
psql_safe() {
    local TMP_PGPASS=$(mktemp /tmp/.pgpass.XXXXXX)
    gpg -q -d ~/.pgpass.gpg > "$TMP_PGPASS"
    chmod 0600 "$TMP_PGPASS"
    ((sleep 2; rm -f "$TMP_PGPASS") & disown) > /dev/null 2>&1

    PGPASSFILE="$TMP_PGPASS" command psql "$@"
}
alias psql=psql_safe

# Decrypt ~/.aws/credentials.gpg into a tmp file.
aws_safe() {
    local TMP_CREDS=$(mktemp /tmp/.aws_credentials.XXXXXX)
    gpg -q -d ~/.aws/credentials.gpg > "$TMP_CREDS"
    chmod 0600 "$TMP_CREDS"
    ((sleep 2; rm -f "$TMP_CREDS") & disown) > /dev/null 2>&1

    AWS_SHARED_CREDENTIALS_FILE="$TMP_CREDS" command aws "$@"
}
alias aws=aws_safe

# Decrypt ~/.ssh/id_rsa.gpg into a tmp file.
ssh_safe() {
    local TMP_CREDS=$(mktemp /tmp/.ssh_id_rsa.XXXXXX)
    gpg -q -d ~/.ssh/id_rsa.gpg > "$TMP_CREDS"
    chmod 0600 "$TMP_CREDS"
    ((sleep 2; rm -f "$TMP_CREDS") & disown) > /dev/null 2>&1

    command ssh -i "$TMP_CREDS" "$@"
}
alias ssh=ssh_safe

# nvm stuff TODO: move it to a separate file and source it here
export NVM_DIR="$HOME/.nvm"

lazy_nvm_load() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

nvm()  { lazy_nvm_load; nvm "$@" }
node() { lazy_nvm_load; node "$@" }
npm()  { lazy_nvm_load; npm "$@" }
npx()  { lazy_nvm_load; npx "$@" }
