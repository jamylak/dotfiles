tell application "System Events"
	set alacrittyIsRunning to (name of processes) contains "Alacritty"
end tell

if alacrittyIsRunning then
    -- If already running then create window from existing instance then use open
	-- This seems to be the only way happy with amethyst
	do shell script "/Applications/Alacritty.app/Contents/MacOS/alacritty msg create-window --command zsh -ci tmux; open /Applications/Alacritty.app"
else
    -- If not already running just open it normally
	do shell script "/Applications/Alacritty.app/Contents/MacOS/alacritty --command zsh -ci tmux &>/dev/null &"
end if
