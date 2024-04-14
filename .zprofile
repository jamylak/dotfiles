alias c="clear"
alias ls="ls -G"
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
alias qj="exit"
alias ta="tmux a"
alias td="tmux detach"
alias vio='NVIM_APPNAME="oldasnvim" nvim'
alias vi='nvim'
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
alias x="exa --icons --tree -l --git --git-ignore -L 2"
alias ex="exa --icons --tree -l --git --git-ignore"
alias exn="exa --icons --tree -l --git --git-ignore --no-permissions --no-user"
alias exx="exa --icons --tree -l --git"
alias l="exa --icons -l --git --git-ignore"
alias ll="exa --icons -l --git"
alias zt="zig test"
alias ztt="zig test tests.zig"

export MACOSX_DEPLOYMENT_TARGET=$(sw_vers -productVersion)
export PROJECTS_DIR=/Users/james/bar
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"

PATH="/Users/james/bar/glsl-language-server/build:$PATH"
PATH=$PATH:/Users/james/.local/bin


# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/james/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/james/Downloads/google-cloud-sdk/path.zsh.inc'; fi
# # The next line enables shell command completion for gcloud.
# if [ -f '/Users/james/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/james/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="/opt/homebrew/bin:$PATH"

# MacPorts Installer addition on 2023-11-12_at_19:51:36: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

# MacPorts Installer addition on 2023-11-12_at_19:51:36: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
export VIRTUALENVWRAPPER_PYTHON=/opt/homebrew/bin/python3

# Lazy version of virtualenv wrapper
workon () {
  unset -f workon mkvirtualenv
  source /opt/homebrew/bin/virtualenvwrapper.sh
  workon $@
}
mkvirtualenv () {
  unset -f workon mkvirtualenv
  source /opt/homebrew/bin/virtualenvwrapper.sh
  mkvirtualenv $@
}

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

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/Cellar/luajit/2.1.1703358377/lib/pkgconfig"

# Set up fzf key bindings and fuzzy completion
export FZF_DEFAULT_OPS="--extended"
eval "$(fzf --zsh)"
