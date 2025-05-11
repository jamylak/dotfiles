# https://gist.github.com/stecman/97bbe21b59613aa6c6c025ae85871438
# This works after signing with self signed cert
# first add code signing cert as trusted
# xattr -cr /path/to/YourApp.app
# codesign --deep --force --sign "MySelfSignedIdentity" /path/to/YourApp.app
# then manually add as trusted
# <key>LSUIElement</key><true/> in info.plist to stop bouncing in dock
on is_running(appName)
	tell application "System Events" to (name of processes) contains appName
end is_running

if not is_running("kitty") then
	tell application "kitty" to activate
else
	tell application "System Events" to tell process "kitty"
		click menu item "New OS Window" of menu 1 of menu bar item "Shell" of menu bar 1
	end tell
end if
