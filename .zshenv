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
alias viz='nvim ~/.zprofile -c "normal cd"'
alias vic='nvim ~/.config -c "normal cd"'
alias vin='nvim ~/.config/nvim/ -c "normal cd"'
alias vid='nvim ~/.config/dotfiles/ -c "normal cdg."'
alias vit='nvim -c :term -c :startinsert'
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

export PATH="/Users/james/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export EDITOR="nvim"
export PROJECTS_DIR="/Users/james/bar"

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
