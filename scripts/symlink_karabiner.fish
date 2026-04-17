#!/usr/bin/env fish
# Symlink all Karabiner complex modification files from this repo.

set script_dir (dirname (status --current-filename))
set repo_root (realpath $script_dir/..)
set target_dir ~/.config/karabiner/assets/complex_modifications

mkdir -p $target_dir

for file in $repo_root/karabiner/*.json
    set name (basename $file)
    ln -sfn $file $target_dir/$name
end
