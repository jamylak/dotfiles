# to get the name of menu eg. in ghostty it's "File" i ran below
# tell application "System Events" to get entire contents of menu bar 1 of process "ghostty"
# first add code signing cert as trusted
# xattr -cr /path/to/YourApp.app
# codesign --deep --force --sign "MySelfSignedIdentity" /path/to/YourApp.app
# then manually add as trusted
on is_running(appName)
	tell application "System Events" to (name of processes) contains appName
end is_running

if not is_running("ghostty") then
	tell application "ghostty" to activate
else
	tell application "System Events" to tell process "ghostty"
		click menu item "New Window" of menu 1 of menu bar item "File" of menu bar 1
	end tell
end if
