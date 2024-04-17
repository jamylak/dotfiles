set -g fish_key_bindings fish_vi_key_bindings

# Testing abbreviations
abbr -a gk git checkout
abbr -a c clear
abbr -a gc git commit
abbr -a ga git add
abbr -a vi nvim
abbr -a q exit

alias c="clear"
alias ls="ls -G"
# alias gk="git checkout"
# alias gc="git commit"
# alias ga="git add"
alias gm="git commit -m"
alias gs="git status"
alias gl="git log"
alias gd="git diff"
alias gp="git pull"
alias gu="git push"
alias gps="git push"
alias gpl="git pull"
alias ta="tmux a"
alias td="tmux detach"
alias vio='NVIM_APPNAME="oldasnvim" nvim'
alias viz='nvim ~/.zprofile -c "normal cd"'
alias vic='nvim ~/.config -c "normal cd"'
alias vin='nvim ~/.config/nvim/ -c "normal cd"'
alias vid='nvim ~/.config/dotfiles/ -c "normal cd"'
alias vit='nvim -c :term -c :startinsert'
alias nv='nvim'
alias lg="lazygit"
alias newproj="scripts/newproj.sh"
alias nproj="scripts/newproj.sh"
alias killdocker="osascript -e 'quit app \"Docker\"'"
alias zb="zig build"
alias cm="cmake . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=1" 
alias cb="cmake --build build"
# alias rn='./$(find build/ -type f -perm +111 -maxdepth 1 | head -n 1)'
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

# Lazy version of zoxide
function z
    # Remove the function definitions
    functions -e z zi

    # Initialize zoxide for fish shell
    zoxide init fish | source

    # Forward arguments using argv
    z $argv
end

function zi
    # Remove the function definitions
    functions -e z zi

    # Initialize zoxide for fish shell
    zoxide init fish | source

    # Forward arguments using argv
    zi $argv
end

fzf --fish | source
