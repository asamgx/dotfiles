# Changelog

Changes that need follow-up steps on the other machines (`air`, `mini`, `pro`), newest first.
Each entry lists what changed and what to run on every machine that hasn't done it yet.
"Done on" tracks progress per machine; a machine with steps still open is listed as
`**machine**: all except step N (reason)`.

## 2026-11-09 — Remove oh-my-claudecode, own status line

Done on: **pro**.

### What changed in the repo

- **oh-my-claudecode (OMC) is gone.** It ran about 25 Node hooks around every tool call, injected its own
  orchestration prompt, and mostly duplicated built-in features and other enabled plugins. Its
  marketplace pulled unpinned code from a single maintainer's repo, which then ran on every tool call.
- `claude/.claude/CLAUDE.md` now holds only the git conventions; the OMC prompt is gone.
- `claude/.claude/.omc-config.json` and `hud/omc-hud.mjs` are deleted. The status line is now
  `hud/statusline.mjs`, a single dependency-free script with the same layout: git branch and status, then
  model, effort, 5h/weekly usage, session time, context bar and tool/agent counts. It takes usage from
  Claude Code's status line input, so it reads no Keychain token and makes no network calls.
- `.omc/` is no longer in `.gitignore` or `.stow-global-ignore`, and the `lccbase` alias (Claude
  without OMC) is gone from `.zshrc`.

### Steps for each machine

1. **Uninstall the plugin and its marketplace** (each command is a no-op if already gone):

   ```sh
   claude plugin uninstall oh-my-claudecode@omc 2>/dev/null
   claude plugin marketplace remove omc 2>/dev/null
   claude plugin list 2>&1 | grep -i oh-my || echo "OMC plugin gone"
   ```

2. **Remove the dangling config symlink** left after `git pull`:

   ```sh
   [ -L ~/.claude/.omc-config.json ] && [ ! -e ~/.claude/.omc-config.json ] && rm ~/.claude/.omc-config.json
   ls ~/.claude/hud/statusline.mjs            # should exist (hud/ is a folded symlink)
   ```

3. **Archive OMC plans/specs/research, then delete all OMC state.** OMC wrote untracked `.omc/` folders
   into every project it ran in; this keeps any `*.md` and `research/` under `~/omc-archive/` first:

   ```sh
   A=~/omc-archive; mkdir -p "$A"
   find ~ -maxdepth 5 -type d -name .omc -not -path '*/Library/*' -not -path '*/node_modules/*' 2>/dev/null |
   while read -r d; do
     rel=${d#$HOME/}; rel=${rel%/.omc}
     (cd "$d" && find . -type f -name '*.md' -not -path '*/state/*' -not -path './sessions/*' -exec sh -c \
       'mkdir -p "$0/$(dirname "$1")" && cp -p "$1" "$0/$1"' "$A/$rel" {} \;)
     [ -d "$d/research" ] && mkdir -p "$A/$rel" && rsync -a --exclude .omc "$d/research" "$A/$rel/"
     rm -rf "$d"
   done
   rm -rf ~/.claude/plugins/cache/omc ~/.claude/plugins/oh-my-claudecode ~/.claude/plugins/data/oh-my-claudecode-omc
   find "$A" -type d -empty -delete 2>/dev/null
   find ~ -maxdepth 5 -type d -name .omc -not -path '*/Library/*' 2>/dev/null | wc -l   # should be 0
   ```

4. **Check the status line** in a new Claude Code session: two lines, no `[OMC#…]` label.

## 2026-10-17 — History rewrite, claude package holds only settings, leak guard

Done on: **pro**.

### What changed in the repo

- **History was rewritten** (`git filter-repo`) to remove work details from `claude/.claude/settings.json`
  and Anthropic's licensed skills from `claude/.claude/skills/synced/`. Every commit since 2026-09-21 has
  a new SHA, so **`git pull` will fail or merge old history back in**. Use the reset in step 2.
- The `claude` package now holds only hand-written files: `settings.json`, `CLAUDE.md`,
  `.omc-config.json`, `package-manager.json`, `hud/`. `skills/` and the unused `statusline.sh` are gone,
  and `claude/.claude/skills/` is gitignored.
- `~/.claude/skills` must be a real folder, not a symlink into the repo: Claude Code syncs account
  skills into it, and that churn was being committed.
- The Cloudflare skills now come from `cloudflare@claude-plugins-official`, enabled in `settings.json`,
  instead of copies in the repo.
- Work-specific `autoMode` entries moved to the untracked `~/.claude/automode.local.json`, loaded by
  `alias claude='claude --settings ~/.claude/automode.local.json'` in `~/.zshrc.local`. Claude Code
  reads `autoMode` only from user settings, managed settings or `--settings`, not from project settings.
- `.githooks/pre-commit` refuses generated paths, credential-like strings and the regexes in the
  untracked `~/.config/dotfiles/leak-patterns`.

### Steps for each machine

1. **Save local work.** `git -C ~/dotfiles status --short`; commit nothing yet. Stash it if anything shows:

   ```sh
   git -C ~/dotfiles stash push -u -m before-rewrite
   ```

2. **Reset to the rewritten history** (not `git pull`):

   ```sh
   git -C ~/dotfiles fetch origin
   git -C ~/dotfiles reset --hard origin/main
   git -C ~/dotfiles stash list | grep -q before-rewrite && git -C ~/dotfiles stash pop
   git -C ~/dotfiles status -sb                      # should show "## main...origin/main" with no ahead/behind
   ```

   If the stash pop conflicts on files under `claude/.claude/skills/`, drop those changes:
   `git -C ~/dotfiles checkout -- . && git -C ~/dotfiles stash drop`.

3. **Make `~/.claude/skills` a real folder** (close other Claude sessions first):

   ```sh
   [ -L ~/.claude/skills ] && rm ~/.claude/skills; mkdir -p ~/.claude/skills
   [ -L ~/.claude/statusline.sh ] && rm ~/.claude/statusline.sh
   ls -la ~/.claude/skills                          # real folder; start Claude and synced/ reappears
   ```

4. **Cloudflare plugin**: `claude plugin install cloudflare@claude-plugins-official` (skip if
   `claude plugin list | grep cloudflare` already shows it).

5. **Leak guard**:

   ```sh
   git -C ~/dotfiles config core.hooksPath .githooks
   mkdir -p ~/.config/dotfiles   # then copy ~/.config/dotfiles/leak-patterns from pro
   ```

6. **Work machines only**: copy `~/.claude/automode.local.json` from pro and add the alias above to
   `~/.zshrc.local`. Check with `zsh -ic 'alias claude'`.
7. Run `dotstow -nv`: it should report no conflicts. Then mark the machine as done under "Done on" above.

## 2026-10-01 — Global gitignore, dotstow, ~/.zshrc.local, new-machine checklist

Done on: **pro**.

### What changed in the repo

- `git` package now includes `.config/git/ignore` (the global gitignore git reads by default).
- `.zshrc` defines `dotstow`: stows every package except `ssh` (reference only) and the other
  machines' `_brew_*`. Use it instead of `stow */`, which would link `ssh` and fight over `~/Brewfile`.
  Flags pass through: `dotstow -nv` (dry run), `dotstow -R` (restow).
- `.zshrc` sources `~/.zshrc.local` last if it exists (untracked; machine-only settings and secrets),
  like `.gitconfig` already includes `~/.gitconfig-local`. Both names are in `.gitignore`.
- README has a step-by-step "New Machine Setup".

### Steps for each machine

1. **Global gitignore**: if `~/.config/git/ignore` is a real file (not a symlink), merge any lines the
   repo copy lacks into `git/.config/git/ignore`, then replace it with the link:

   ```sh
   ls -l ~/.config/git/ignore
   diff ~/.config/git/ignore git/.config/git/ignore
   mv ~/.config/git/ignore ~/.config/git/ignore.bak && stow git
   git check-ignore -v --no-index x/.claude/settings.local.json   # should name ~/.config/git/ignore
   ```

2. **dotstow**: open a new shell, then `dotstow -nv`. It should only report `starship3.toml` (unused)
   or nothing; anything else is a package that isn't fully stowed on this machine. Run `dotstow` to
   link it, after moving aside any file it reports as a conflict.
3. Mark the machine as done under "Done on" above.

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
