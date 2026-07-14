# Markdown Features & Shortcuts in Your NeoVim Setup

## Your Current Setup
- **NeoVim**: v0.11.6
- **Plugins**: copilot.vim, vim-commentary, vim-surround, targets.vim, kanagawa.nvim, **markdown-simple** (your new plugin)

---

## Built-in NeoVim Markdown Features

### Navigation Shortcuts

#### `[[` - Jump to Previous Heading
- Moves cursor backward to the previous heading (# Heading or underline-style)
- Works in normal and visual mode
- Searches for lines starting with 1-5 `#` characters

#### `]]` - Jump to Next Heading  
- Moves cursor forward to the next heading
- Works in normal and visual mode
- Searches for lines starting with 1-5 `#` characters

#### `gO` - Show Table of Contents (Treesitter)
- Opens an outline/TOC of all headings in the current buffer
- Only available if treesitter is enabled (which NeoVim 0.11.6 has built-in)
- Quick way to navigate large markdown documents

### Formatting

#### Comments
- `commentstring` is set to `<!-- %s -->`
- Works with vim-commentary plugin: `gcc` to toggle comment on current line

#### Auto-formatting Options
The following are automatically set for markdown files:
- **Expandtab**: Tabs are converted to spaces
- **tabstop=4, softtabstop=4, shiftwidth=4**: 4-space indentation (recommended markdown style)
- **formatoptions**: 
  - `t` - Auto-wrap text using textwidth
  - `c` - Auto-wrap comments
  - `q` - Allow formatting with `gq`
  - `l` - Long lines are not broken in insert mode
  - `n` - Recognize numbered lists
  - `-r` - Do NOT auto-insert comment leader on Enter
  - `-o` - Do NOT auto-insert comment leader on `o`/`O`

#### List Formatting
- Recognizes numbered lists: `1. Item`
- Recognizes bullet lists: `- Item`, `* Item`, `+ Item`
- Recognizes quote blocks: `> Quote`

### Folding (Optional)
To enable markdown folding, add to your vimrc:
```vim
let g:markdown_folding = 1
```
Then you can:
- `za` - Toggle fold at cursor
- `zM` - Close all folds
- `zR` - Open all folds

---

## Your Installed Plugins (for Markdown)

### vim-commentary
**Shortcut**: `gc{motion}` or `gcc`

Examples:
- `gcc` - Toggle comment on current line (adds `<!-- -->`)
- `gcip` - Comment out current paragraph
- `gc3j` - Comment out current line + 3 lines below
- `gc` in visual mode - Comment selected lines

### vim-surround
Surround text with markdown formatting:

- `ysiw*` - Surround current word with `*asterisks*` (italic)
- `ysiw**` - Surround with bold (type `*` twice)
- `ysiw]` - Surround with `[brackets]` for links
- `ysiw)` - Surround with `(parentheses)`
- `cs*_` - Change surrounding `*` to `_` (italic style)
- `ds*` - Delete surrounding `*`

**Link workflow**:
1. Type text: `example`
2. `ysiw]` → `[example]`
3. Move cursor after and type: `(https://example.com)`
4. Result: `[example](https://example.com)`

Or use visual mode:
1. Select text with `viw` or `vip`
2. Press `S*` to surround with `*`

### targets.vim
Enhanced text objects work great with markdown:

- `ci*` - Change inside asterisks (italic text)
- `ci_` - Change inside underscores
- `ci[` - Change inside brackets
- `ci(` - Change inside parentheses (link URLs)
- `da*` - Delete around asterisks (including the `*`)
- `di"` - Change inside quotes

More advanced:
- `cin[` - Change inside **next** `[brackets]` on the line
- `cil[` - Change inside **last** `[brackets]` on the line

### markdown-simple (Your New Plugin)
**Shortcuts**:
- `#` - Increase heading level (cycles: text → H1 → H2 → ... → H6 → text)
- `@` - Decrease heading level (cycles: text → H6 → H5 → ... → H1 → text)

---

## Common Workflows

### Creating a Link
```
1. Type text: "Click here"
2. viw (select word) or vip (select paragraph)
3. S] → wraps in [Click here]
4. a(https://example.com)<Esc> → [Click here](https://example.com)
```

### Formatting Text
```
*italic*       - ysiw* or S* in visual mode
**bold**       - Select text, S*, then manually add second *
`code`         - ysiw` or S` in visual mode
~~strike~~     - Select text, S~, then add second ~
```

### Quick Commenting
```
gcc           - Comment/uncomment current line
gcap          - Comment out current paragraph
gc}           - Comment from cursor to end of paragraph
```

### Heading Navigation
```
[[            - Jump to previous heading
]]            - Jump to next heading
gO            - Show document outline (TOC)
#             - Increase heading level (your plugin)
@             - Decrease heading level (your plugin)
```

### List Editing
```
o             - New line maintains list formatting
gq            - Reformat selected list/paragraph
```

---

## Tips

1. **Spell checking**: Add to vimrc for markdown:
   ```vim
   autocmd FileType markdown setlocal spell
   ```

2. **Disable markdown plugin mappings**: If you don't want `[[` and `]]`:
   ```vim
   let g:no_markdown_maps = 1
   ```

3. **Preview markdown**: Use external tools like:
   ```bash
   # In terminal while editing
   glow README.md
   # Or install a preview plugin
   ```

4. **Copilot enabled**: Your vimrc already enables Copilot for markdown files!

---

## Summary: Most Useful Shortcuts

| Shortcut | Action |
|----------|--------|
| `[[` / `]]` | Previous/Next heading |
| `gO` | Show TOC/outline |
| `#` / `@` | Increase/Decrease heading level |
| `gcc` | Toggle comment |
| `ysiw*` | Italic word under cursor |
| `ysiw]` | Wrap in brackets |
| `ci*` | Change italic text |
| `gq` | Reformat paragraph |
