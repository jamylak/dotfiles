# MAC
## Key Repeat & Delay

```sh
defaults read -g KeyRepeat
defaults read -g InitialKeyRepeat
```

https://www.reddit.com/r/neovim/comments/16gr5tz/you_want_speed_youre_not_ready_for_this_much/

```sh
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
```
