# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

1. Install GNU Stow:

   ```bash
   # macOS
   brew install stow

   # Linux
   sudo apt install stow  # Debian/Ubuntu
   sudo pacman -S stow    # Arch
   ```

2. Clone this repository:

   ```bash
   git clone https://github.com/barbera01/dotfiles.git ~/repos/gh/dotfiles
   cd ~/repos/gh/dotfiles
   ```

3. Stow the packages you want:
   ```bash
   stow -t ~ alacritty
   ```

## Packages

- **alacritty** - Terminal emulator configuration
- **btop** - System resource monitor
- **herdr** - Terminal multiplexer configuration

## Usage

### Installing a package

```bash
stow -t ~ <package-name>
```

### Removing a package

```bash
stow -D -t ~ <package-name>
```

### Re-stowing (useful after updates)

```bash
stow -R -t ~ <package-name>
```

## Adding new packages

1. Create a directory with the package name
2. Mirror the structure from `$HOME`

### For .config files:
```
package-name/
└── .config/
    └── package-name/
        └── config-file
```

### For single files in home directory:
```
tmux/
└── .tmux.conf
```

or

```
git/
├── .gitconfig
└── .gitignore_global
```

3. Stow it:
   ```bash
   stow -t ~ package-name
   ```

## Structure

Each package directory mirrors the structure of your home directory. When you run `stow <package>`, it creates symlinks from your home directory to the files in this repo.

For example, `alacritty/.config/alacritty/alacritty.toml` symlinks to `~/.config/alacritty/alacritty.toml`.
