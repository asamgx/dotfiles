# Changelog

Changes that need follow-up steps on the other machines (`air`, `mini`, `pro`), newest first.
Each entry lists what changed and what to run on every machine that hasn't done it yet.
"Done on" tracks progress per machine; a machine with steps still open is listed as
`**machine**: all except step N (reason)`.

## 2026-10-01 — Shell color scripts copied into the dotfiles

Done on: **pro**.

### What changed in the repo

- New `colorscripts` package: the 11 scripts `.zshrc` used, copied unmodified from
  https://gitlab.com/dwt1/shell-color-scripts (commit `576735c`; upstream unchanged since 2023), with its
  MIT `LICENSE` and a `CREDITS.md` for the creator (Derek Taylor) and each script's author.
  Stows to `~/.local/share/colorscripts/`.
- `.zshrc` runs a random executable script from there directly with `bash` (~3 ms) instead of
  `colorscript exec <index>` (~90 ms). The old numeric indexes depended on `find` order, so other
  machines could show different scripts than intended.
- The old `sudo make install` copy (`/opt/shell-color-scripts`, `/usr/local/bin/colorscript`) is no
  longer used.

### Steps for each machine

1. `stow colorscripts`, then open a new terminal: a color script should print as before.
2. Remove the old install, if present. The user runs this in their own terminal (`sudo` needs a
   password, which an agent can't type):

   ```sh
   ls -d /opt/shell-color-scripts /usr/local/bin/colorscript ~/shell-color-scripts 2>/dev/null
   sudo rm -rf /opt/shell-color-scripts /usr/local/bin/colorscript
   rm -rf ~/shell-color-scripts      # clone; check `git -C ~/shell-color-scripts status` first
   ```

3. Mark the machine as done under "Done on" above.

## 2026-10-01 — zsh cleanup and speed-ups

Done on: **pro**.

### What changed in the repo

- `brewdump` now runs `brewsync dump` (the old `brew bundle dump --describe` fails on Homebrew 7).
- `ccat` uses `bat` (`pygmentize` isn't installed).
- `$MACHINE` detection lowercases `LocalHostName` before matching. The Mini is `Andrews-Mac-mini`;
  the shared brewsync config was corrected to that spelling (it said `Andrews-Mac-Mini`).
- Startup ~0.65 s → ~0.25 s (before `colorscript`): `$HOMEBREW_PREFIX` instead of `brew --prefix`,
  cached `compinit` (rebuilt daily; after installing new completions run `rm ~/.zcompdump && rezsh`),
  `thefuck --alias` once with `alias fk=fuck`, and nvm loaded on first `nvm` call. The default Node
  (`~/.nvm/alias/default`) is still put on PATH at startup, so `node`/`npm` work as before.
- History: `SHARE_HISTORY`, `HIST_IGNORE_ALL_DUPS`, `HIST_IGNORE_SPACE`, `HIST_REDUCE_BLANKS`, 50k entries.
- Removed: Poetry env var, `~/.zfunc` fpath, PATH lines duplicated from `.zprofile`, commented-out leftovers.
  The Android SDK block only runs if `~/Library/Android/sdk` exists.

### Steps for each other machine

1. Open a new shell after pulling, then check: `echo $MACHINE` (must be this machine), `node -v`,
   `nvm --version`, `brewdump --help` (shows brewsync dump help).
2. If `$MACHINE` is `unknown`, compare `scutil --get LocalHostName` with the `case` in `zsh/.zshrc`.
3. Mark the machine as done under "Done on" above.

## 2026-10-01 — Stow k9s, nap and a shared brewsync config

Done on: **pro**.

### What changed in the repo

- **New `brewsync` package**: `brewsync/.config/brewsync/config.yaml` and `ignore.yaml`, shared by all
  machines. `current_machine` is now `auto`: each machine finds itself by matching
  `scutil --get LocalHostName` against `machines.<name>.hostname`. `history.log` stays local (not in the package).
  brewsync saves both files in place (`os.WriteFile`), so the symlinks survive brewsync's own edits.
- **k9s and nap** were already in the repo but weren't stowed on pro, so both ran on defaults. They are
  stowed there now. k9s may rewrite `config.yaml` when it saves settings, which changes the repo file;
  review `git diff k9s/` before committing.

### Steps for each other machine

Run in `~/dotfiles` after pulling.

1. **brewsync**: keep this machine's ignore entries before replacing the files.

   ```sh
   diff ~/.config/brewsync/ignore.yaml brewsync/.config/brewsync/ignore.yaml
   ```

   If this machine has entries the repo copy lacks, add them to `brewsync/.config/brewsync/ignore.yaml`.
   Then move the local files aside and stow:

   ```sh
   mkdir -p ~/brewsync-config-backup
   mv ~/.config/brewsync/config.yaml ~/.config/brewsync/ignore.yaml ~/brewsync-config-backup/
   stow brewsync
   scutil --get LocalHostName        # must match this machine's hostname in config.yaml (case is ignored
                                     # with brewsync v0.1.5+; exact match before that)
   brewsync doctor                   # "Current machine" must show this machine
   ```

   If the hostname doesn't match, fix it in `brewsync/.config/brewsync/config.yaml` and commit.
   Never run `brewsync dump` while `doctor` shows the wrong machine.

2. **k9s**: if `~/.config/k9s/config.yaml` or `aliases.yaml` are real files (not symlinks), move them
   aside, then stow:

   ```sh
   ls -l ~/.config/k9s/
   mkdir -p ~/k9s-config-backup && mv ~/.config/k9s/config.yaml ~/.config/k9s/aliases.yaml ~/k9s-config-backup/ 2>/dev/null
   stow k9s
   ```

3. **nap**: `stow nap` (needed for `NAP_CONFIG=~/.config/nap/config.yaml` from `.zshrc` to exist).

4. Check that nothing else is half-stowed: `for p in */; do stow -nv "${p%/}" 2>&1 | grep -q "^LINK\|conflict" && echo "${p%/}"; done`
   should print nothing except `ssh` (reference only, never stow), the other machines' `_brew_*` packages,
   and `starship` (its unused `starship3.toml` isn't linked; only `starship.toml` is read).

5. Mark the machine as done under "Done on" above.

## 2026-10-01 — Remove Kulala, Cursor, Antigravity, Warp, neofetch; fix AeroSpace cask name

Done on: **pro** (all steps). **air**: tap trust only.

### What changed in the repo

- **nvim**: removed `kulala.nvim` (`lua/plugins/kulala.lua`, `lazy-lock.json` entry). Its own spec loads on
  `VimLeavePre`, and since 2026-09-30 it asks for a "kulala-core" license token via a hidden
  `inputsecret()` prompt, so `:qa` / `q` froze the terminal on quit.
- **Removed stow packages**: `cursor/`, `antigravity/`, `warp/`, `neofetch/`, `rectangle/`, `poetry/`.
- **Removed `master_code/`**: VS Code is the only editor left, so `settings.json` and `keybindings.json`
  are now plain files in `vscode/Library/Application Support/Code/User/` (were symlinks into
  `master_code/`). Dropped the Cursor-only `cursor.cpp.disabledLanguages` setting.
- **Removed `_scripts/`**: the extension scripts read `*-extensions.txt` files that were deleted in
  `bf5812f` (Dec 2025) when brewsync took over; `setup-ide-settings.sh` only maintained the
  `master_code` symlinks. VS Code extensions are tracked as `vscode "..."` lines in the Brewfiles.
- **`_brew_pro/Brewfile`**: removed `neofetch`; AeroSpace is `cask "nikitabobko/tap/aerospace"`.
- **Docs**: `CLAUDE.md`, `AGENTS.md`, `README.md` updated. `ssh/` is a reference copy only — never stow
  it (so don't use `stow */`, which would link it).

### Why AeroSpace showed up as `cask "aerospace"`

Homebrew 7 added tap trust. For a cask from an untrusted tap, `brew bundle dump` (used by
`brewsync dump`) can't read the tap's cask file and falls back to the installed copy, which has no
tap name or description, so it writes the short `cask "aerospace"`. Trusting the tap fixes it.

### Steps for each other machine

Run in `~/dotfiles`. Skip a step if it's already done.

1. **Remove symlinks left pointing at deleted packages.** If you haven't pulled yet, run
   `stow -D cursor antigravity warp neofetch` *before* `git pull`. If you already pulled, the
   package folders are gone, so delete the broken links directly:

   ```sh
   find ~ -maxdepth 6 -type l ! -exec test -e {} \; -print 2>/dev/null \
     | grep -E "dotfiles/(cursor|antigravity|warp|neofetch)/"     # review the list
   find ~ -maxdepth 6 -type l ! -exec test -e {} \; -print 2>/dev/null \
     | grep -E "dotfiles/(cursor|antigravity|warp|neofetch)/" | while read -r l; do rm "$l"; done
   rmdir ~/.config/neofetch 2>/dev/null
   ```

   Then confirm VS Code still resolves its settings:
   `head -3 ~/Library/Application\ Support/Code/User/settings.json`

2. **nvim**: open nvim and run `:Lazy clean` (removes the kulala plugin), then optionally
   `rm -rf ~/.local/state/nvim/kulala.nvim ~/.local/share/nvim/kulala.nvim`.
   Check quitting is instant: `nvim --headless +qa` should return immediately.

3. **Homebrew tap trust** (fixes short cask names in dumps):

   ```sh
   brew trust --json=v1                       # list trusted taps
   brew trust --tap nikitabobko/tap           # if missing (already done on air)
   brew trust --tap jesseduffield/lazygit     # optional: pro trusts it; nothing installs from it
   brew bundle dump --file=- | grep -B1 aerospace   # expect the description + nikitabobko/tap/aerospace
   ```

   If it still prints `cask "aerospace"`, run `brew reinstall --cask nikitabobko/tap/aerospace`.

4. **neofetch** (fastfetch replaces it): `brew uninstall neofetch`.

5. **brewsync config**: now shared through the `brewsync` stow package (already without `cursor`
   and `antigravity`). Do the "Stow k9s, nap and a shared brewsync config" entry above before step 7.

6. **brewsync binary**: update to v0.1.5 (pushed to brewsync `main`: case-insensitive hostname match,
   tap-qualified names and descriptions in the `brew list` fallback, `trusted: true` kept in dumps):
   `cd ~/code/brewsync && git pull && make install && brewsync --version` (expect `v0.1.5`).

7. **Regenerate this machine's Brewfile**: `brewsync dump`, then review `git diff _brew_<machine>/Brewfile`
   (expect neofetch removed and the full AeroSpace name) and commit.

8. Mark the machine as done under "Done on" above.
