if [ -d "/opt/homebrew" ]; then
    export HOMEBREW_DIR="/opt/homebrew"
else
    export HOMEBREW_DIR="/usr/local"  # fallback to another directory if needed
fi
export PATH="/Users/$USERNAME/.local/bin:$PATH"
export PATH="$HOMEBREW_DIR/bin:$PATH"
export EDITOR="nvim"
export PROJECTS_DIR="/Users/$USERNAME/bar"

alias c="clear"
alias ls="ls -G"
alias gk="git checkout"
alias gc="git commit"
alias gm="git commit -m"
alias gs="git status"
alias ga="git add"
alias gl="git log"
alias gd="git diff"
alias gp="git pull"
alias gu="git push"
alias gps="git push"
alias gpl="git pull"
alias q="exit"
alias qj="exit"
alias ta="tmux a"
alias td="tmux detach"
alias vi='nvim'
alias viv='nvim -c "normal '\''0"'
alias vig="nvim ."
alias vii="nvim ."
alias vij="nvim ."
alias vio='NVIM_APPNAME="oldasnvim" nvim'
alias via='nvim ~/.config/dotfiles/alacritty/alacritty.toml -c "normal cd"'
alias viz='nvim ~/.config/dotfiles/.zshenv -c "normal cd"'
alias vic='nvim ~/.config -c "normal cd"'
alias vin='nvim ~/.config/nvim/ -c "normal cd"'
alias vip='nvim ~/.config/nvim/lua/plugins/ -c "normal cd"'
alias vid='nvim ~/.config/dotfiles/ -c "normal cd"'
alias vif='nvim ~/.config/dotfiles/fish/config.fish -c "normal cd"'
alias vik='nvim ~/.config/dotfiles/kitty/kitty.conf -c "normal cd"'
alias vib='nvim ~/bar -c "normal cd"'
alias vit='nvim -c :term -c :startinsert'
alias vitm='nvim ~/.config/dotfiles/.tmux.conf -c "normal cd"'
alias nv='nvim'
alias lg="lazygit"
alias newproj="scripts/newproj.sh"
alias nproj="scripts/newproj.sh"
alias killdocker="osascript -e 'quit app \"Docker\"'"
alias zb="zig build"
alias cm="cmake . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=1" 
alias cb="cmake --build build"
alias rn='./$(find build/ -type f -perm +111 -maxdepth 1 | head -n 1)'
alias rt="./build/test*"
alias sb="./scripts/build.sh"
alias x="exa --no-permissions --no-user --icons --tree -l --git --git-ignore -L 2"
alias ex="exa --icons --tree -l --git --git-ignore"
alias exn="exa --icons --tree -l --git --git-ignore --no-permissions --no-user"
alias exx="exa --icons --tree -l --git"
alias l="exa --icons -l --git --git-ignore"
alias ll="exa --icons -l --git"
alias zt="zig test"
alias ztt="zig test tests.zig"
alias war="watchandrun"

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
