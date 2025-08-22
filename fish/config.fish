source ~/.config/fish/config.local.pre.fish
if test -d /opt/homebrew/bin
    set -xg SHELL /opt/homebrew/bin/fish
else
    set -xg SHELL /usr/local/bin/fish
end

# Fix incorrerct yazi emoji rendering on
# nvim terminal. Also fix tmux issue when returning
# to a session, on return the layout gets messed up
if set -q NVIM; or set -q TMUX
    set -gx YAZI_CONFIG_HOME $HOME/.config/dotfiles/yazi_alt
end

set fish_cursor_insert line
set -gx EDITOR hx
# set -gx HELIX_RUNTIME /Users/james/proj/helix/runtime
set -gx PROJECTS_DIR /Users/$USER/bar
# set -gx MACOSX_DEPLOYMENT_TARGET $(sw_vers -productVersion)
# Running vulkan things doesn't work without this
set -gx XDG_DATA_DIRS /usr/local/share
# set -gx XDG_DATA_DIRS /usr/local/share
# https://github.com/nushell/nushell/issues/10100
set -gx XDG_CONFIG_HOME $HOME/.config
# set -gx XDG_STATE_HOME $HOME/.local/state
# set -gx XDG_DATA_HOME $HOME/.local/share
set -gx LG_CONFIG_FILE $HOME/.config/lazygit/config.yaml

# TODO: Lazygit config
# promptToReturnFromSubprocess: false
# https://github.com/jesseduffield/lazygit/issues/1915

set -g fish_key_bindings fish_vi_key_bindings

function nvim_nproj -a projname
    if test -n "$projname"
        mkdir ~/bar/$projname
        cd ~/bar/$projname
        nvim_find_files
    else
        nvim -c ":F"
    end
end

# Autocomplete binding
bind \cy 'commandline -f accept-autosuggestion'
# bind -M insert \cy fish_clipboard_paste
bind -M insert \ef forward-word
bind -M insert \eb backward-word
# todo: make a useful default for empty terminal \ck
bind -M normal \ck expand-abbr
bind -M insert \ck expand-abbr
bind -M insert \cs "zi; commandline --function repaint"
bind -M insert \ei "zi; commandline --function repaint"
# Doing commandline -r because if you bind things directly
# it messes up nvim cursor
bind -M insert \ej 'commandline -r "y" ; commandline -f execute'
bind -M insert \ek 'commandline -r "nvim_find_files" ; commandline -f execute'
bind -M insert \eo 'commandline -r "nvim -c \":Telescope oldfiles\"" ; commandline -f execute'
bind -M insert \eh "hx ."
bind -M insert \cg "echo n | lazygit && commandline --function repaint"
bind -M insert \eg "echo n | lazygit && commandline --function repaint"
# bind -M insert \eg "z (tv git-repos) && commandline --function repaint"
bind -M insert \en 'commandline -r "nvim_nproj"; commandline -f execute'
bind -M insert \ev 'commandline -r "nvim ." ; commandline -f execute'
# bind -M insert \ev "nvim"
bind -M insert \eq "commandline --function kill-whole-line"
bind -M insert \ep 'commandline -r "nvim_join_fzf"; commandline -f execute'
# bind -M insert \cp 'commandline -r "tmux_fzf"; commandline -f execute'
bind -M insert \em 'commandline -r "tmux_session_fzf"; commandline -f execute'
bind -M insert \co "__smart_cd_or_insert_path; commandline --function repaint"

function __smart_cd_or_insert_path
    # 1. If I press eg. \co
    # cd to that dir
    # 2. If i type eg. hx \co
    # then it is hx (fzf dir result)/
    # 3. If i type eg. hx /my/dir/\co
    # then it is hx /my/dir/(fzf dir result)
    set cmd (commandline)
    set cursor (commandline --cursor)

    if test -n "$cmd"
        set prev_char (string sub -l 1 -s (string length -- $cmd) -- $cmd)
    else
        set prev_char ""
    end

    if test "$prev_char" = /
        _fzf_search_directory
        return
    end

    set result (ls -d /Applications /tmp (eval echo ~) ~/.local/share/ ~/.local/share/nvim/lazy/ ~/.Trash ~/.config ~/bar/ ~/bar/* ~/proj/ ~/proj/* ~/.config/dotfiles ~/.config/nvim | fzf --bind 'ctrl-j:accept')
    if test -z "$result"
        return
    end

    # Check if cursor is at the start or only whitespace before
    if string match -rq '^\s*$' (string sub -l $cursor -- "$cmd")
        cd $result
        commandline -r ''
        commandline --function repaint
    else
        commandline -i -- "$result/"
        # TODO: Test if this is better otherwise remove
        _fzf_search_directory
    end
end

#bind -M normal \ce edit_command_buffer
#bind -M insert \ce edit_command_buffer

# eg. fd is in here
fish_add_path -mp /opt/homebrew/bin
fish_add_path -mp /opt/homebrew/opt/llvm/bin
fish_add_path -mp /usr/local/bin
fish_add_path -mp /Users/$USER/.local/bin
fish_add_path -mp $HOME/.cargo/bin
fish_add_path -mp $HOME/.emacs.d/bin
fish_add_path -mp $HOME/.config/emacs/bin

function launch_new_tab -a cmd
    if test -n "$TMUX"
        tmux new-window "fish -c \"$cmd\""
    else if test $TERM = xterm-kitty
        kitty @ launch --type=tab fish -c "$cmd"
    else
        # For ghostty (or others?)
        skhd -k "cmd - t" && skhd -t "$cmd; exit" && skhd -k return
    end
end

function hx_tv -a path
    # Text search a path
    # then open result in hx (if we got one)
    set res (tv text (dirname "$path"))
    if test -n "$res"
        hx $res
    end
end

function yazi_tv_text -a path
    # Text search a path
    # then open result in hx (if we got one)
    set res (tv text (dirname "$path"))
    # Strip off everything after final : at the end
    # including the #
    set res (echo $res | sed 's/:[^:]*$//')
    if test -n "$res"
        yazi $res
    end
end

function yazi_tv_git -a path
    # Text search a path
    # then open result in hx (if we got one)
    set res (tv git-repos (dirname "$path"))
    if test -n "$res"
        z $res
        yazi $res
    end
end

function launch_overlay -a cmd
    if test -n "$TMUX"
        tmux split-window -v -c "#{pane_current_path}" "fish -c \"$cmd\"" \; resize-pane -Z
        #tmux new-window "fish -c \"$cmd\""
        #tmux popup -E "fish -c \"$cmd\""
    else if test $TERM = xterm-kitty
        kitty @ launch --type=overlay fish -c "$cmd"
    else
        # For ghostty
        skhd -k "cmd - return" && skhd -t "$cmd; exit" && skhd -k return -k "cmd + shift - return"
    end
end

function launch_vsplit -a cmd
    if test -n "$TMUX"
        tmux split-window -v "fish -c \"$cmd\""
    else if test $TERM = xterm-kitty
        kitty @ launch --location=vsplit fish -c "$cmd"
    else
        # For ghostty - Replicate Cmd - \
        skhd -k "cmd - 0x2A" && skhd -t "$cmd; exit" && skhd -k return
    end
end

function launch_hsplit -a cmd
    if test -n "$TMUX"
        tmux split-window -h "fish -c \"$cmd\""
    else if test $TERM = xterm-kitty
        kitty @ launch --location=hsplit fish -c "$cmd"
    else
        # For ghostty - Replicate Cmd - Enter
        skhd -k "cmd - 0x24" && skhd -t "$cmd; exit" && skhd -k return
    end
end

function launchGithubUrl -a url branch
    echo launching github url: $url
    set remote origin
    set repo (string split / $url -f5)
    set base_repo (string split / $url -f1-5 | string join "/")
    echo repo: $repo
    if not string match -q '*pull*' $url; and not string match -q '*job*' $url
        set path (string split / $url -f8 -m7)
    end

    if test -d "$HOME/bar/$repo"
        set p "$HOME/bar/$repo"
    else if test -d "$HOME/proj/$repo"
        set p "$HOME/proj/$repo"
    else
        set p "$HOME/proj/$repo"
        git clone "$base_repo.git" $p
    end
    cd $p

    # check if it's a fork branch eg. pluiedev:push-foo
    if string match -q '*:*' "$branch"
        set forkBranch "$branch"
        # we need to achieve something like this
        # git remote add upstream https://github.com/ghostty-org/ghostty.git
        # git fetch upstream pull/6004/head:pluiedev-push-nxwlqouoqluy
        # git checkout pluiedev-push-nxwlqouoqluy

        # we are looking at something like
        # https://github.com/ghostty-org/ghostty/pull/6004/commits
        # so it's a PR based off fork
        # assume the upstream is same as URL
        git remote add upstream "$base_repo.git"
        # make the pull/6004/head:pluiedev-push-nxwlqouoqluy part
        set ref_prefix (string split / $url -f6-7 | string join "/")
        # forkBranch is like pluiedev:push-nxwlqouoqluy
        # so replace the :
        set ref_suffix (string replace ':' '-' "$forkBranch")
        set ref $ref_prefix/head:$ref_suffix
        git fetch upstream $ref

        set remote upstream
        set branch "$ref_suffix"
    end

    yazi_new_tab $p

    echo "launch repo: $repo $path..."

    if test -n "$path"
        # path helix format
        # set path (string replace -a '#L' ':' $path)
        set linenum (string split "#L" $path -r -m1 -f2)
        set path (string split "#L" $path -r -m1 -f1)

        # Don't make it go to end of file if no line num
        set linenumnvim ""
        if test -n "$linenum"
            set linenumnvim "+$linenum"
        end

        echo new path $path
        launch_new_tab "cd $p && nvim $linenumnvim $path" &
    else
        launch_new_tab "cd $p && nvim_find_files" &
    end

    if test -n "$branch"
        # if branch is given, then we can update in background
        # and probably the file should be there otherwise just
        # wait and search for it
        # Update in BG cause this is slow
        echo "stash + untracked..."
        git stash -u
        # Try checkout the branch in case we already have it
        git checkout "$branch"
        # Get it if we don't have it
        gitUpdateMainMaster $remote
        git checkout "$branch"
        read -P "Press Enter to continue..."
    end
end

function gitUpdateMainMaster -a remote
    echo "Update main / master to $remote"
    git fetch --all

    # Update main and master
    if git show-ref --verify --quiet refs/heads/main
        git update-ref refs/heads/main refs/remotes/$remote/main
    end

    if git show-ref --verify --quiet refs/heads/master
        git update-ref refs/heads/master refs/remotes/$remote/master
    end
end

function launchKittyGithubUrl -a url branch
    kitty fish -c "launchGithubUrl $url \"$branch\"" &
end

function sendRepeatToOtherPane
    if test $TERM = xterm-kitty
        kitty @ send-text -m id:$(kitty @ ls | jq -r '.[].tabs[].windows[] | select(.is_focused == false) | .id' | head -n 1) 'r\\x0d'
    else
        # For ghostty - Replicate Cmd - ] to swith to the other pane
        # then send 'r' and enter
        # then Cmd - [ to swith back
        # skhd -k "cmd - ]" && skhd -t "$cmd; exit" && skhd -k return
        skhd -k "cmd - 0x1E" && skhd -t r -k return -k "cmd - 0x21"
    end
end

function lazygit_new_tab -a path
    launch_new_tab "cd (git_repo_dir $path); lazygit"
end

function hx_new_tab -a path linenum
    if test -n "$linenum"
        launch_new_tab "hx $path:$linenum"
    else
        launch_new_tab "hx $path"
    end
end

function nvim_new_tab -a path linenum
    if test -n "$linenum"
        launch_new_tab "nvim $path +$linenum -c ':CD'"
    else
        launch_new_tab "nvim $path -c ':CD'"
    end
end

function yazi_new_tab -a path
    # attempted fix for it not loading fish
    # full config in time
    launch_new_tab "y $path"
end

function yazi_launch_overlay -a path
    launch_overlay "y $path"
end

function yazi_vsplit -a path
    launch_vsplit "y $path"
end

function yazi_hsplit -a path
    # TODO: doesn't work for file eg. notes(1).csv
    # should escape to notes\(1\).csv
    launch_hsplit "y $path"
end

function neogitlog_new_tab -a path
    launch_new_tab "cd (git_repo_dir $path); neogitlog 400"
end

function neogitdiffmain_new_tab -a path
    launch_new_tab "cd (git_repo_dir $path); neogitdiffmain"
end

function neogitdiff_new_tab -a path
    launch_new_tab "cd (git_repo_dir $path); neogitdiff"
end

function nvim_find_files
    nvim -c ":Telescope find_files"
end

function git_repo_dir -a path
    set dir (realpath $path)
    # Test git rev-parse --show-toplevel
    # instead of while
    while test $dir != /
        if test -d "$dir/.git"
            echo $dir
            return 0
        end
        set dir (dirname $dir)
    end
    echo "Not in a Git repository" >&2
    return 1
end

# Note: Could do something like this to allow mix of
# commands, eg. when not empty
# bind --preset -M insert ctrl-space 'test -n "$(commandline)" && commandline -i " "'

# https://github.com/fish-shell/fish-shell/issues/3541
function forward-or-execute
    set before (commandline -C) # cursor position
    set cmd (commandline)
    if test -z "$cmd"
        # empty commandline
        # commandline -r nvim_nproj
        commandline -r nvim
        commandline -f execute
    else
        # either go forward char if there is a suggestion
        # else execute the line
        commandline -f forward-char
        set after (commandline -C)
        if test $before -eq $after
            commandline -f execute
        end
    end
end

function fish_user_key_bindings
    # for mode in insert default visual
    bind -M insert \cb backward-char
    bind -M insert \ca beginning-of-line
    bind -M insert \ce end-of-line
    bind -M insert \cf forward-char
    bind -M insert \cp history-search-backward
    bind -M insert \cn history-search-forward
    bind -M insert ctrl-space _fzf_search_history
    bind -M insert alt-space _fzf_search_history
    bind -M insert \cj forward-or-execute
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

function neogitlog
    # Hacky feedkeys way, so use a delay to wait for it to load
    set -l delay 1000
    if test -n "$argv[1]"
        set delay "$argv[1]"
    end
    nvim . -c ":lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\" gnll\", true, true, true), \"m\", true); vim.defer_fn(function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\"ggjdd\", true, true, true), \"m\", true) end, $delay)"
end

function neogitdiffmain
    # Hacky feedkeys way, so use a delay to wait for it to load
    set -l delay 400
    if test -n "$argv[1]"
        set delay "$argv[1]"
    end
    nvim . -c ":lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\" gndr\", true, true, true), \"m\", true); vim.defer_fn(function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\"<c-n><c-n><enter>\", true, true, true), \"m\", true) end, $delay)"
end

function neogitdiff
    nvim . -c ":lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\" gndd\", true, true, true), \"m\", true);"
end

function nvim_of
    # From within neovim, escape terminal, then open a file
    # and CD into that dir
    # skhd doesn't seem to work in kitty right now?
    skhd -k "ctrl - 0x2A" && skhd -k "ctrl - n" && skhd -t gf && skhd -t " v" && skhd -t " j"
end

function nvim_last_session
    set last_command (history | grep '^nvim_join_session' | head -n 1)
    eval $last_command
end

function nvim_main_send_files
    nvim --server /tmp/nvimmain.sock --remote-send ":args $argv <CR>"
end

function tmux_last_session
    set last_command (history | grep '^tmux_attach' | head -n 1)
    eval $last_command
end

function dashboard
    set -l dir (pwd)
    if test -n "$argv[1]"
        set dir "$argv[1]"
    end
    launch_new_tab "cd $dir && fish -c yazi"
    launch_new_tab "cd $dir && fish -c neogitlog"
    launch_new_tab "cd $dir && fish -c 'hx .'"
    launch_new_tab "cd $dir && fish -c lazygit"
    exit
end

function git_checkout_origin
    # Move an origin branch locally
    set branch (tv git-branch)
    git checkout $branch
    git switch --track $branch
end

# Dashboard
abbr -a db dashboard
# Neogit
abbr -a ng neogitlog 300
abbr -a ngl neogitlog 300
abbr -a nl neogitlog 300
abbr -a ngd neogitdiff
abbr -a nd neogitdiff
abbr -a d neogitdiff
# C++
# TODO: debug build
# TODO: lldb
# Other
abbr -a hex hexdump -C
abbr -a cdls "cd (ls -t | head -n 1)"
abbr -a war watchandrun
abbr -a w --set-cursor=! "cd ~/.virtualenvs/! && source bin/activate.fish && test -f .project && cd (cat .project)"
abbr -a workon --set-cursor=! "cd ~/.virtualenvs/! && source bin/activate.fish && test -f .project && cd (cat .project)"
abbr -a svep --set-cursor=! "echo (pwd) > ~/.virtualenvs/!/.project"
abbr -a setvirtualenvproject --set-cursor=! "echo (pwd) > ~/.virtualenvs/!/.project"
abbr -a ef exec fish
abbr -a hm --position anywhere ~/
abbr -a dotfiles --position anywhere ~/.config/dotfiles
abbr -a dot --position anywhere ~/.config/dotfiles
abbr -a mcd --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a mkcd --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a mkd --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a mkc --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a mk --set-cursor=! "mkdir \"!\" && cd (ls -tA | head -n 1)"
abbr -a p python3
abbr -a pdb python3 -m pdb
abbr -a --position anywhere tmp /tmp/
abbr -a --position anywhere tm /tmp/
abbr -a --position anywhere bar ~/bar/
abbr -a --position anywhere b ~/bar/
abbr -a --position anywhere proj ~/proj/
abbr -a --position anywhere pr ~/proj/
abbr -a c 'nvim -c ":CopilotChatOpen" -c ":only" -c "startinsert"'
abbr -a r --position anywhere --function last_history_item
abbr -a q exit

# Tmux
abbr -a t tmux
abbr -a ta "tmux a"
abbr -a td "tmux detach"
abbr -a tc tmux new-session -s
abbr -a ts tmux new-session -s
abbr -a tk tmux new-session -s
abbr -a fk tmux new-session -s

function tmux_attach -a name dir
    set name (string escape --style=var $name)
    if test -n "$dir"
        tmux new-session -s $name -c $dir "hx ." 2>/dev/null
    else
        tmux new-session -s $name 2>/dev/null
    end
    tmux attach-session -t $name
end

abbr -a tj tmux_attach
abbr -a fk tmux_attach

# Directories
abbr -a k zi
abbr -a zid "cd ~/.config/dotfiles"
abbr -a zd "cd ~/.config/dotfiles"
abbr -a zib "cd ~/bar"
abbr -a zis "cd ~/scripts"
abbr -a zip "cd ~/proj"
abbr -a zp "cd ~/proj"
abbr -a zit "cd /tmp"
abbr -a zin "z ~/.config/nvim"
abbr -a zn "z ~/.config/nvim"
abbr -a br brew
abbr -a bi "brew install"
abbr -a bin "brew info"
abbr -a bu "brew upgrade"

function git_fetch_main
    git fetch
    git branch -f main origin/main 2>/dev/null
    git branch -f master origin/master 2>/dev/null
end

# Git
abbr -a g git
abbr -a gf git fetch
abbr -a gfk "git_fetch_main; git_checkout_origin"
abbr -a gfo "git_fetch_main; git_checkout_origin"
abbr -a gko git_checkout_origin
abbr -a gkt "git checkout (tv git-branch)"
abbr -a gt "git checkout (tv git-branch)"
abbr -a gkb "git checkout (tv git-branch)"
abbr -a N nvim -c ":Neogit"
abbr -a ng nvim -c ":Neogit"
abbr -a gi "git init"
abbr -a gb "git branch"
abbr -a gk git checkout
abbr -a gm --set-cursor=! "git commit -m \"!\""
# gh extension install gennaro-tedesco/gh-s
abbr -a ghc --set-cursor=! "git clone (gh s \"!\") && cd (ls -t | head -n 1)"
abbr -a ghs --set-cursor=! "git clone (gh s \"!\") && cd (ls -t | head -n 1)"
abbr -a cloneproj --set-cursor=! "cd ~/proj && git clone (gh s \"!\") && cd (ls -t | head -n 1)"
abbr -a clonetoproj --set-cursor=! "cd ~/proj && git clone (gh s \"!\") && cd (ls -t | head -n 1)"
abbr -a ghp --set-cursor=! "cd ~/proj && git clone (gh s \"!\") && cd (ls -t | head -n 1)"
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
abbr -a gcl --set-cursor=! "git clone ! && cd (ls -t | head -n 1)"
abbr -a gpsu "git push --set-upstream origin (git branch --show-current)"
abbr -a gsu "git push --set-upstream origin (git branch --show-current)"

# Neovide
abbr -a neovide 'open -a neovide --args'
abbr -a nv 'open -a neovide --args'
# alias neovide 'open -a Neovide --args'
# abbr -a nv neovide

# gcloud
abbr -a gal gcloud auth login
abbr -a gad gcloud auth application-default login
abbr -a gaadl gcloud auth application-default login
abbr -a gadl gcloud auth application-default login

# Lazygit
abbr -a lg lazygit
abbr -a G lazygit
abbr -a gn "nvim . -c ':lua vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(\" gn<CR>\", true, true, true), \"m\", true)'"
abbr -a lgd "cd ~/.config/dotfiles; lazygit"
abbr -a lgn "cd ~/.config/nvim/; lazygit"

# Vim
abbr -a vi nvim
abbr -a v nvim
abbr -a n nvim
abbr -a nn nvim_nproj

function nvim_new_session -a name
    tmux new-session -d -s nvim 2>/dev/null
    # unset tmux variable or else when eg. launch_new_tab is called
    # from a joined nvim session, it thinks we are in tmux,
    # even though tmux just runs this server only...
    tmux new-window -t nvim "set -e TMUX && nvim --headless --listen /tmp/nvim$name.sock"
end

function nvim_join_session -a name dir
    # So fish abbr can work eg. filepaths will
    # be scaped
    set name (string escape --style=var $name)

    # First try just connect
    # this will make most cases faster
    if test -e /tmp/nvim$name.sock
        nvim --server /tmp/nvim$name.sock --remote-ui
        return
    end

    # Create the session if it doesn't exist
    nvim_new_session $name
    while not test -e /tmp/nvim$name.sock
        continue
    end
    if test -n "$dir"
        nvim --server /tmp/nvim$name.sock --remote-send ":cd $dir <CR>"
        nvim --server /tmp/nvim$name.sock --remote-send ":Telescope find_files <CR>"
    end

    nvim --server /tmp/nvim$name.sock --remote-ui
end

abbr -a ns nvim_new_session
abbr -a njj --set-cursor=! nvim --server /tmp/nvim!.sock --remote-ui
abbr -a ne nvim_join_session
abbr -a nj nvim_join_session
abbr -a fj nvim_join_session
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
abbr -a vifl 'nvim ~/.config/dotfiles/fish/config.local.post.fish -c "normal cd"'
abbr -a vfl 'nvim ~/.config/dotfiles/fish/config.local.post.fish -c "normal cd"'
abbr -a fl 'nvim ~/.config/dotfiles/fish/config.local.post.fish -c "normal cd"'
abbr -a vizl 'nvim ~/.config/dotfiles/.zshenv.local -c "normal cd"'
abbr -a vik 'nvim ~/.config/dotfiles/kitty/kitty.conf -c "normal cd"'
abbr -a vk 'cd ~/.config/dotfiles && nvim kitty/kitty.conf'
abbr -a vit 'nvim /tmp -c "normal cd"'
abbr -a vt 'nvim -c ":term" -c ":startinsert"'
abbr -a vitm 'nvim ~/.config/dotfiles/.tmux.conf -c "normal cd"'

# Helix
abbr -a h hx
abbr -a hr 'hx .'
abbr -a hz 'cd ~/.config/dotfiles; hx .zshenv'
abbr -a hzl 'cd ~/.config/dotfiles; hx .zshenv.local'
abbr -a ha 'cd ~/.config/dotfiles; hx alacritty/alacritty.toml'
abbr -a hf 'cd ~/.config/dotfiles; hx fish/config.fish'
abbr -a hy 'cd ~/.config/dotfiles; hx yazi'
abbr -a hg 'cd ~/.config/dotfiles; hx ghostty/config'
abbr -a hh 'cd ~/.config/dotfiles; hx helix/config.toml'
abbr -a hb 'cd ~/bar; cd (fzf --walker=dir) && hx .'
abbr -a hp 'cd ~/proj; cd (fzf --walker=dir) && hx .'
abbr -a he 'cd ~/bar; cd (fzf --walker=dir) && hx .'
abbr -a hfl 'cd ~/.config/dotfiles; hx fish/config.local.post.fish'
abbr -a hd 'cd ~/.config/dotfiles; hx .'
abbr -a htm 'cd ~/.config/dotfiles; hx .tmux.conf'
abbr -a hn 'cd ~/.config/nvim/; hx .'
abbr -a hk 'cd ~/.config/dotfiles; hx kitty/kitty.conf'
abbr -a ht 'cd /tmp; hx .'

function toggle_amethyst
    if pgrep Amethyst >/dev/null
        killall Amethyst
    else
        open -a Amethyst
    end
end

# Emacs
abbr -a em emacsclient -c
abbr -a e emacsclient -c

# Misc
abbr -a rp realpath
abbr -a newproj "scripts/newproj.sh"
abbr -a nproj "scripts/newproj.sh"
abbr -a killdocker "osascript -e 'quit app \"Docker\"'"
abbr -a rt "./build/test*"
abbr -a sb "./scripts/build.sh"
abbr -a xx hx +999999

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

# Yazi
# https://yazi-rs.github.io/docs/quick-start/
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function nvim_join_fzf
    set result (ls -d /tmp ~/bar/* ~/proj/* ~/.config/dotfiles ~/.config/nvim | fzf --print-query)
    set query $result[1]
    set dir $result[2]

    if test -n "$query"; and not test -n "$dir"
        set dir $HOME/bar/$query
        if string match -q '*.*' $query
            # new file to create in bar, ensure directories exist
            mkdir -p (dirname $dir)
            touch $dir
            set dir (dirname $dir)
        else
            # new folder to create in bar, doesn't already exist
            mkdir -p $dir
        end
    end
    if test -n "$dir"
        nvim_join_session "$dir" "$dir"
    end
end

function tmux_fzf
    set dir (ls -d ~/bar/* ~/proj/* ~/.config/dotfiles ~/.config/nvim | fzf)
    if test -n "$dir"
        tmux_attach "$dir" "$dir"
    end
end

function tmux_session_fzf
    set session (tmux list-sessions | fzf | cut -d ':' -f 1)
    if test -n "$session"
        tmux attach-session -t $session
    end
end

starship init fish | source
set -gx FZF_DEFAULT_OPTS "--pointer=🔥 --layout=reverse --info=inline --height=80% --bind=ctrl-j:accept"
fzf_configure_bindings --directory=\ct
source ~/.config/fish/config.local.post.fish
