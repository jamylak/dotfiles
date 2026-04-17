# Dotfiles

## Set Fish as Default Shell

```sh
cat /etc/shells
chsh -s "$(command -v fish)"
```

## Symlinks

```
./scripts/init_symlinks.fish
```

## Karabiner Only

```
./scripts/symlink_karabiner.fish
```
