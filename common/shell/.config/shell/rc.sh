# Entry point for personal shell config, sourced by ~/.bashrc (Omarchy) and
# ~/.config/zsh/custom/aliases.zsh (zsh). Functions load before aliases so the
# aliases (e.g. grep -> rg) don't get expanded inside function bodies.
source "$HOME/.config/shell/functions.sh"
source "$HOME/.config/shell/aliases.sh"
source "$HOME/.config/shell/fzf.sh"
if [[ -n "$BASH_VERSION" ]]; then
  source "$HOME/.config/shell/bash.sh"
fi
