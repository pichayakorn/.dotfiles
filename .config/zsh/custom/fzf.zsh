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

# 4. Use fd (if available) for much faster and cleaner file searching
if command -v fd >/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# 5. Appearance & Behavior (Catppuccin Mocha + Vim Navigation)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--prompt=' ' --pointer='󰛂 ' --layout=reverse --border --height=40% \
--bind 'ctrl-j:down,ctrl-k:up'"
