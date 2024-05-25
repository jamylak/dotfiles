set -g fish_key_bindings fish_vi_key_bindings
function setcursors
    set -g fish_cursor_insert block
    set -g fish_cursor_default block
    set -g fish_cursor_external block
    set -g fish_cursor_unknown block
end

# Try get it to always be block

function fish_cursor_block
    # Set cursor to block shape
    echo -ne '\e[2 q'
end

function fish_vi_cursor_handle --on-variable fish_bind_mode
    fish_cursor_block
end
function set_mode_post_execution --on-event fish_postexec
    fish_cursor_block
end

function set_mode_pre_execution --on-event fish_preexec
    fish_cursor_block
end
# Set cursor to block on shell startup
fish_cursor_block
setcursors

# Reset cursor to block after each command
function force_cursor_block --on-event fish_prompt
    fish_cursor_block
    setcursors
end

# https://github.com/fish-shell/fish-shell/issues/3541
function fish_user_key_bindings
    # for mode in insert default visual
    for mode in insert
        bind -M $mode \cy forward-char
        bind -M $mode \ck forward-char
        bind -M $mode \cj forward-char
        # https://stackoverflow.com/questions/37114257/how-to-bind-ctrl-enter-in-fish
        # not working
        # bind -M $mode \cM forward-char
    end
end

function watchandrun
    # Check if the command was provided
    if set -q argv[1]
        # Extract the last argument as the file to watch
        set file_to_watch (eval echo $argv[-1])
        echo "Watching for changes on $file_to_watch"

        # Convert the command to a string
        set cmd (string join " " $argv)
        echo "Command to run: $cmd"

        # Start watching the file and execute the command upon changes
        fswatch -l 0.01 -o $file_to_watch | while read change_count
            echo "Change detected, running command..."
            eval $cmd
            echo "Waiting for changes..."
        end
    else
        echo "Please specify a command to run and a file to watch."
    end
end
abbr -a war watchandrun

function last_history_item
    echo $history[1]
end
abbr -a r --position anywhere --function last_history_item
# Testing abbreviations
abbr -a gk git checkout
abbr -a c clear
abbr -a gc git commit
abbr -a ga git add
abbr -a vi nvim
abbr -a q exit
# abbr -a ls ls -G
abbr -a lg "lazygit"
abbr -a vib "cd ~/bar; nvim ."
abbr -a vij "nvim ."

# Set SHELL to FISH
set -xg SHELL /opt/homebrew/bin/fish --login

alias c="clear"
alias ls="ls -G"
# alias gk="git checkout"
# alias gc="git commit"
# alias ga="git add"
alias vi="nvim"
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
alias viv='nvim -c "normal \'0"'
alias vio='NVIM_APPNAME="oldasnvim" nvim'
alias vii="nvim ."
alias vij="nvim ."
alias vig="nvim ."
alias via='nvim ~/.config/dotfiles/alacritty/alacritty.toml -c "normal cd"'
alias viz='nvim ~/.config/dotfiles/.zshenv -c "normal cd"'
alias vic='nvim ~/.config -c "normal cd"'
alias vin='nvim ~/.config/nvim/ -c "normal cd"'
alias vip='nvim ~/.config/nvim/lua/plugins/ -c "normal cd"'
alias vid='nvim ~/.config/dotfiles/ -c "normal cd"'
alias vif='nvim ~/.config/dotfiles/fish/config.fish -c "normal cd"'
alias vik='nvim ~/.config/dotfiles/kitty/kitty.conf -c "normal cd"'
alias vit='nvim -c :term -c :startinsert'
alias vitm='nvim ~/.config/dotfiles/.tmux.conf -c "normal cd"'
alias newproj="scripts/newproj.sh"
alias nproj="scripts/newproj.sh"
alias killdocker="osascript -e 'quit app \"Docker\"'"
alias zb="zig build"
alias cm="cmake . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=1" 
alias cb="cmake --build build"
function rn
    set executable (find build/ -type f -perm +111 -maxdepth 1 | head -n 1)
    if test -x $executable
        eval ./$executable $argv
    else
        echo "Executable not found or not runnable"
    end
end
alias rt="./build/test*"
alias sb="./scripts/build.sh"
alias x="exa --no-permissions --no-user --icons --tree -l --git --git-ignore -L 2"
alias xj="exa --no-permissions --no-user --icons --tree -l -L 2"
alias xk="exa --no-permissions --no-user --icons --tree -l -L 1"
alias ex="exa --icons --tree -l --git --git-ignore"
alias exn="exa --icons --tree -l --git --git-ignore --no-permissions --no-user"
alias exx="exa --icons --tree -l --git"
alias l="exa --icons -l --git --git-ignore"
alias ll="exa --icons -l --git"
alias zt="zig test"
alias ztt="zig test tests.zig"

set -Ux EDITOR vim
set -Ux PROJECTS_DIR /Users/$USER/bar
# set -Ux MACOSX_DEPLOYMENT_TARGET $(sw_vers -productVersion)

# eg. fd is in here
fish_add_path -mp $HOME/.cargo/bin
fish_add_path -mp /Users/$USER/.local/bin
fish_add_path -mp /usr/local/bin
fish_add_path -mp /opt/homebrew/bin

bind \cy 'commandline -f accept-autosuggestion'

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

# fzf --fish | source

# starship init fish | source

fzf_configure_bindings --directory=\ct
