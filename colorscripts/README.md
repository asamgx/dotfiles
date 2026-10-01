# colorscripts

The 11 terminal color scripts that `.zshrc` shows at the start of each interactive shell, copied from
[shell-color-scripts](https://gitlab.com/dwt1/shell-color-scripts) by Derek Taylor (MIT, see `LICENSE`)
at commit `576735c` (2023-03-27, upstream's latest when copied on 2026-10-01).

Credits for the creator and every script author are in `.local/share/colorscripts/CREDITS.md`.

Maintained here; there is no upstream sync. `.zshrc` runs a random executable file from
`~/.local/share/colorscripts/` directly with `bash` (no `colorscript` CLI), so to add one, drop an
executable script in `.local/share/colorscripts/`; to stop one showing, delete it or `chmod -x` it.
