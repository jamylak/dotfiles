tell application "System Events"
	set kittyIsRunning to (name of processes) contains "Kitty"
end tell

if kittyIsRunning then
	do shell script "/Applications/Kitty.app/Contents/MacOS/kitty -d /Users/james --single-instance &>/dev/null; open /Applications/Kitty.app"
else
	do shell script "/Applications/Kitty.app/Contents/MacOS/kitty -d /Users/james --single-instance &>/dev/null &"
end if
