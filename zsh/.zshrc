eval "$(starship init zsh)"

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
fpath+=~/.zfunc

autoload -Uz compinit && compinit

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8  
export EDITOR=/opt/homebrew/bin/nvim
export TERM=xterm-256color
export XDG_CONFIG_HOME="$HOME/.config"
export DOTFILES="$HOME/dotfiles"

case "$(scutil --get LocalHostName)" in
  "Andrews-MacBook-Air")
    export MACHINE="air"
    ;;
  "Andrews-Mac-mini")
    export MACHINE="mini"
    ;;
  *)
    export MACHINE="unknown"
    ;;
esac

## Aliases
#alias l='lsd -hA --group-dirs first'

# Random
alias please='sudo $(fc -ln -1)'
alias ccat='pygmentize -g'
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

# Zsh Source
alias rezsh="source ~/.zshrc"
alias zshconfig="nvim ~/.zshrc"

# Tmux
alias retmux="source ~/.tmux.conf"

# MacO
alias wifipass="security find-generic-password -wa"
alias c="clear"

# Brew
alias brewdump='brew bundle dump --force --describe --file=~/Brewfile'
alias ccupgrade='brew upgrade --cask claude-code'

# Python
alias aple='source .venv/bin/activate'

# claude-code
alias lcc="claude"

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
# alias fire='aafire -driver curses'

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


## Python
# Created by `pipx` on 2025-01-23 14:13:12
export PATH="$PATH:$HOME/.local/bin"
export PATH="$(brew --prefix python)/libexec/bin:$PATH"

#Poetry
export POETRY_VIRTUALENVS_IN_PROJECT=true

# PyEnv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

## Go
export GOPATH=$HOME/go
# Manual Installation
#export GOROOT=/usr/local/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Zsh Plugins
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-you-should-use/you-should-use.plugin.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Zoxide
[[ $- == *i* ]] && eval "$(zoxide init --cmd cd zsh)"

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# FZF key bindings and fuzzy completion
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Machine Specific Configurations
# if [ "$MACHINE" = "mini" ]; then
#   export NVM_DIR="$HOME/.nvm"
# elif [ "$MACHINE" = "air" ]; then
#   export NVM_DIR="$HOME/.nvm"
# fi


# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Color Script
indexes=(30 39 56 55 51 49 30 29 4 21 11 2)
random_index=${indexes[RANDOM % ${#indexes[@]}]}
[[ -t 0 && -t 1 ]] && colorscript exec $random_index 2>&1 | grep -v "Input error"

# Nap
export NAP_CONFIG="$XDG_CONFIG_HOME/nap/config.yaml"

# ---- TheFuck -----
# thefuck alias
eval $(thefuck --alias)
eval $(thefuck --alias fk)


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

source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# Brewsync
source <(brewsync completion zsh)
