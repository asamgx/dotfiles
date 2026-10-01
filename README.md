# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) for macOS. These configurations are user and machine-agnostic, using `$HOME` environment variable for portability.

## New Machine Setup

Machines are `air`, `mini` and `pro`, detected from `scutil --get LocalHostName` (see the `MACHINE`
case near the top of `zsh/.zshrc`). For a new machine, add its hostname there and in
`brewsync/.config/brewsync/config.yaml`, and create its `_brew_<name>/Brewfile` (e.g. copy one and
trim it) before step 6.

1. **Command line tools and Homebrew**

   ```bash
   xcode-select --install
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   brew install stow git
   ```

2. **Set the hostname** if it doesn't match the one in `zsh/.zshrc` (case doesn't matter):

   ```bash
   scutil --get LocalHostName
   sudo scutil --set LocalHostName Andrews-MacBook-Air   # only if it needs changing
   ```

3. **Clone this repo** (HTTPS works before SSH keys are set up; switch the remote to
   `git@github.com:asamgx/dotfiles.git` later):

   ```bash
   git clone https://github.com/asamgx/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

4. **Install packages** from this machine's Brewfile (taps are trusted via `trusted: true` in it):

   ```bash
   stow stow _brew_air          # _brew_mini / _brew_pro on those machines; links ~/Brewfile
   brew bundle --file=~/Brewfile
   ```

5. **Link the shell config and open a new shell.** Move aside anything stow reports as a conflict
   (e.g. a `~/.zprofile` the Homebrew installer created) first:

   ```bash
   stow -nv zsh                 # dry run; lists conflicts
   stow zsh && exec zsh -l
   ```

6. **Link everything else.** `dotstow` (defined in `.zshrc`) stows every package except `ssh`
   (reference copy only) and the other machines' Brewfiles:

   ```bash
   dotstow -nv                  # dry run
   dotstow
   ```

7. **brewsync** isn't in a Brewfile; it's built from source (Go comes from the Brewfile):

   ```bash
   git clone https://github.com/asamgx/brewsync.git ~/code/brewsync
   cd ~/code/brewsync && make install
   brewsync doctor              # "Current machine" must show this machine before any brewsync dump
   ```

8. **Editors and tmux**

   ```bash
   nvim --headless "+Lazy! sync" +qa    # install Neovim plugins
   tmux                                 # TPM and its plugins install themselves on first start
   ```

9. **Machine-only settings** go in untracked files that the tracked configs load if present:
   `~/.zshrc.local` (sourced last by `.zshrc`; secrets, machine-specific env) and
   `~/.gitconfig-local` (included by `.gitconfig`). `ssh/.ssh/config` is a reference copy; copy what
   you need into `~/.ssh/config` by hand.

`CHANGELOG.md` lists migration steps for machines that were already set up. A machine set up from
this checklist already matches the latest state, so add it to each entry's "Done on" line instead of
running those steps.

## What's Included

### Shell & Terminal
- **zsh** - Shell configuration with aliases, functions, and environment setup
- **starship** - Cross-shell prompt configuration
- **tmux** - Terminal multiplexer configuration
- **ghostty** - Terminal emulator settings

### Development Tools
- **nvim** - Neovim configuration with LazyVim
- **git** - Git configuration and aliases
- **lazygit** - Terminal UI for git commands
- **ssh** - SSH client configuration (reference copy only, not stowed)

### Editors & IDEs
- **vscode** - VS Code settings and keybindings
- **zed** - Zed editor configuration

### Utilities
- **yazi** - Terminal file manager
- **nap** - Code snippet manager
- **colorscripts** - Color scripts shown when a shell starts (from Derek Taylor's shell-color-scripts; credits in `colorscripts/.local/share/colorscripts/CREDITS.md`)
- **brewsync** - Shared brewsync config and ignore list (machine detected by hostname)
- **aerospace** - Tiling window manager

## Stow Commands

### Basic Usage

```bash
# Stow a single package (creates symlinks)
stow <package-name>

# Examples:
stow zsh        # Link zsh configs to $HOME
stow nvim       # Link nvim configs to $HOME/.config/nvim
stow git        # Link git configs to $HOME

# Stow multiple packages at once
stow zsh nvim tmux git

# Stow all packages for this machine (skips ssh and other machines' Brewfiles)
dotstow
```

### Removing/Unstowing

```bash
# Remove symlinks for a package
stow -D <package-name>

# Examples:
stow -D zsh     # Remove zsh symlinks
stow -D nvim    # Remove nvim symlinks

# Unstow all packages
stow -D */
```

### Restowing (Update symlinks)

```bash
# Useful after updating configs - removes old and creates new symlinks
stow -R <package-name>

# Examples:
stow -R zsh
stow -R nvim

# Restow everything
stow -R */
```

### Dry Run (Preview changes)

```bash
# See what would happen without actually doing it
stow -n <package-name>
stow -nv <package-name>  # Verbose output

# Examples:
stow -nv zsh    # Preview zsh stow operation
stow -nv */     # Preview stowing all packages
```

### Advanced Options

```bash
# Specify a different target directory (default: $HOME via .stowrc)
stow --target=/some/other/path <package-name>

# Verbose output (see what's being linked)
stow -v <package-name>

# Simulate (dry-run) with verbose output
stow -nv <package-name>

# Adopt existing files (move them into stow package)
stow --adopt <package-name>
```

## Machine-Specific Configurations

Some configurations may need to be machine-specific. Here's how to handle them:

### Strategy 1: Separate Stow Packages

Create machine-specific packages:

```
dotfiles/
├── tmux/              # Shared tmux config
├── tmux-work/         # Work machine specific
└── tmux-personal/     # Personal machine specific
```

Then stow the appropriate one:
```bash
# On work machine
stow tmux tmux-work

# On personal machine
stow tmux tmux-personal
```

### Strategy 2: Hostname-Based Conditionals

Use hostname detection in config files:

```bash
# In .zshrc or .tmux.conf
if [ "$(hostname)" = "work-machine" ]; then
    # Work-specific settings
else
    # Personal settings
fi
```

### Strategy 3: Separate Config Files

Keep a base config that sources machine-specific overrides:

```bash
# In .tmux.conf
source-file ~/.tmux.conf.$(hostname)
```

Then create:
- `.tmux.conf.work-machine`
- `.tmux.conf.personal-machine`

## Directory Structure

Each directory represents a "stow package" and mirrors the structure from `$HOME`:

```
dotfiles/
├── zsh/
│   ├── .zshrc           → $HOME/.zshrc
│   └── .zprofile        → $HOME/.zprofile
├── nvim/
│   └── .config/
│       └── nvim/        → $HOME/.config/nvim/
├── tmux/
│   └── .tmux.conf       → $HOME/.tmux.conf
└── git/
    └── .gitconfig       → $HOME/.gitconfig
```

## Configuration Notes

### Git Configuration

Update `git/.gitconfig` with your personal information:

```bash
[user]
    name = Your Name
    email = your.email@example.com
```

### Zsh Configuration

After stowing zsh configs:

```bash
# Reload shell configuration
source ~/.zshrc

# Or restart your terminal
```

### SSH Keys

The `ssh/` directory contains SSH client configuration. Your actual SSH keys should be managed separately and NOT committed to the repository.

## Updating Dotfiles

```bash
# Navigate to dotfiles directory
cd ~/dotfiles

# Pull latest changes
git pull

# Restow updated packages
stow -R <package-name>

# Or restow everything
stow -R */
```

## Backup Your Existing Configs

Before stowing, backup your existing configurations:

```bash
# Create backup directory
mkdir -p ~/.config-backup

# Backup existing configs
cp ~/.zshrc ~/.config-backup/
cp -r ~/.config/nvim ~/.config-backup/
# ... backup other configs as needed
```

## Troubleshooting

### Conflicts

If stow reports conflicts (existing files/symlinks):

```bash
# Option 1: Remove/backup the conflicting file manually
mv ~/.zshrc ~/.zshrc.backup

# Option 2: Use --adopt to move existing file into stow package
stow --adopt zsh

# Option 3: Force removal (careful!)
stow -D zsh  # Remove old symlinks
rm ~/.zshrc  # Remove conflicting file
stow zsh     # Create new symlinks
```

### Broken Symlinks

```bash
# Find broken symlinks in home directory
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print

# Remove broken symlink
rm <broken-symlink>

# Restow the package
stow -R <package-name>
```

### Check What's Stowed

```bash
# List all symlinks in your home directory
ls -la ~ | grep "^l"

# See where a specific config links to
ls -la ~/.zshrc
```

## Managing Homebrew Packages

### Export Current Packages

```bash
brewsync dump   # alias: brewdump — writes this machine's _brew_*/Brewfile
```

### Install Packages from Brewfile

```bash
cd ~/dotfiles
brew bundle --file=~/Brewfile   # alias: brewinstall
```

### Cleanup Unused Packages

```bash
# Remove packages not listed in Brewfile
brew bundle cleanup --file=~/Brewfile

# Do a dry run first
brew bundle cleanup --file=~/Brewfile --dry-run
```

## Contributing

This is a personal dotfiles repository, but feel free to fork it and adapt it to your needs!

## Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [Dotfiles Best Practices](https://dotfiles.github.io/)
- [Homebrew Documentation](https://docs.brew.sh/)

## License

MIT
