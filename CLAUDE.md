# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles, symlinked into `$HOME` via `make symlink`. Files of note:

- `zshrc` — sources every `zsh/*.zsh` module automatically (loop at the bottom of the file), so a new module just needs to be dropped in `zsh/` with no manual wiring.
- `zsh/targets.zsh` — custom zle widgets that emulate `targets.vim`/vim-style motions (`ci'`, `ci"`, `ci(`, `cib`, `ci[`, `ciB`) and custom find-motions (`fi-`/`Fi-`, `fi=`/`Fi=`, `fip`/`Fip`) for zsh vi-mode. These are hand-rolled string/cursor manipulations over `$BUFFER`/`$CURSOR`, not real vim — logic lives in plain functions (`change-inside`, `jump-after-char-right`, `jump-after-char-left`, `jump-to-command-after-pipe-right/left`) that are then registered with `zle -N` and bound with `bindkey -M vicmd`.
- `zsh/wrappers.zsh` — wraps `pg_dump`, `psql`, `aws`, `ssh` to transparently decrypt a GPG-encrypted credentials file (`~/.pgpass.gpg`, `~/.aws/credentials.gpg`, `~/.ssh/id_rsa.gpg`) into a short-lived tmp file, run the real command, then delete the tmp file after a 2s delay. Any change here touches how real credentials are handled — be careful with permissions (`chmod 0600`) and cleanup ordering.
- `zsh/vi-mode.zsh` — general zsh vi-mode tweaks (history search preserving cursor position, disabling `-`/`+` history bindings).
- `config/nvim/` — Neovim config; plugins are vendored under `pack/<vendor>/start/<plugin>` (native Vim8/Neovim packages, not a plugin manager). `vimrc` sources the legacy `~/.vimrc` then layers Neovim-only config (colorscheme) on top.
- `gitconfig` — includes `~/.gitconfig.local` for machine-specific `user.name`/`user.email`; don't put personal identity info directly in the repo's `gitconfig`.
- `agents/claude/CLAUDE.md` — this is the *global* `~/.claude/CLAUDE.md`, symlinked by `make symlink`. It's a private, user-wide instruction file (currently just the PII/privacy rule), separate in purpose from this repo-level CLAUDE.md.
- `agents/claude/skills/` — the *global* `~/.claude/skills/` directory (the whole folder is symlinked by `make symlink`, mirroring the zsh auto-sourcing convention above — drop a new `<skill-name>/SKILL.md` in here and it's picked up with no extra wiring). Currently just `asana-commenting/`, which encodes personal tone/mention conventions for posting Asana comments.

## Commands

```bash
make symlink   # symlink all managed dotfiles + config/nvim into $HOME
make test      # run tests/test_targets.zsh (the zsh vi-mode motion tests)
```

There is no build step. Shell scripts are sourced directly; nvim plugins are plain vendored files (no install/compile step beyond symlinking).

### Running a single test

`tests/test_targets.zsh` is a flat script, not a test-framework file — it sources `zsh/targets.zsh` and runs a fixed list of `test_command` calls, printing a pass/fail summary and exiting non-zero on failure. To check a single behavior, comment out or temporarily trim the other `test_command` lines, or just run `zsh tests/test_targets.zsh` and read the ✓/✗ output (test names describe the scenario, e.g. "From middle, jump after -- in --name").

When adding a new vi-mode motion to `zsh/targets.zsh`, add matching `test_command` cases to `tests/test_targets.zsh` — this is the only regression coverage for that file's cursor-math logic.

## Conventions

- New shell config goes in `zsh/*.zsh`; it will be picked up automatically by `zshrc`'s sourcing loop — do not add explicit `source` lines to `zshrc` itself.
- `Makefile`'s `FILES` list controls which top-level dotfiles get symlinked to `$HOME/.<file>`; a new dotfile must be added there to be installed by `make symlink`.
