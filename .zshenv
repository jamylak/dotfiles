if [ -d "/opt/homebrew" ]; then
    export HOMEBREW_DIR="/opt/homebrew"
else
    export HOMEBREW_DIR="/usr/local"  # fallback to another directory if needed
fi
export PATH="/Users/$USERNAME/.local/bin:$PATH"
export PATH="$HOMEBREW_DIR/bin:$PATH"
export EDITOR="nvim"
export PROJECTS_DIR="/Users/$USERNAME/bar"

alias war=watchandrun
alias p=python3
alias c=clear
alias q=exit
alias lg="lazygit"
alias tm=tmux
alias t=tmux
alias ta="tmux a"
alias td="tmux detach"
alias h='nvim -c :term -c :startinsert'
alias zid="z dotfiles"
alias zib="z bar"
alias zit="z /tmp"
alias zin="z ~/.config/nvim"
alias br="brew"

# Git
alias gk=git checkout
alias gm="git commit -m"
alias gl="git log"
alias gpl="git pull"
alias gc=git commit
alias ga=git add
alias gp=git pull
alias gs=git status
alias gd=git diff
alias gu=git push
alias gps=git push

# Vim
alias vi="nvim"
alias v="nvim ."
alias vib="cd ~/bar; nvim ."
alias vij="nvim ."
alias vig='nvim ~/.config/dotfiles/ghostty/config -c "normal cd"'
alias viv='nvim -c "normal '\''0"'
alias vi="nvim"
alias vii="nvim ."
alias vij="nvim ."
alias via='nvim ~/.config/dotfiles/alacritty/alacritty.toml -c "normal cd"'
alias viz='nvim ~/.config/dotfiles/.zshenv -c "normal cd"'
alias vic='nvim ~/.config -c "normal cd"'
alias vin='nvim ~/.config/nvim/ -c "normal cd"'
alias vip='nvim ~/.config/nvim/lua/plugins/ -c "normal cd"'
alias vid='nvim ~/.config/dotfiles/ -c "normal cd"'
alias vif='nvim ~/.config/dotfiles/fish/config.fish -c "normal cd"'
alias vifl='nvim ~/.config/dotfiles/fish/config.local.fish -c "normal cd"'
alias vik='nvim ~/.config/dotfiles/kitty/kitty.conf -c "normal cd"'
alias vit='nvim -c :term -c :startinsert'
alias vitm='nvim ~/.config/dotfiles/.tmux.conf -c "normal cd"'

# Misc
alias newproj="scripts/newproj.sh"
alias nproj="scripts/newproj.sh"
alias killdocker="osascript -e 'quit app \"Docker\"'"
alias rt="./build/test*"
alias sb="./scripts/build.sh"

# C++
alias cm="cmake . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=1" 
alias cb="cmake --build build"

# Exa
alias x="exa --no-permissions --no-user --icons --tree -l -L 2"
alias xj="exa --no-permissions --no-user --icons --tree -l --git --git-ignore -L 2"
alias xk="exa --no-permissions --no-user --icons --tree -l -L 1"
alias ex="exa --icons --tree -l --git --git-ignore"
alias exn="exa --icons --tree -l --git --git-ignore --no-permissions --no-user"
alias exx="exa --icons --tree -l --git"
alias l="exa --icons -l --git --git-ignore"
alias ll="exa --icons -l --git"

# Zig
alias zb="zig build"
alias zt="zig test"
alias ztt="zig test tests.zig"

# Lazy version of zoxide
z () {
  unset -f z zi
  eval "$(zoxide init zsh)"
  z $@
}

zi () {
  unset -f z zi
  eval "$(zoxide init zsh)"
  zi $@
}

# Function to watch a file and execute a specified command when it changes
watchandrun() {
  # Check if at least one argument was provided
  if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <command-to-execute> <path-to-watch>"
    return 1
  fi

  # Extract the file to watch, which is the last argument
  local file_to_watch="${@: -1}"

  # Remove the last argument to get the command
  local command_to_run="${@:1:$(($#-1))}"

  echo "Watching for changes on $file_to_watch"
  echo "Command to run: $command_to_run"

  # Start watching the file and execute the command upon changes
  fswatch -l 0.01 -o "$file_to_watch" | while read -r change_count; do
    echo "Change detected, running command..."
    eval "$command_to_run"
    echo "Waiting for changes..."
  done
}


# Lazy version of virtualenv wrapper
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$HOMEBREW_DIR/bin/python3
workon () {
  unset -f workon mkvirtualenv
  source $HOMEBREW_DIR/bin/virtualenvwrapper.sh
  workon $@
}
mkvirtualenv () {
  unset -f workon mkvirtualenv
  source $HOMEBREW_DIR/bin/virtualenvwrapper.sh
  mkvirtualenv $@
}

source ~/.zshenv.local
