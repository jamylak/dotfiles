export MACOSX_DEPLOYMENT_TARGET=$(sw_vers -productVersion)
export PATH="/Users/james/bar/glsl-language-server/build:$PATH"
# MacPorts Installer
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished MacPorts
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/opt/homebrew/Cellar/luajit/2.1.1703358377/lib/pkgconfig"

# Lazy version of virtualenv wrapper
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/opt/homebrew/bin/python3
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
