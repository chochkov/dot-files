# markdown-simple

A simple vim plugin for managing markdown headings.

## Features

Only loaded for markdown files. Provides two keyboard shortcuts:

- `#` - Increase heading level
  - Regular line → H1 (`# `)
  - H1 → H2 (`## `)
  - H2 → H3 (`### `)
  - ...
  - H6 → Regular line (removes heading)

- `@` - Decrease heading level (opposite direction)
  - Regular line → H6 (`###### `)
  - H6 → H5 (`##### `)
  - H5 → H4 (`#### `)
  - ...
  - H1 → Regular line (removes heading)

## Installation

This plugin uses vim's native package management. It's installed in:
```
~/.config/nvim/pack/custom/start/markdown-simple/
```

The plugin automatically loads when editing markdown files.

## Usage

Place your cursor on any line and press:
- `#` to increase heading level
- `@` to decrease heading level

## Testing

Run the test suite:
```bash
cd ~/.config/nvim/pack/custom/start/markdown-simple
make test
```

Or manually:
```bash
vim -u NONE -S test_markdown_simple.vim
```
