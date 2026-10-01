# Credits

These color scripts come from **shell-color-scripts**, copied on 2026-10-01 at upstream commit
`576735c` (2023-03-27, "Updating PKGBUILD"), which was upstream's latest commit at the time.
Everything below comes from that repository's own files (README, PKGBUILD, LICENSE, script
headers and git history).

## Creator

- **Name:** Derek Taylor
- **Known as:** DistroTube (the name used in the project's PKGBUILD maintainer line)
- **Role:** created and maintains shell-color-scripts; he wrote the `colorscript` CLI, packaged it
  for Arch Linux (PKGBUILD / AUR `shell-color-scripts`), and collected the scripts. The README
  describes it as "A collection of terminal color scripts I've accumulated over the years."
- **Contact (as listed in the project):** `derek@distrotube.com` (PKGBUILD maintainer and most
  commits); some commits also use `contact@unabot.com`
- **Repository:** https://gitlab.com/dwt1/shell-color-scripts
- **Project started:** first commit 2018-02-09 by Derek Taylor
- **Commits:** 69 of the repository's 113 commits are his (51 + 18 under the two addresses)
- **License:** MIT, "Copyright (c) 2020 Derek Taylor" (full text in `LICENSE` next to this file)

## Authors of the scripts used here

Derek Taylor collected most scripts from community forum posts; their original authors are named
in each script's header.

| Script | Author | Original source |
|---|---|---|
| `awk-rgb-test` | not named (added by Derek Taylor, 2020-09-22) | — |
| `bloks` | not named (added by Derek Taylor, 2018-02-09) | — |
| `colortest-slim` | machinebacon | http://linuxbbq.org/bbs/viewtopic.php?f=4&t=1656#p33237 |
| `colorwheel` | baskerville | http://crunchbang.org/forums/viewtopic.php?pid=288344#p288344 |
| `crunchbang` | steampunknyanja | http://crunchbang.org/forums/viewtopic.php?pid=146715#p146715 |
| `crunchbang-mini` | thevdude | http://crunchbang.org/forums/viewtopic.php?pid=147530#p147530 |
| `elfman` | thevdude | http://crunchbang.org/forums/viewtopic.php?pid=144700#p144700 |
| `faces` | pfh | http://crunchbang.org/forums/viewtopic.php?pid=127737#p127737 |
| `illumina` | venam | https://nixers.net/showthread.php?tid=1921 |
| `monster` | gutterslob | http://crunchbang.org/forums/viewtopic.php?pid=130590#p130590 |
| `pinguco` | lantlos (added to the repo by acxz, 2022-02-20) | — |

## Other contributors to shell-color-scripts

From the upstream git history (commit counts), besides Derek Taylor: gk07 (6), darkeye (5),
Firgen (4), Djones A. Boni (3), Jorrit Wegman (3), HostGrady (2), Lucas Benchat / foopsss (2,
also maintains the Fedora Copr package), Sergei S (2), Vessel Wave (2), alexcoder04 (2),
Alfredo Casanova, Anupam Kumar, Edmund Rosewright and 9 others with one commit each.

## Changes made here

- Kept only the 11 scripts above; the scripts themselves are unmodified.
- Dropped the `colorscript` CLI: `.zshrc` runs a random script from `~/.local/share/colorscripts/`
  directly with `bash`.
