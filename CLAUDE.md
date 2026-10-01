# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Pending Per-Machine Steps

Before other work on a machine, read `CHANGELOG.md` and run any steps listed for this machine (`$MACHINE`) that its "Done on" line doesn't include yet.

### When to add a CHANGELOG entry

The other machines (`air`, `mini`, `pro`) only get what `git pull` brings. Whenever a change needs anything more than a pull to take effect on another machine, add an entry to `CHANGELOG.md` in the same change, so the agent there picks it up. Examples:

- stowing, unstowing or re-stowing a package (new, removed or renamed packages, files replacing symlinks)
- installing, uninstalling, trusting or reinstalling Homebrew packages, or anything a `brewsync dump` should pick up
- files outside this repo (e.g. `~/.config/*` that isn't stowed, `/opt`, `/usr/local`, app data)
- commands needing `sudo` or the user's password, app restarts, plugin cleanups (`:Lazy clean`)
- updating or reinstalling tools built from other repos (e.g. `brewsync`)

A change that works right after `git pull` (an edited config of an already-stowed package) needs no entry.

Entry format (newest first): `## YYYY-MM-DD — title`, a `Done on:` line, `### What changed in the repo` (what and why), and `### Steps for each machine` as copy-pasteable commands that check before acting, are safe to re-run, and say how to verify. Mark steps that need `sudo` as user-run. List the machine where the change was made under `Done on`, noting any step still open there (`**pro**: all except step 2 (reason)`). When finishing a step on a machine, update its `Done on` line.

## Repository Overview

Personal dotfiles managed with GNU Stow for macOS (Apple Silicon - Homebrew at `/opt/homebrew`). Configurations are user/machine-agnostic using `$HOME` for portability.

## Essential Commands

### Stow Operations

```bash
stow <package>              # Create symlinks to $HOME (e.g., stow zsh, stow nvim)
stow -D <package>           # Remove symlinks
stow -R <package>           # Refresh symlinks after updates
stow -nv <package>          # Dry run with verbose output
stow --adopt <package>      # Adopt existing files into stow package
stow */                     # Stow all packages
```

Note: `.stowrc` sets `--target=$HOME/` by default.

### Homebrew Package Management

```bash
stow _brew_air   # One per machine: symlinks ~/Brewfile to that machine's Brewfile
                 # (_brew_mini on the Mac mini, _brew_pro on the MacBook Pro)
brewinstall      # Alias: brew bundle --file=~/Brewfile
brewdump         # Alias: brewsync dump (writes this machine's _brew_*/Brewfile; check `brewsync doctor` first)
```

### VS Code Extensions

VS Code extensions are tracked in each machine's Brewfile as `vscode "..."` entries, managed by brewsync (`brewsync dump`).

The `brewsync` package shares `~/.config/brewsync/config.yaml` and `ignore.yaml` across machines; `current_machine: auto` picks the machine by `scutil --get LocalHostName`. Check `brewsync doctor` shows the right machine before `brewsync dump`.

## Architecture

### Directory Structure

Each top-level directory is a stow package that mirrors `$HOME` structure:
- `zsh/`, `nvim/`, `tmux/`, `git/` - Core development configs
- `vscode/`, `zed/` - Editor configs
- `_brew_air/`, `_brew_mini/`, `_brew_pro/` - Machine-specific Brewfiles
- `ssh/` - Reference copy of `~/.ssh/config` only; never stow it

### Machine Detection

The `.zshrc` detects machine via hostname and sets `$MACHINE` to `air`, `mini`, `pro`, or `unknown`. Each machine stows its own `_brew_*` package so `~/Brewfile` symlinks to the right machine-specific Brewfile; `brewinstall` operates on `~/Brewfile`; `brewdump` (brewsync) writes the Brewfile configured for the detected machine.

### Key Tool Configurations

- **Neovim**: LazyVim framework, plugins in `lua/plugins/`, language configs in `lua/plugins/lang/`
- **Tmux**: TPM plugin manager, Catppuccin theme, prefix `Ctrl+b` (local) / `Ctrl+a` (SSH)
- **Zsh**: Starship prompt, plugins via Homebrew, integrations with zoxide, fzf, pyenv, nvm

### Files Ignored by Stow

Per `.stow-global-ignore`: `README.*`, `LICENSE.*`, `.git*`, `.DS_Store`, `TODO.*`, `*.secrets.*`

## Conventions

### Adding New Stow Packages

1. Create directory: `mkdir myapp`
2. Mirror `$HOME` structure inside (e.g., `myapp/.config/myapp/config.yaml`)
3. Run: `stow myapp`

### Catppuccin Theme

Used across Neovim, Tmux, k9s, Yazi, and Zed.
