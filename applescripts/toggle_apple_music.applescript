tell application "Music"
    if player state is playing then
        pause
    else
        play
    end if
end tell
