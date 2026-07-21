# TODO:
# * figure out the secrets files with gpg script
# * setup vim plugins (lion?, replace? what else chat about best setup)
# * set up dev env for SQL with tmux vim etc.
# * SQL task
# * tmux complete in vim plugin
# * atm on save in vim, the cursor gets misplaced, need to fix that

# * Code completion in vim for SQL queries, maybe with a plugin like coc.nvim or nvim-compe
#   - need completion from column names in the database, so might need to set up a language server for SQL
#   - would be great to have completion from the values of some columns as well.
#   - would be great to have this completion work in tmux as well, maybe with a plugin like tmux-cpp?
#   - would be great to have this completion in psql as well, maybe with a plugin like pgcli?
#   - tmux spotify plugin:
#   	* show current song in tmux status bar
#   		-	with option to show/hide.
#   		-	with option to show it only when spotify is playing.
#   		- with option to show it only on some sessions.
#   	* option to control spotify from tmux, with keybindings to play/pause, skip, etc.
#   	* option to add song to playlist from tmux.
#   	* make sure nothing can overwrite it (e.g. copilot or claude code)

DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

FILES := \
	zshrc \
	tmux.conf \
	vimrc \
	inputrc \
	psqlrc \
	gitconfig

symlink:
	# Neovim config and plugins
	ln -sfn $(DOTFILES_DIR)/config/nvim $$HOME/.config/nvim
	# Dotfiles
	for file in $(FILES); do \
		ln -sfn $(DOTFILES_DIR)/$$file $$HOME/.$$file; \
	done
	# Zsh modules (no symlink needed, sourced from ~/dot-files/zsh/)
	# Claude:
	ln -sfn $(DOTFILES_DIR)/agents/claude/CLAUDE.md $$HOME/.claude/CLAUDE.md
	ln -sfn $(DOTFILES_DIR)/agents/claude/skills $$HOME/.claude/skills

test:
	@echo "Running targets.zsh tests..."
	@zsh tests/test_targets.zsh

# Installs and (re)loads the launchd agent that reaps idle psql SSH tunnels
# (see zsh/pg_tunnels.zsh, zsh/wrappers.zsh, scripts/pg-tunnel-reaper.sh).
# Separate from `symlink` since it starts a running background service.
install-pg-tunnel-reaper:
	mkdir -p $$HOME/Library/LaunchAgents
	ln -sfn $(DOTFILES_DIR)/launchagents/local.pg-tunnel-reaper.plist \
		$$HOME/Library/LaunchAgents/local.pg-tunnel-reaper.plist
	launchctl unload $$HOME/Library/LaunchAgents/local.pg-tunnel-reaper.plist 2>/dev/null || true
	launchctl load -w $$HOME/Library/LaunchAgents/local.pg-tunnel-reaper.plist
