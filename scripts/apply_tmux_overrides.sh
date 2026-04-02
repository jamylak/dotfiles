#!/bin/sh

set -eu

tmux set -g status-left '#[fg=#fbf1c7,bg=#458588,bold] #{?client_prefix,🚀 ,#{?pane_in_mode,👀 ,💣 }}#[bold,nodim]#S '
tmux set -g status-interval 10
tmux set -g status-right '#[fg=#b8bb26,bg=#282828]#($HOME/.tmux/plugins/gruvbox-tmux/src/git-status.sh #{pane_current_path})#[fg=#d3869b,bg=#282828]#($HOME/.tmux/plugins/gruvbox-tmux/src/wb-git-status.sh #{pane_current_path} &)#[fg=#fb4934,bg=#282828]#($HOME/.tmux/plugins/gruvbox-tmux/src/battery-widget.sh)#[fg=#fe8019,bg=#282828,bold]▒ #($HOME/proj/dotfiles/scripts/tmux-metrics.sh)'
