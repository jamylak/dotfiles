tell application "System Events"
	set ghosttyIsRunning to (name of processes) contains "Ghostty"
end tell

if ghosttyIsRunning then
	tell application "System Events"
		tell UI element "Ghostty" of list 1 of application process "Dock"
			perform action "AXShowMenu"
			click menu item "New Window" of menu 1
		end tell
	end tell
else
	do shell script "/Applications/Ghostty.app/Contents/MacOS/ghostty &>/dev/null &"
end if
