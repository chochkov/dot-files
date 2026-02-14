# Dotfiles

Personal configuration files.

## Setup

```bash
make symlink
```

## Zsh Shortcuts

Vim-style navigation commands for zsh vi-mode (normal mode):

### Change Inside (ci)
- `ci'` - Change inside single quotes
- `ci"` - Change inside double quotes
- `ci(` or `cib` - Change inside parentheses
- `ci[` or `ciB` - Change inside brackets

### Find Character (fi/Fi)
Navigate to next/previous occurrences of special characters:

- `fi-` - Jump to after next `-` (right)
- `Fi-` - Jump to after previous `-` (left)
- `fi=` - Jump to after next `=` (right)
- `Fi=` - Jump to after previous `=` (left)
- `fip` - Jump to command after next `|` (right)
- `Fip` - Jump to command after previous `|` (left)

All commands support count prefixes (e.g., `2fip` jumps to 2nd pipe to the right).

Special features:
- Double dashes (`--`) are treated as single occurrence
- Pipe navigation skips whitespace to land at command start
- All commands stay in normal mode (don't switch to insert)
