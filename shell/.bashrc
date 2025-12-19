# ~/.bashrc - Bash configuration

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ----- Source external files -----
[ -f ~/.exports ] && source ~/.exports
[ -f ~/.aliases ] && source ~/.aliases

# ----- Shell options -----
shopt -s histappend      # Append to history, don't overwrite
shopt -s checkwinsize    # Update LINES and COLUMNS after each command
shopt -s cdspell         # Autocorrect typos in cd
shopt -s dirspell        # Autocorrect directory typos
shopt -s autocd          # Type directory name to cd into it
shopt -s globstar        # ** matches all files and directories recursively

# ----- Completion -----
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ----- Prompt -----
# Colors
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BLUE='\[\033[0;34m\]'
PURPLE='\[\033[0;35m\]'
CYAN='\[\033[0;36m\]'
WHITE='\[\033[0;37m\]'
BOLD='\[\033[1m\]'
RESET='\[\033[0m\]'

# Git branch in prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Git status indicators
parse_git_dirty() {
    [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}

# Custom prompt: user@devbox:~/path (branch*)$
export PS1="${GREEN}\u@devbox${RESET}:${BLUE}\w${YELLOW}\$(parse_git_branch)\$(parse_git_dirty)${RESET}\$ "

# ----- Functions -----

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick git commit and push
gcp() {
    git add -A && git commit -m "$1" && git push
}

# Docker shell into container
dsh() {
    docker exec -it "$1" /bin/sh
}

# Docker bash into container
dbash() {
    docker exec -it "$1" /bin/bash
}

# Find process by name
psg() {
    ps aux | grep -v grep | grep -i "$1"
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    echo "Serving on http://localhost:$port"
    python3 -m http.server "$port"
}

# Get public IP info
ipinfo() {
    curl -s "https://ipinfo.io" | jq
}

# ----- Welcome message -----
echo "🚀 Welcome to devbox | $(date '+%Y-%m-%d %H:%M')"
echo "   Node: $(node -v 2>/dev/null || echo 'not installed')"
echo "   Docker: $(docker -v 2>/dev/null | cut -d' ' -f3 | tr -d ',' || echo 'not installed')"
