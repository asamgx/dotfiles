# AGENTS.md

Guide for AI agents working in this dotfiles repository.

## Repository Overview

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) for macOS. Configurations are user/machine-agnostic using `$HOME` for portability.

**Target platform**: macOS (Apple Silicon - Homebrew at `/opt/homebrew`)

## Directory Structure

```
dotfiles/
├── _brew_air/              # Brewfile for MacBook Air
├── _brew_mini/             # Brewfile for Mac mini
├── _brew_pro/              # Brewfile for MacBook Pro
├── stow/                   # Stow configuration (.stowrc, .stow-global-ignore)
│
│ # Stow packages (each directory mirrors $HOME structure):
├── aerospace/              # Tiling window manager
├── brewsync/               # brewsync config + ignore list (shared, current_machine: auto)
├── claude/                 # Claude AI settings
├── colorscripts/           # Shell color scripts shown at shell start (copied from shell-color-scripts, see CREDITS.md)
├── ghostty/                # Terminal emulator
├── git/                    # Git configuration
├── k9s/                    # Kubernetes UI
├── lazygit/                # Git TUI
├── nap/                    # Code snippet manager
├── nvim/                   # Neovim (LazyVim)
├── ssh/                    # SSH client config (reference only, never stowed)
├── starship/               # Shell prompt
├── tmux/                   # Terminal multiplexer
├── vscode/                 # VS Code
├── yazi/                   # File manager
├── zed/                    # Zed editor
└── zsh/                    # Zsh shell config
```

## Essential Commands

### Stow Operations

```bash
# Stow a package (create symlinks to $HOME)
stow <package>              # e.g., stow zsh, stow nvim

# Stow multiple packages
stow zsh nvim tmux git

# Stow all packages
stow */

# Unstow (remove symlinks)
stow -D <package>

# Restow (refresh symlinks after updates)
stow -R <package>

# Dry run with verbose output
stow -nv <package>

# Adopt existing files into stow package
stow --adopt <package>
```

**Note**: `.stowrc` sets `--target=$HOME/` by default.

### Homebrew Package Management

```bash
# Each machine stows its own brew package once, symlinking ~/Brewfile into the repo:
stow _brew_air   # or _brew_mini / _brew_pro on those machines

# Install from this machine's Brewfile (alias: brewinstall)
brew bundle --file=~/Brewfile

# Export current packages (alias: brewdump) — brewsync writes this machine's _brew_*/Brewfile
brewsync dump

# Cleanup packages not in Brewfile
brew bundle cleanup --file=_brew_air/Brewfile --dry-run  # preview
brew bundle cleanup --file=_brew_air/Brewfile            # execute
```

### VS Code Extensions

VS Code extensions are tracked in each machine's Brewfile as `vscode "..."` entries, managed by brewsync (`brewsync dump`).

### Shell Configuration

```bash
# Reload zsh config
source ~/.zshrc   # or alias: rezsh

# Edit zsh config
nvim ~/.zshrc     # or alias: zshconfig
```

## Machine-Specific Configuration

The `.zshrc` detects the machine via hostname:

```bash
case "$(scutil --get LocalHostName)" in
  "Andrews-MacBook-Air") export MACHINE="air" ;;
  "Andrews-Mac-mini")    export MACHINE="mini" ;;
  "Andrews-MacBook-Pro") export MACHINE="pro" ;;
  *)                     export MACHINE="unknown" ;;
esac
```

Separate Brewfiles exist for each machine; each machine stows only its own package, which symlinks `~/Brewfile` to the right file (`brewinstall` then operates on `~/Brewfile`; `brewdump` runs `brewsync dump`):
- `_brew_air/Brewfile` - MacBook Air (`stow _brew_air`)
- `_brew_mini/Brewfile` - Mac mini (`stow _brew_mini`)
- `_brew_pro/Brewfile` - MacBook Pro (`stow _brew_pro`)

## Tool Configuration Details

### Neovim

- **Framework**: LazyVim
- **Config location**: `nvim/.config/nvim/`
- **Plugin manager**: lazy.nvim
- **Plugins**: `lua/plugins/` directory
- **Language-specific**: `lua/plugins/lang/` (Go, Python)
- **Extras enabled**: harpoon2, copilot, copilot-chat, dap, Go, Python, TypeScript, SQL, eslint

### Tmux

- **Plugin manager**: TPM (Tmux Plugin Manager)
- **Theme**: Catppuccin (macchiato flavor)
- **Prefix**: `Ctrl+b` (local), `Ctrl+a` (over SSH)
- **Key plugins**: resurrect, continuum, vim-tmux-navigator, fzf-url
- **Reload config**: `prefix + r`

Bootstrap TPM automatically if missing:
```bash
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'"
```

### Zsh

- **Prompt**: Starship
- **Plugins** (via Homebrew):
  - zsh-syntax-highlighting
  - zsh-autosuggestions
  - zsh-you-should-use
  - zsh-history-substring-search
- **Integrations**: zoxide (smart cd), fzf, thefuck, pyenv, nvm, tmuxifier

### Git

- **Delta** for diff highlighting
- **Conditional includes** for work repos:
  ```
  [includeIf "gitdir:~/Code/pulse/"]
      path = ~/.gitconfig-shadow
  ```

## Useful Shell Aliases

From `.zshrc`:

| Alias | Command |
|-------|---------|
| `l` | `eza -l --icons --git -a` |
| `lt` | `eza --tree --level=2 --long --icons --git` |
| `vi` | `nvim` |
| `gst` | `git status` |
| `glog` | Pretty git log graph |
| `gc` | `git commit -m` |
| `gp` | `git push origin HEAD` |
| `rezsh` | `source ~/.zshrc` |
| `lcc` | `claude` |
| `dco` | `docker compose` |

## Key Conventions

### Adding New Stow Packages

1. Create directory matching package name: `mkdir myapp`
2. Mirror the `$HOME` structure inside:
   ```
   myapp/
   └── .config/
       └── myapp/
           └── config.yaml
   ```
3. Stow it: `stow myapp`

### Files Ignored by Stow

Per `.stow-global-ignore`:
- `README.*`, `LICENSE.*`, `COPYING`
- `.git`, `.gitignore`, `.gitmodules`
- `.DS_Store`
- `TODO.*`, `*.secrets.*`

### Theme

Catppuccin theme is used across multiple tools:
- Neovim (colorscheme.lua)
- Tmux (macchiato flavor)
- k9s (multiple variants available)
- Yazi, Zed

## Development Languages

The Brewfiles include tooling for:

| Language | Tools |
|----------|-------|
| **Python** | pyenv, pyenv-virtualenv, pipx, ruff, uv |
| **Go** | golang, golangci-lint, air, delve, gopls, staticcheck |
| **Node.js** | nvm, bun, pnpm |
| **TypeScript** | via Node.js tooling |

## Gotchas

1. **Stow conflicts**: If a file already exists at the target, stow will fail. Use `stow --adopt` to move existing files into the package, or manually backup/remove them first.

2. **Brewfile machine-specific**: Use the correct Brewfile for your machine (`_brew_air`, `_brew_mini`, or `_brew_pro`).

3. **SSH prefix change**: Tmux automatically switches prefix from `Ctrl+b` to `Ctrl+a` when over SSH to avoid conflicts with nested sessions.

4. **Go paths**: `GOROOT` and `GOPATH` are set in `.zshrc`. GOROOT points to Homebrew's Go installation.

## Troubleshooting

### Broken Symlinks

```bash
# Find broken symlinks in home
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print

# Restow the package
stow -R <package>
```

### Check What's Stowed

```bash
ls -la ~ | grep "^l"           # List all symlinks
ls -la ~/.zshrc                # Check specific file
```
