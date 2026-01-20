#!/usr/bin/env fish

set -l search_paths

for p in /tmp ~ ~/.local/share ~/.local/share/nvim/lazy ~/.config ~/bar ~/proj
    if test -e $p
        set search_paths $search_paths $p
    end
end

if test (uname) = Darwin
    for p in /Applications ~/.Trash ~/Desktop ~/Downloads
        if test -e $p
            set search_paths $search_paths $p
        end
    end
end

if test -e /etc/NIXOS; and test -e ~/nixconf
    set search_paths $search_paths ~/nixconf
end

for p in ~/bar/* ~/proj/* ~/.config/dotfiles* ~/.config/nvim*
    if test -e $p
        set search_paths $search_paths $p
    end
end

if test (count $search_paths) -gt 0
    ls -dt $search_paths
end
