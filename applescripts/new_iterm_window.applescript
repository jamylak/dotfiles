tell application "System Events"
	set iTermIsRunning to (name of processes) contains "iTerm2"
end tell

if iTermIsRunning then
	tell application "iTerm"
		create window with default profile
	end tell
else
	tell application "iTerm"
		activate
	end tell
end if
