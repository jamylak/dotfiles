#!/usr/bin/env fish

set -l search_paths /tmp ~ ~/.local/share ~/.local/share/nvim/lazy ~/.config ~/bar ~/proj

if test (uname) = Darwin
    set search_paths $search_paths /Applications ~/.Trash ~/Desktop ~/Downloads
end

if test -e /etc/NIXOS; and test -e ~/nixconf
    set search_paths $search_paths ~/nixconf
end

set search_paths $search_paths ~/bar/* ~/proj/* ~/.config/dotfiles* ~/.config/nvim*

if test (count $search_paths) -gt 0
    ls -dt $search_paths 2>/dev/null
end
