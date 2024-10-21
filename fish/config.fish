if test -d /opt/homebrew/bin
    set -xg SHELL /opt/homebrew/bin/fish
else
    set -xg SHELL /usr/local/bin/fish
end

set -Ux EDITOR hx
set -Ux PROJECTS_DIR /Users/$USER/bar
# set -Ux MACOSX_DEPLOYMENT_TARGET $(sw_vers -productVersion)
# Running vulkan things doesn't work without this
set -g XDG_DATA_DIRS /usr/local/share
# set -g XDG_DATA_DIRS /usr/local/share:/usr/share:/Users/james/.nix-profile/share:/nix/var/nix/profiles/default/share


set -g fish_key_bindings fish_vi_key_bindings

# Autocomplete binding
bind \cy 'commandline -f accept-autosuggestion'
bind -M normal \ck expand-abbr
bind -M insert \ck expand-abbr

bind -M normal \ce edit_command_buffer
bind -M insert \ce edit_command_buffer

# eg. fd is in here
fish_add_path -mp /opt/homebrew/bin
fish_add_path -mp /usr/local/bin
fish_add_path -mp /Users/$USER/.local/bin
fish_add_path -mp $HOME/.cargo/bin

# https://github.com/fish-shell/fish-shell/issues/3541
function fish_user_key_bindings
    # for mode in insert default visual
    for mode in insert
        bind -M $mode \cy forward-char
        #bind -M $mode \ck forward-char
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
        echo "[[ Watching for changes on $file_to_watch ]]"

        # Convert the command to a string
        set cmd (string join " " $argv)
        echo "[[ Command to run: $cmd ]]"

        # Start watching the file and execute the command upon changes
        fswatch -l 0.01 -o $file_to_watch | while read change_count
            # echo "[[ Change detected, running command... ]]"
            eval $cmd
            echo "[[ ...waiting for changes... ]]"
        end
    else
        echo "Please specify a command to run and a file to watch."
    end
end

function last_history_item
    echo $history[1]
end

function rn
    set executable (find build/ -type f -perm +111 -maxdepth 1 | head -n 1)
    if test -x $executable
        eval ./$executable $argv
    else
        echo "Executable not found or not runnable"
    end
end

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

abbr -a war watchandrun
abbr -a w --set-cursor=! "cd ~/.virtualenvs/! && source bin/activate.fish && test -f .project && cd (cat .project)"
abbr -a workon --set-cursor=! "cd ~/.virtualenvs/! && source bin/activate.fish && test -f .project && cd (cat .project)"
abbr -a svep --set-cursor=! "echo (pwd) > ~/.virtualenvs/!/.project"
abbr -a setvirtualenvproject --set-cursor=! "echo (pwd) > ~/.virtualenvs/!/.project"
abbr -a ef exec fish
abbr -a hm --position anywhere ~/
abbr -a fj --position anywhere ~/
abbr -a mcd --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a mkcd --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a mkd --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a mkc --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a mk --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a p python3
abbr -a --position anywhere tmp /tmp/
abbr -a --position anywhere tm /tmp/
abbr -a --position anywhere bar ~/bar/
abbr -a --position anywhere b ~/bar/
abbr -a --position anywhere proj ~/proj/
abbr -a --position anywhere pr ~/proj/
abbr -a c clear
abbr -a r --position anywhere --function last_history_item
abbr -a q exit
abbr -a t tmux
abbr -a ta "tmux a"
abbr -a td "tmux detach"
abbr -a zid "cd ~/.config/dotfiles"
abbr -a zd "cd ~/.config/dotfiles"
abbr -a zib "cd ~/bar"
abbr -a zip "cd ~/proj"
abbr -a zp "cd ~/proj"
abbr -a zit "cd /tmp"
abbr -a zin "z ~/.config/nvim"
abbr -a zn "z ~/.config/nvim"
abbr -a br brew
abbr -a bi "brew install"

# Git
abbr -a g git
abbr -a N nvim -c ":Neogit"
abbr -a ng nvim -c ":Neogit"
abbr -a gi "git init"
abbr -a gk git checkout
abbr -a gm --set-cursor=! "git commit -m \"!\""
# gh extension install gennaro-tedesco/gh-s
abbr -a ghc --set-cursor=! "git clone (gh s \"!\") && cd (ls -t | head -n 1)"
#abbr -a ghc --set-cursor=! "git clone (gh s !) && cd (ls -t | head -n 1)"
abbr -a gl "git log"
abbr -a gpl "git pull"
abbr -a gc git commit
abbr -a ga git add
abbr -a gaa git add -A
abbr -a gp git pull
abbr -a gs git status
abbr -a gst git stash
abbr -a gstp git stash pop
abbr -a gd git diff
abbr -a gu git push
abbr -a gps git push
abbr -a gcl git clone
abbr -a gpsu "git push --set-upstream origin (git branch --show-current)"
abbr -a gsu "git push --set-upstream origin (git branch --show-current)"

# Lazygit
abbr -a lg lazygit
abbr -a G lazygit
abbr -a gn "nvim . -c ':lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\" gn<CR>\", true, true, true), \"m\", true)'"
abbr -a lgd "cd ~/.config/dotfiles; lazygit"
abbr -a lgn "cd ~/.config/nvim/; lazygit"

# Vim
abbr -a vi nvim
abbr -a v nvim .
#abbr -a vj "nvim . -c ':lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\"<leader>fw\", true, true, true), \"m\", true)'"
abbr -a vib "cd ~/bar; nvim ."
abbr -a o "cd /Users/james/bar/testfoo; nvim foo.frag -c ':M' -c ':lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\"f<CR>\", true, true, true), \"m\", true)'"

abbr -a vb "cd ~/bar; cd (fzf --walker=dir) && nvim . -c ':lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\"si<CR>\", true, true, true), \"m\", true)'"
abbr -a vij "nvim ."
abbr -a vig 'nvim ~/.config/dotfiles/ghostty/config -c "normal cd"'
abbr -a viv 'nvim -c "normal \'0"'
abbr -a vn 'NVIM_APPNAME=nvim2 nvim'
abbr -a vj 'NVIM_APPNAME=nvim2 nvim'
abbr -a vnn 'NVIM_APPNAME=nvim2 nvim ~/.config/nvim2/init.lua'
abbr -a vi nvim
abbr -a vii "nvim ."
abbr -a vij "nvim ."
abbr -a via 'nvim ~/.config/dotfiles/alacritty/alacritty.toml -c "normal cd"'
abbr -a viz 'nvim ~/.config/dotfiles/.zshenv -c "normal cd"'
abbr -a vic 'nvim ~/.config -c "normal cd"'
abbr -a vin 'nvim ~/.config/nvim/ -c "normal cd"'
abbr -a vih 'cd ~/.config/helix/; nvim config.toml'
abbr -a vip 'nvim ~/.config/nvim/lua/plugins/ -c "normal cd"'
abbr -a vp "cd ~/proj; cd (fzf --walker=dir) && nvim . -c ':lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\"si<CR>\", true, true, true), \"m\", true)'"
abbr -a vid 'nvim ~/.config/dotfiles/ -c "normal cd"'
abbr -a vif 'nvim ~/.config/dotfiles/fish/config.fish -c "normal cd"'
abbr -a vifl 'nvim ~/.config/dotfiles/fish/config.local.fish -c "normal cd"'
abbr -a fl 'nvim ~/.config/dotfiles/fish/config.local.fish -c "normal cd"'
abbr -a vizl 'nvim ~/.config/dotfiles/.zshenv.local -c "normal cd"'
abbr -a vik 'nvim ~/.config/dotfiles/kitty/kitty.conf -c "normal cd"'
abbr -a vk 'cd ~/.config/dotfiles && nvim kitty/kitty.conf'
abbr -a vit 'nvim /tmp -c "normal cd"'
abbr -a vitm 'nvim ~/.config/dotfiles/.tmux.conf -c "normal cd"'

# Helix
abbr -a h hx
abbr -a hr 'hx .'
abbr -a hz 'cd ~/.config/dotfiles; hx .zshenv'
abbr -a hzl 'cd ~/.config/dotfiles; hx .zshenv.local'
abbr -a ha 'cd ~/.config/dotfiles; hx alacritty/alacritty.toml'
abbr -a hf 'cd ~/.config/dotfiles; hx fish/config.fish'
abbr -a hg 'cd ~/.config/dotfiles; hx ghostty/config'
abbr -a hh 'cd ~/.config/dotfiles; hx helix/config.toml'
abbr -a hb 'cd ~/bar; cd (fzf --walker=dir) && hx .'
abbr -a hp 'cd ~/proj; cd (fzf --walker=dir) && hx .'
abbr -a he 'cd ~/bar; cd (fzf --walker=dir) && hx .'
abbr -a hfl 'cd ~/.config/dotfiles; hx fish/config.local.fish'
abbr -a hd 'cd ~/.config/dotfiles; hx .'
abbr -a htm 'cd ~/.config/dotfiles; hx .tmux.conf'
abbr -a hn 'cd ~/.config/nvim/; hx .'
abbr -a hk 'cd ~/.config/dotfiles; hx kitty/kitty.conf'
abbr -a ht 'cd /tmp; hx .'

# Emacs
abbr -a em emacs
abbr -a e emacs

# Misc
abbr -a newproj "scripts/newproj.sh"
abbr -a nproj "scripts/newproj.sh"
abbr -a killdocker "osascript -e 'quit app \"Docker\"'"
abbr -a rt "./build/test*"
abbr -a sb "./scripts/build.sh"

# C++
abbr -a cm "cmake . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
abbr -a cb "cmake --build build"

# eza
abbr -a l "eza --no-permissions --no-user --icons --tree -l -L 2"
abbr -a x "eza --icons -l"
abbr -a xj "eza --no-permissions --no-user --icons --tree -l --git --git-ignore -L 2"
abbr -a xk "eza --no-permissions --no-user --icons --tree -l -L 1"
abbr -a ex "eza --icons --tree -l"
abbr -a exn "eza --icons --tree -l --git --git-ignore --no-permissions --no-user"
abbr -a exx "eza --icons --tree -l --git --git-ignore"
abbr -a ll "eza --icons -l"

# Zig
abbr -a zb "zig build"
abbr -a zbt "zig build test"
abbr -a zt "zig test"
abbr -a ztt "zig test tests.zig"
abbr -a zr "./zig-out/bin/*"
abbr -a zbr "zig build && ./zig-out/bin/*"

# fzf --fish | source

starship init fish | source
#oh-my-posh init fish --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/kushal.omp.json' | source
#oh-my-posh init fish --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/montys.omp.json' | source
#oh-my-posh init fish --config 'https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json' | source

fzf_configure_bindings --directory=\ct

# Noting tide configuration but don't need to run this in this file
# fisher install IlanCosman/tide@v6
#tide configure --auto --style=Rainbow --prompt_colors='16 colors' --show_time='24-hour format' --rainbow_prompt_separators=Vertical --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='Two lines, character' --prompt_connection=Dotted --powerline_right_prompt_frame=No --prompt_spacing=Sparse --icons='Many icons' --transient=No

source ~/.config/fish/config.local.fish
