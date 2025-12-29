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

do shell script "/opt/homebrew/bin/fish -c 'KITTY_BIN=/Applications/kitty.app/Contents/MacOS/kitty KITTY_LISTEN_ON=(echo unix:(ls -t /tmp/kitty-* | head -n1)) KITTY_WIN_ID=($KITTY_BIN @ ls | jq -r '.[-1].tabs[-1].windows[-1].id') echo ($KITTY_BIN @ send-text --match id:$KITTY_WIN_ID \"nvim_nproj
\")'"
