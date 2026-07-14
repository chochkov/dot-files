# Understanding `gO` - The Treesitter TOC Feature

## What is `gO`?

The `gO` command in NeoVim opens a **Table of Contents (TOC)** view for markdown (and vimdoc) files. It shows all headings in your document in a navigable list.

## What Enables It?

### Treesitter
**Treesitter** is a parser library built into NeoVim (since v0.5+, native in v0.10+). It:
- Parses your code/markdown into a syntax tree
- Understands document structure (headings, code blocks, links, etc.)
- Enables semantic features like:
  - Smart navigation
  - Better syntax highlighting
  - Code folding
  - Structure-aware editing

### The `gO` Implementation
Located in: `/opt/homebrew/share/nvim/runtime/lua/vim/treesitter/_headings.lua`

**How it works:**
1. Treesitter parses the markdown file
2. Extracts all heading nodes (H1-H6, both `#` and underline styles)
3. Creates a location list (`:lopen`) with all headings
4. Adds indentation for visual hierarchy (H3+)
5. Hides file/line metadata for cleaner view

**Supported heading formats:**
```markdown
# ATX style (H1-H6)
## ATX style H2

Setext style H1
===============

Setext style H2
---------------
```

## How to Use `gO`

### Opening the TOC
1. In a markdown file, press `gO` in normal mode
2. A location list window opens at the bottom showing all headings

### Navigation
**In the TOC window:**
- `↑/↓` or `j/k` - Move between headings
- `Enter` - Jump to that heading in your file
- `:lne` or `:lnext` - Next heading
- `:lp` or `:lprev` - Previous heading

**From your file:**
- `gO` - Toggle TOC open/close
- `[[` - Jump to previous heading (without opening TOC)
- `]]` - Jump to next heading (without opening TOC)

### Exiting the TOC

Multiple ways to close it:

1. **`:q`** - Quit the location list window (most common)
2. **`:lclose`** - Close the location list
3. **`Ctrl+w c`** - Close current window
4. **`Ctrl+w o`** - Make current window the only window (closes all others)
5. Press `gO` again while in the original file

**Tip:** If you're in the TOC window and want to go back to editing:
- `Ctrl+w p` - Jump to previous window (your file)
- Or just `Ctrl+w k` - Move to window above

## Visual Example

```
# Main Document                     │ Location List (gO)
────────────────────────────────────┼─────────────────────────
# Chapter 1: Introduction           │ Chapter 1: Introduction
                                    │ Getting Started
Some intro text here...             │   Installation
                                    │   Configuration
## Getting Started                  │ Chapter 2: Advanced
                                    │   Treesitter
More text...                        │   LSP Setup
                                    │
### Installation                    │
                                    │
Details about installation...       │
                                    │
### Configuration                   │
                                    │
Config instructions...              │
                                    │
# Chapter 2: Advanced               │
                                    │
Advanced topics...                  │
                                    │
## Treesitter                       │
                                    │
About treesitter...                 │
```

## Technical Details

### Treesitter Query
NeoVim uses a query pattern to find headings:
```scheme
(atx_heading
  (atx_h1_marker)
  heading_content: (_) @h1)
```

This captures:
- ATX headings: `#`, `##`, `###`, etc.
- Setext headings: Underlined with `===` or `---`
- All 6 heading levels

### Location List vs Quickfix
- **Location list** (`:lopen`) - Per-window list (used by `gO`)
- **Quickfix** (`:copen`) - Global list (used for compile errors, grep results)

The TOC uses location list so each window can have its own TOC.

## Customization

### Custom Height
You can set the TOC window height:
```lua
vim.keymap.set('n', 'gO', function()
  require('vim.treesitter._headings').show_toc(15) -- 15 lines tall
end, { buffer = 0 })
```

### Disable `gO`
If you don't want this mapping:
```vim
" In your init.vim or ftplugin/markdown.vim
autocmd FileType markdown nunmap <buffer> gO
```

## Related Commands

- `:help location-list` - Learn about location lists
- `:help treesitter` - Learn about treesitter
- `:help gO` - Built-in help for gO
- `:Inspect` - See treesitter node under cursor
- `:InspectTree` - View full treesitter parse tree

## Pro Tips

1. **Quick navigation workflow:**
   ```
   gO        → Open TOC
   /search   → Search for heading
   Enter     → Jump to it
   :q        → Close TOC
   ```

2. **Keep TOC open while editing:**
   - Open TOC with `gO`
   - Navigate in TOC with `j/k`
   - Press `Enter` to preview sections
   - Use `Ctrl+w p` to go back to TOC

3. **For large documents:**
   - The TOC shows indentation for sub-headings
   - H1-H2: No indent
   - H3-H4: One indent (2 spaces)
   - H5-H6: Two indents (4 spaces)

## Common Issues

**Q: `gO` doesn't work?**
- Check: `:lua =vim.treesitter.get_parser()`
- If nil, treesitter parser not loaded for markdown

**Q: No headings shown?**
- Treesitter may not recognize your heading syntax
- Try standard `#` syntax instead of underline style
- Check with `:Inspect` on the heading line

**Q: TOC window too small/big?**
- Resize: `Ctrl+w +` / `Ctrl+w -` (add/remove lines)
- Or: `:resize 20` (set to 20 lines)
