# TODO:
# * figure out the secrets files with gpg script
# * setup vim plugins (lion?, replace? what else chat about best setup)
# * nvim doesnt take config - e.g. leader
# * set up dev env for SQL with tmux vim etc.

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

test:
	@echo "Running targets.zsh tests..."
	@zsh tests/test_targets.zsh
