# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

HOMEBREW_DIR="/opt/homebrew"

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set up fzf key bindings and fuzzy completion
export FZF_DEFAULT_OPS="--extended"
eval "$(fzf --zsh)"

source "$HOME/.cargo/env"
export PKG_CONFIG_PATH="$HOMEBREW_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
eval "$($HOMEBREW_DIR/bin/brew shellenv)"

# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/james/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/james/Downloads/google-cloud-sdk/path.zsh.inc'; fi
# # The next line enables shell command completion for gcloud.
# if [ -f '/Users/james/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/james/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^j' autosuggest-accept
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

source "$HOMEBREW_DIR/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
