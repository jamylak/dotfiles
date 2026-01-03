#!/usr/bin/env fish
# Create or update symlinks from this repo into your home config directories.

set repo_root (pwd)

# Fish
mkdir -p ~/.config/fish
ln -sfn $repo_root/fish/config.fish ~/.config/fish/config.fish

# Alacritty
ln -sfn $repo_root/alacritty ~/.config/alacritty

# Kitty
ln -sfn $repo_root/kitty ~/.config/kitty

# Ghostty
ln -sfn $repo_root/ghostty ~/.config/ghostty

# Helix
ln -sfn $repo_root/helix ~/.config/helix

# Starship
# ln -sfn $repo_root/starship.toml ~/.config/starship.toml

# Yazi
ln -sfn $repo_root/yazi ~/.config/yazi

# Btop
mkdir -p ~/.config/btop
ln -sfn $repo_root/btop/btop.conf ~/.config/btop/btop.conf

# Lazygit
# mkdir -p ~/.config/lazygit
# ln -sfn $repo_root/lazygit/config.yaml ~/.config/lazygit/config.yml

# Nushell
# mkdir -p ~/.config/nushell
# ln -sfn $repo_root/nushell/config.nu ~/.config/nushell/config.nu

# # Karabiner
# mkdir -p ~/.config/karabiner/assets/complex_modifications
# for file in $repo_root/karabiner/*.json
#   set name (basename $file)
#   ln -sfn $file ~/.config/karabiner/assets/complex_modifications/$name
# end

# macOS keybindings
# mkdir -p ~/Library/KeyBindings
# ln -sfn $repo_root/apple/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
