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

## Tests

```sh
fish ./tests/run_all_tests.fish
```

Run one test directly:

```sh
fish ./tests/test_worktree_add.fish
```

## Worktree sessions

Run `coco <branch>` inside Rex to create a worktree, open a Rex session named
after its directory, launch the configured `$AI_CLI` (Codex by default), and
switch to that session. Outside Rex, `coco` opens the worktree through tmux.
The originating Rex session stays in its original directory and keeps its name.
If session creation or switching fails, the worktree remains available and
`coco` reports the failure.

Automatic Rex naming follows the Git root of the session's first terminal pane.
Other panes cannot rename the session. Sessions launched by `coco` receive their
name immediately, before the assistant starts. Directory changes in the owning
pane update its session name immediately, including changes from the Space picker.
