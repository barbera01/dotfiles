# Fixing Neo-tree Icon Issues

## What Was Fixed

### 1. Neo-tree Configuration (`lua/plugins/neo-tree.lua`)
- Added explicit icon definitions for folders and files
- Added custom icon rendering component to fix expand/collapse issues
- Ensured nvim-web-devicons dependency is loaded
- Added expander icons for tree navigation

### 2. Nvim Options (`lua/config/options.lua`)
- Set `vim.g.have_nerd_font = true` to tell nvim to use Nerd Font icons
- Added UTF-8 encoding settings

### 3. Tmux Configuration (`~/.tmux.conf`)
- Added proper terminal settings for true color support
- Added UTF-8 support flags
- Set default terminal to `tmux-256color`

## How to Apply the Fixes

### Step 1: Restart Tmux
```bash
# Kill all tmux sessions (save your work first!)
tmux kill-server

# Or just source the new config
tmux source-file ~/.tmux.conf
```

### Step 2: Restart Neovim
```bash
# Exit nvim
:q

# Start nvim again
nvim
```

### Step 3: Sync Plugins
```vim
:Lazy sync
```

### Step 4: Test Icons
Open neo-tree and expand folders:
```vim
:Neotree toggle
```

## Expected Results

You should now see:
- **Folder icons:**  (closed),  (open)
- **File icons:** Language-specific icons (e.g.,  for Python,  for JavaScript)
- **Git status icons:** ✚ (added),  (modified),  (ignored)
- **Expander icons:**  (collapsed),  (expanded)

## Troubleshooting

### 1. Still Seeing Broken Icons?

**Check your terminal font:**

Most terminals need to be configured to use a Nerd Font. You have JetBrains Mono Nerd Font installed.

**For common terminals:**

**Windows Terminal:**
```json
{
  "profiles": {
    "defaults": {
      "font": {
        "face": "JetBrainsMono Nerd Font",
        "size": 11
      }
    }
  }
}
```

**iTerm2 (Mac):**
- Preferences → Profiles → Text → Font
- Select "JetBrainsMono Nerd Font"

**Alacritty:**
```yaml
font:
  normal:
    family: "JetBrainsMono Nerd Font"
  size: 11.0
```

**Kitty:**
```conf
font_family JetBrainsMono Nerd Font
font_size 11.0
```

**VS Code Terminal:**
```json
{
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font"
}
```

### 2. Icons Still Missing After Font Change?

**Test icon rendering in terminal:**
```bash
# These should show icons (not boxes or question marks):
echo "        󰁕  󰄱  "
```

If you see boxes [], your terminal isn't using the Nerd Font.

### 3. Test nvim-web-devicons Directly

In nvim:
```vim
:lua print(vim.inspect(require("nvim-web-devicons").get_icon("test.py")))
```

Should output something like: `{ "", "DevIconPy" }`

### 4. Verify Nerd Font is Detected

In nvim:
```vim
:lua print(vim.g.have_nerd_font)
```

Should output: `true`

### 5. Check Terminal Info

In nvim:
```vim
:echo $TERM
" Should show: tmux-256color or screen-256color

:set encoding?
" Should show: encoding=utf-8
```

### 6. Force Refresh Icons

```vim
" Reload neo-tree
:Lazy reload neo-tree.nvim

" Rebuild icon cache
:lua require("nvim-web-devicons").setup({})

" Refresh neo-tree
:Neotree close
:Neotree toggle
```

### 7. Check for Icon Plugin Conflicts

LazyVim uses mini.icons by default, but we're explicitly using nvim-web-devicons.

```vim
" Check which icon provider is active
:lua print(vim.inspect(package.loaded["mini.icons"]))
:lua print(vim.inspect(package.loaded["nvim-web-devicons"]))
```

If mini.icons is interfering, you can disable it in `lua/plugins/neo-tree.lua`:
```lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    { "echasnovski/mini.icons", enabled = false }, -- Disable mini.icons
  },
  -- ... rest of config
}
```

## Testing Your Setup

### Test 1: Basic Icon Test
```bash
# Run this in your terminal (not in nvim)
printf "\ue5fe \ue5fb \ue7a2 \uf489 \uf7a1\n"
```

**Expected:** Should show various folder and file icons
**If you see:** Boxes or question marks → Terminal font issue

### Test 2: Neo-tree Icon Test
1. Open nvim: `nvim`
2. Open neo-tree: `<leader>e` or `:Neotree toggle`
3. Navigate to a folder with different file types (`.py`, `.js`, `.md`, `.json`)
4. Expand the folder (press `<space>` or `<cr>` on the folder)

**Expected:**
- Each file should have a unique icon
- Folders should show  when closed,  when open
- Git status icons should appear next to modified files

### Test 3: Icon Refresh Test
1. Create a new file in neo-tree: press `a`
2. Name it `test.py`
3. The icon should immediately show the Python icon ()

## Manual Icon Configuration

If icons still don't work, you can use simple ASCII characters instead:

Edit `lua/plugins/neo-tree.lua`:
```lua
default_component_configs = {
  icon = {
    folder_closed = "+",
    folder_open = "-",
    folder_empty = "○",
    folder_empty_open = "●",
    default = "•",
  },
  indent = {
    expander_collapsed = "+",
    expander_expanded = "-",
  },
},
```

## Common Issues

### Icons work in other apps but not nvim
- Check nvim options: `:set encoding?` should be `utf-8`
- Check nvim font setting: `:lua print(vim.g.have_nerd_font)` should be `true`

### Icons work sometimes but disappear on expand
- This was the main issue we fixed
- The custom `components.icon` function in neo-tree.lua handles this
- Make sure you reloaded nvim after the config change

### Different icons than expected
- Multiple icon plugins can conflict (mini.icons vs nvim-web-devicons)
- Our config explicitly uses nvim-web-devicons
- Check `:Lazy` to see which plugins are loaded

### Icons show in neo-tree but not in other plugins
- Some plugins may need separate configuration
- Check their docs for icon settings

## Get More Icons

If you want more or different icons, you can customize them:

```vim
:lua require("nvim-web-devicons").setup({
  override = {
    tf = {
      icon = "󱁢",
      color = "#5f43e9",
      cterm_color = "98",
      name = "Terraform"
    },
    tfvars = {
      icon = "󱁢",
      color = "#5f43e9",
      cterm_color = "98",
      name = "TerraformVars"
    },
  }
})
```

Add this to your `lua/plugins/neo-tree.lua` or create a separate file.

## Still Having Issues?

1. **Check terminal emulator** - Ensure it supports Unicode and Nerd Fonts
2. **Test terminal font** - Run the icon test commands above
3. **Verify font installation** - Run: `fc-list | grep -i "nerd"`
4. **Check locale** - Run: `locale` (should show UTF-8)
5. **Try a different terminal** - Sometimes specific terminals have issues

## Verification Checklist

- [ ] JetBrains Mono Nerd Font installed (`fc-list | grep -i nerd`)
- [ ] Terminal configured to use Nerd Font
- [ ] Tmux config updated and reloaded
- [ ] Nvim config updated (`have_nerd_font = true`)
- [ ] Nvim plugins synced (`:Lazy sync`)
- [ ] Neo-tree opened and folders expanded
- [ ] Icons displaying correctly

## References

- [Nerd Fonts](https://www.nerdfonts.com/)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)
