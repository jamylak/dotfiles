export MACOSX_DEPLOYMENT_TARGET=$(sw_vers -productVersion)
export PATH="/Users/$USERNAME/bar/glsl-language-server/build:$PATH"
# MacPorts Installer
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished MacPorts
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$HOMEBREW_DIR/Cellar/luajit/2.1.1703358377/lib/pkgconfig"
