#!/usr/bin/env fish

set -l search_paths /tmp ~ ~/.local/share ~/.local/share/nvim/lazy ~/.config ~/proj ~/Downloads

if test (uname) = Darwin
    set search_paths $search_paths /Applications ~/.Trash ~/Desktop
end

if test -e /etc/NIXOS
    set search_paths $search_paths ~/
end

set search_paths $search_paths ~/proj/*

if test (count $search_paths) -gt 0
    ls -dt $search_paths 2>/dev/null
end
