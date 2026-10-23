# fzf configuration
# -----------------

# 1. Determine the fzf base directory
if [[ -d "/opt/homebrew/opt/fzf" ]]; then
  FZF_BASE="/opt/homebrew/opt/fzf"
elif [[ -d "/usr/local/opt/fzf" ]]; then
  FZF_BASE="/usr/local/opt/fzf"
elif [[ -d "/usr/share/fzf" ]]; then
  # Standard Linux location (e.g., Arch)
  FZF_BASE="/usr/share/fzf"
fi

# 2. Source completion and key-bindings if fzf is found
if [[ -n "$FZF_BASE" ]]; then
  # Use the shell directory for Homebrew, or the base for Linux
  if [[ -d "$FZF_BASE/shell" ]]; then
    FZF_SHELL="$FZF_BASE/shell"
  else
    FZF_SHELL="$FZF_BASE"
  fi

  [[ $- == *i* ]] && source "$FZF_SHELL/completion.zsh" 2> /dev/null
  source "$FZF_SHELL/key-bindings.zsh"
fi

# 3. Handle keybinding conflict with tmux prefix (Ctrl+t)
# Rebind the file widget to Ctrl+f (Find)
if bindkey | grep -q 'fzf-file-widget'; then
  bindkey '^F' fzf-file-widget
  # Optionally unbind Ctrl+t to avoid confusion, though tmux will catch it first
  # bindkey -r '^T'
fi

# 4. fd command and appearance are shared with bash: ~/.config/shell/fzf.sh
