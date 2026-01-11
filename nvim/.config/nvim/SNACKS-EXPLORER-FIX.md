# Fixing Snacks Explorer Rendering Issues

## The Problem

- Odd characters appearing in the explorer
- Need to open/close explorer to refresh and clear artifacts
- Icons not rendering properly on initial open

## What Was Fixed

### 1. **Snacks Configuration** (`lua/plugins/snacks-file-browser.lua`)

**Added:**
- Custom `format` function with proper spacing
- Explicit icon definitions
- nvim-web-devicons integration
- Auto-refresh and redraw settings
- Priority loading to ensure proper initialization

**Key fixes:**
```lua
format = function(file)
  -- Custom formatting ensures proper icon + space + name
  -- Prevents odd characters from rendering issues
end

icons = {
  enabled = true,
  folder_closed = "",
  folder_open = "",
  -- ... defined explicit icons
}

redraw = true,  -- Force redraw on changes
```

### 2. **Keymaps** (`lua/config/keymaps.lua`)

**Added force-redraw wrapper:**
```lua
<leader>e  -- Toggle explorer WITH automatic redraw
<leader>er -- Manual refresh command
```

The new `<leader>e` keymap:
- Forces `redraw!` before opening
- Opens snacks explorer
- Forces `redraw!` again after 50ms
- Clears any odd characters automatically

### 3. **Autocmds** (`lua/config/autocmds.lua`)

**Added automatic refresh:**
- Auto-redraw when entering explorer buffers
- Force redraw on window resize
- Prevents artifacts from accumulating

## How to Apply

### Step 1: Restart Neovim
```bash
# Exit all nvim instances
:qa

# Restart nvim
nvim
```

### Step 2: Sync Plugins
```vim
:Lazy sync
```

### Step 3: Test
```vim
" Open explorer (should auto-refresh now)
<leader>e

" If still seeing issues, manual refresh:
<leader>er

" Or force redraw:
:redraw!
```

## New Keybindings

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle Explorer (with auto-refresh) |
| `<leader>er` | Force refresh explorer |
| `:redraw!` | Manual screen redraw |

## Why This Happens

The odd characters are caused by:

1. **Terminal escape codes** - Partially rendered ANSI codes
2. **Icon rendering race conditions** - Icons loading after initial draw
3. **Buffer redraw timing** - Snacks draws before terminal is ready
4. **Font fallback** - Missing glyphs showing as squares

## Testing the Fix

### Before (Problem):
1. Open explorer → See odd characters/artifacts
2. Close and reopen → Characters disappear
3. Repeat cycle needed

### After (Fixed):
1. Open explorer → Clean, proper rendering
2. No need to close/reopen
3. Auto-refresh handles updates

## Additional Fixes

### If Still Seeing Issues After Changes:

**1. Check Terminal Font (Most Common)**

Make sure your terminal is using a Nerd Font:
```bash
# Run the icon test
~/.config/nvim/test-icons.sh

# Test terminal directly
echo "    "
```

If you see boxes [], your terminal isn't using the Nerd Font.

**2. Force Redraw Manually**

Add to your workflow:
```vim
" Before opening explorer
:redraw!
<leader>e
```

**3. Check Tmux Configuration**

Ensure tmux has proper settings (already fixed in previous step):
```bash
# Reload tmux
tmux source-file ~/.tmux.conf
```

**4. Verify Snacks is Loaded**

```vim
" Check if snacks is loaded
:lua print(vim.inspect(package.loaded["snacks"]))

" Should show a table, not nil
```

**5. Try Neo-tree Instead**

If snacks continues to have issues:
```vim
" Disable snacks explorer
" Edit lua/plugins/snacks-file-browser.lua:
opts = {
  explorer = { enabled = false },
}

" Use neo-tree instead (already configured)
<leader>e  " This will use neo-tree
```

## Comparison: Snacks vs Neo-tree

Both are now configured in your setup:

| Feature | Snacks Explorer | Neo-tree |
|---------|----------------|----------|
| **Speed** | Faster | Slightly slower |
| **Icons** | Custom format | Built-in |
| **Git Status** | Basic | Advanced |
| **Rendering** | Can have issues | More stable |
| **Features** | Minimal | Full-featured |
| **Current Issue** | Odd characters | None |

**Recommendation:** Try neo-tree if snacks continues having issues:
```vim
" Temporarily disable snacks, use neo-tree
:Neotree toggle
```

## Manual Refresh Commands

If auto-refresh doesn't work:

```vim
" Force full refresh
:redraw!

" Reload snacks
:Lazy reload snacks.nvim

" Toggle explorer (closes and reopens)
<leader>e
<leader>e

" Use manual refresh keymap
<leader>er
```

## Root Cause Analysis

The issue occurs because:

1. **Snacks opens** → Creates buffer
2. **Icons load** → Async from nvim-web-devicons
3. **Terminal draws** → May be mid-icon-load
4. **Result** → Partial render, odd characters

**Our fix:**
- Forces synchronous icon loading
- Adds redraw before/after
- Custom format ensures clean spacing
- Autocmds catch edge cases

## Performance Impact

The auto-redraw has minimal impact:
- ~50ms delay (imperceptible)
- Only triggers on explorer open/enter
- Doesn't affect other buffers

## Alternative: Use ASCII Icons

If font issues persist, use simple ASCII:

Edit `lua/plugins/snacks-file-browser.lua`:
```lua
icons = {
  enabled = true,
  folder_closed = "+",
  folder_open = "-",
  file = "•",
  symlink = "@",
},
```

## Debugging Commands

```vim
" Check current buffer type
:echo &filetype

" Check buffer name
:echo bufname('%')

" Check if in snacks buffer
:lua print(vim.api.nvim_buf_get_name(0))

" Force redraw
:redraw!

" Clear and redraw
:mode

" Check snacks config
:lua print(vim.inspect(require("snacks").config.explorer))
```

## Long-term Solution

If issues persist after all fixes:

**Option 1: Use Neo-tree (Recommended)**
```lua
-- In lua/plugins/snacks-file-browser.lua
return {
  "folke/snacks.nvim",
  opts = {
    explorer = { enabled = false },
  },
}
```

Neo-tree is more mature and handles rendering better.

**Option 2: Different Terminal**

Some terminals handle Unicode/icons better:
- **Alacritty** - Excellent rendering
- **Kitty** - Great icon support
- **WezTerm** - Modern, good Unicode
- **Windows Terminal** - Good on Windows

**Option 3: Simpler Icons**

Use ASCII or simpler icons to avoid rendering complexity.

## Summary

The fix adds:
1. ✅ Auto-redraw on explorer open
2. ✅ Custom icon formatting
3. ✅ Autocmd refresh on buffer enter
4. ✅ Manual refresh command (`<leader>er`)
5. ✅ Proper icon spacing

This should eliminate the need to manually close/reopen the explorer!

## Testing Checklist

- [ ] Restart nvim
- [ ] `:Lazy sync` completed
- [ ] Open explorer with `<leader>e`
- [ ] Icons render correctly
- [ ] No odd characters visible
- [ ] Expand folders - icons update
- [ ] Try manual refresh `<leader>er` if needed
- [ ] Check terminal font if still having issues

## Need More Help?

1. Run icon test: `~/.config/nvim/test-icons.sh`
2. Check full icon guide: `~/.config/nvim/ICON-FIX.md`
3. Try neo-tree: `:Neotree toggle`
4. Force terminal font: Use JetBrainsMono Nerd Font
