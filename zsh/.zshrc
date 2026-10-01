eval "$(starship init zsh)"

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS

# Rebuild the completion cache once a day; otherwise trust it (-C skips the slow security check).
# After installing a tool with new completions, run: rm ~/.zcompdump && rezsh
autoload -Uz compinit
if [[ -f ~/.zcompdump && $(date +'%j') == $(stat -f '%Sm' -t '%j' ~/.zcompdump) ]]; then
  compinit -C
else
  compinit
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=/opt/homebrew/bin/nvim
export TERM=xterm-256color
export XDG_CONFIG_HOME="$HOME/.config"
export DOTFILES="$HOME/dotfiles"
# Set by `brew shellenv` in .zprofile; fallback for shells that skipped it
: ${HOMEBREW_PREFIX:=/opt/homebrew}

# Hostnames compared lowercased, so a case change in LocalHostName doesn't break detection
case "${(L)$(scutil --get LocalHostName)}" in
  "andrews-macbook-air")
    export MACHINE="air"
    ;;
  "andrews-mac-mini")
    export MACHINE="mini"
    ;;
  "andrews-macbook-pro")
    export MACHINE="pro"
    ;;
  *)
    export MACHINE="unknown"
    ;;
esac

## Aliases

# Random
alias please='sudo $(fc -ln -1)'
alias ccat='bat'
alias weather='curl wttr.in'
alias path='echo -e ${PATH//:/\\n}'
alias psg='ps aux | grep -i'
alias h='history'
alias j='jobs -l'
alias vi='nvim'
alias svi='sudo nvim'
alias myip='curl ipinfo.io/ip'

# Eza
alias l="eza -l --icons --git -a"
alias ls="eza --icons --git --group-directories-first -a "
alias ld="eza --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpush='git push -u origin'
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gaa='git add .'
alias gcoall='git checkout -- .'
alias gcb='git checkout -b'
alias gr='git remote'
alias gre='git reset'
alias guc='git reset --soft HEAD~1'
alias gl='git log'
alias gloga='git log --oneline --graph --all'

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# GCP
alias gcpconf="gcloud config configurations list"
alias gcpact="gcloud config configurations activate"
alias gcpsetquota="gcloud auth application-default set-quota-project"
alias gcpuse="gcloud config set project"
alias gcpdeact="gcloud auth revoke"
alias gcpinfo="gcloud info"
alias gcpdauth="gcloud auth application-default login"
alias gcpauth="gcloud auth login"

# Azure
alias azlist="az account list --output table"
alias azuse="az account set --subscription"
alias azshow="az account show"
alias azlogin="az login"
alias azlogout="az logout"
alias azacr="az acr login --name"

# GitHub
_gh_cache_user() {
  command -v gh &>/dev/null || return
  mkdir -p ~/.cache
  local user=$(gh auth status 2>&1 | sed -n 's/.*account \(.*\) (.*/\1/p' | head -1)
  [[ -n "$user" ]] || return
  echo "$(echo "$user" | cut -c1)sx" > ~/.cache/gh_active_user
}
ghs() { command gh auth switch "$@" && _gh_cache_user; }
gh() {
  command gh "$@"
  local rc=$?
  if [[ "$1" == "auth" && "$2" == (switch|login|logout) ]]; then
    _gh_cache_user
  fi
  return $rc
}
setopt NO_MONITOR; _gh_cache_user &>/dev/null & disown; setopt MONITOR

# Zsh Source
alias rezsh="source ~/.zshrc"
alias zshconfig="nvim ~/.zshrc"

# Tmux
alias retmux="tmux source-file ~/.tmux.conf"

# MacO
alias wifipass="security find-generic-password -wa"
alias c="clear"

# Brew (~/Brewfile is a stow symlink to this machine's _brew_*/Brewfile)
alias brewdump='brewsync dump'   # writes this machine's _brew_*/Brewfile
alias brewinstall='brew bundle --file=~/Brewfile'
alias ccupgrade='brew upgrade --cask claude-code'
alias cclatest='brew upgrade --cask claude-code@latest'

# Python
alias aple='source .venv/bin/activate'

# claude-code
alias lcc="CLAUDE_CODE_NO_FLICKER=1 claude"
alias lccwf="claude"
alias lccbase='claude --settings '\''{"enabledPlugins":{"oh-my-claudecode@omc":false}}'\'''

############################################
#   TERMINAL DOPAMINE PACK — FINAL EDITION
############################################

# RAINBOW BANNER (with arguments)
rainbow() {
  if [ $# -eq 0 ]; then
    read -rp "Text: " input
  else
    input="$*"
  fi
  figlet -w 120 "$input" | lolcat
}

# FIGLET + FORTUNE BANNERS
fign() { fortune | head -n 1 | figlet -w 120 | lolcat; }
fignc() { fortune | head -n 1 | figlet -w 120; }

alias fig='figlet -w 120'
alias lc='lolcat'

# COWSAY VARIANTS
cowsayfig() { figlet -w 120 "$*" | cowsay -f tux | lolcat; }
cowthinkfig() { figlet -w 120 "$*" | cowsay -f tux -t | lolcat; }
alias cowsay='cowsay -f tux'
alias cowthink='cowsay -f tux -t'

# BONSAI THAT NEVER BREAKS
bonsai() {
  if [ $# -eq 0 ]; then
    cbonsai --live
  else
    cbonsai --time "$1"
  fi
}

# QUOTES — using ZenQuotes (no DNS failures)
quote() {
  curl -s "https://zenquotes.io/api/random" \
    | sed 's/.*"q":"\(.*\)","a":"\(.*\)".*/\1 — \2/'
}

alias hackquote='quote | cowsay | lolcat'

# MATRIX / HACKER / CHILL
alias hacker='clear && cmatrix -b -C green'

# BORED? Pull random dopamine
bored() {
  local arr=("hacker" "hackquote" "bonsai" "fign")
  local pick=${arr[$RANDOM % ${#arr[@]}]}
  eval "$pick"
}

# Coffee break
alias coffee='echo "☕ Coffee time"; sleep 2; fortune | cowsay -f stegosaurus | lolcat'

# Typing speed warmup
alias typer='echo "Start typing..."; sleep 1; tput reset; gti status || echo "No git repo detected"'
# (Uses "gti" — the meme tool that runs when you mistype "git" — install if missing)

# Retro banner intro
alias welcome='clear; figlet -f slant "Welcome!" | lolcat; fortune | cowsay | lolcat; cbonsai --live'

# Infinite chill mode (stop with CTRL+C)
alias meditate='while true; do clear && fortune | lolcat; sleep 5; done'


############################################
# END OF PACK
############################################


## Python (pipx and Homebrew python PATH entries live in .zprofile)
# PyEnv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

## Go
export GOPATH=$HOME/go
export GOROOT="$HOMEBREW_PREFIX/opt/go/libexec"
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Zsh Plugins
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-you-should-use/you-should-use.plugin.zsh
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Zoxide
[[ $- == *i* ]] && eval "$(zoxide init --cmd cd zsh)"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# FZF key bindings and fuzzy completion
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# NVM: put the default Node on PATH now (cheap) so node/npm work everywhere, including
# tools nvim spawns; load nvm itself (~250 ms) only the first time `nvm` is run.
export NVM_DIR="$HOME/.nvm"
() {
  local default versions
  [[ -r $NVM_DIR/alias/default ]] && default=$(<$NVM_DIR/alias/default)
  versions=($NVM_DIR/versions/node/v${default}*(Nn))          # e.g. default "22" -> newest v22.x
  (( $#versions )) || versions=($NVM_DIR/versions/node/v*(Nn))  # "lts/*", "node", etc. -> newest installed
  (( $#versions )) && export NVM_BIN="$versions[-1]/bin" PATH="$versions[-1]/bin:$PATH"
}
nvm() {
  unset -f nvm
  [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
  [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && . "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}

# Color Script: a random one from the colorscripts package (executable files only, so LICENSE/CREDITS are skipped)
() {
  local scripts=(~/.local/share/colorscripts/*(N.x))
  (( $#scripts )) && [[ -t 0 && -t 1 ]] && bash "$scripts[RANDOM % $#scripts + 1]"
}

# Nap
export NAP_CONFIG="$XDG_CONFIG_HOME/nap/config.yaml"

# ---- TheFuck -----
# thefuck alias
eval $(thefuck --alias)
alias fk='fuck'


# Tmuxifier
export PATH="$HOME/.tmux/plugins/tmuxifier/bin:$PATH"
eval "$(tmuxifier init -)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

source "$HOMEBREW_PREFIX/share/google-cloud-sdk/path.zsh.inc"

# Android (only on machines with the SDK installed)
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"
fi

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Brewsync
source <(brewsync completion zsh)
