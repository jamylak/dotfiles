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
alias rt="./build/test*"
alias sb="./scripts/build.sh"
alias x="exa_with_options --icons --tree -l --git --git-ignore -L 2"
alias ex="exa_with_options --icons --tree -l --git --git-ignore"
alias exn="exa_with_options --icons --tree -l --git --git-ignore --no-permissions --no-user"
alias exx="exa_with_options --icons --tree -l --git"
alias l="exa_with_options --icons -l --git --git-ignore"
alias ll="exa_with_options --icons -l --git"
alias zt="cmd_with_options zig test"
alias ztt="zig test tests.zig"

cmd_with_options() {
    $@
}
exa_with_options() {
    /usr/local/bin/exa "$@"
}

export MACOSX_DEPLOYMENT_TARGET=$(sw_vers -productVersion)
export PROJECTS_DIR=/Users/james/bar
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:$PKG_CONFIG_PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"

PATH="/Users/james/bar/glsl-language-server/build:$PATH"

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

export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/Cellar/luajit/2.1.1703358377/lib/pkgconfig"
