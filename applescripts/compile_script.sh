# Note: Could make it so PlistBuddy sets identifier
# so everything is not called applet
SCRIPT="$1"
APP="$2"
set -euo pipefail
echo "Compiling $SCRIPT to $APP"
osacompile -o "$APP" "$SCRIPT"
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$APP/Contents/Info.plist"
xattr -cr "$APP"
codesign --force --deep --sign "MySelfSignedIdentity" "$APP"
