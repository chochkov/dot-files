# TODO:
# ^ remove sca breeze
# * add zsh plugins and split file
# * add shortcuts
# * add vim plugins as git submodules
# * figure out the secrets files with gpg script
# * fix k behaviour in zsh so that cursor is always in the beginning of line
# * fix whitespace on shell for non-git folders
# * setup vim plugins (lion?, replace? what else chat about best setup)

DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

FILES := \
	zshrc \
	tmux.conf \
	vimrc \
	inputrc \
	psqlrc

symlink:
	# Neovim config and plugins
	ln -sfn $(DOTFILES_DIR)/config/nvim $$HOME/.config/nvim
	# Dotfiles
	for file in $(FILES); do \
		ln -sfn $(DOTFILES_DIR)/$$file $$HOME/.$$file; \
	done
	# Zsh modules (no symlink needed, sourced from ~/dot-files/zsh/)
