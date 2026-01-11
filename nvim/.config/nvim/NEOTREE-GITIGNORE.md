# Neo-tree: Showing Gitignored Files

## What Was Changed

Created `/home/andy/.config/nvim/lua/plugins/neo-tree.lua` to configure neo-tree to show gitignored files in the file explorer.

## Key Settings

```lua
hide_gitignored = false  -- Shows gitignored files like terraform.tfvars
hide_dotfiles = false    -- Shows dotfiles like .gitignore
visible = true           -- Makes filtered items visible
```

## How to Use

### After Restarting Neovim

1. **Restart nvim** to load the new configuration:
   ```bash
   # Exit nvim and reopen
   :q
   nvim
   ```

2. **Open Neo-tree** (if not already open):
   - Press `<leader>e` (usually Space + e)
   - Or run `:Neotree toggle`

3. **Your `terraform.tfvars` should now be visible** in the explorer!

### Neo-tree Keybindings

While in Neo-tree window:

| Key | Action |
|-----|--------|
| `H` | Toggle hidden/gitignored files (if you want to hide them temporarily) |
| `I` | Toggle gitignore filter on/off |
| `a` | Add a new file |
| `d` | Delete file |
| `r` | Rename file |
| `y` | Copy file |
| `x` | Cut file |
| `p` | Paste file |
| `R` | Refresh |
| `?` | Show help with all keybindings |

### Visual Indicators

Gitignored files will be shown but may have:
- A different color/dimmed appearance
- An icon: `` (indicating ignored status)

This way you can see them in the explorer but still know they're gitignored.

## Important Notes

### Git Status Still Works

- `terraform.tfvars` is still in `.gitignore`
- It will NOT be committed to git
- You can see it in nvim, but git will ignore it
- Run `git status` to verify it's still ignored

### If You Want to Hide Gitignored Files Again

**Option 1: Toggle in Neo-tree**
- Press `H` while in Neo-tree window to toggle hidden files

**Option 2: Change Config**
Edit `/home/andy/.config/nvim/lua/plugins/neo-tree.lua`:
```lua
hide_gitignored = true,  -- Change to true to hide gitignored files
```

Then restart nvim.

## Troubleshooting

### Still Can't See terraform.tfvars?

1. **Make sure the file exists:**
   ```bash
   ls -la IaC/service-maint-switch/terraform.tfvars
   ```

2. **Refresh Neo-tree:**
   - In Neo-tree window, press `R`

3. **Check if you're in the right directory:**
   - Neo-tree shows the current working directory
   - Use `:pwd` to check current directory
   - Use `:cd /path/to/your/project` to change directory

4. **Verify the config loaded:**
   ```vim
   :lua print(vim.inspect(require("neo-tree").config.filesystem.filtered_items.hide_gitignored))
   ```
   Should print `false`

5. **Full reload:**
   ```vim
   :Lazy reload neo-tree.nvim
   ```

### Alternative: Use Telescope to Open the File

If you still have trouble, you can use Telescope to open gitignored files:

```vim
" Find files including gitignored
:Telescope find_files hidden=true no_ignore=true

" Or add a keybinding in keymaps.lua:
vim.keymap.set("n", "<leader>fA", function()
  require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end, { desc = "Find All Files (including gitignored)" })
```

## Snacks File Browser

You also have snacks file browser configured at `/home/andy/.config/nvim/lua/plugins/snacks-file-browser.lua`.

The snacks browser is already configured to show gitignored files:
```lua
gitignore = false,  -- Don't filter gitignored files
```

If you prefer to use snacks instead of neo-tree, you can disable neo-tree.

## Which File Explorer Am I Using?

LazyVim uses **neo-tree** by default. To check:

```vim
" Open neo-tree
<leader>e  or  :Neotree toggle

" If you want to use snacks explorer instead
:lua Snacks.explorer.toggle()
```

## Make Snacks Your Default (Optional)

If you prefer snacks explorer, edit `/home/andy/.config/nvim/lua/plugins/neo-tree.lua`:

```lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  enabled = false,  -- Disable neo-tree
}
```

And add a keybinding for snacks in your keymaps.lua:
```lua
vim.keymap.set("n", "<leader>e", function()
  require("snacks").explorer.toggle()
end, { desc = "Toggle Explorer (Snacks)" })
```
