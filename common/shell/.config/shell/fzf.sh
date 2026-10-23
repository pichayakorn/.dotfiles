# fzf environment shared by bash and zsh (key bindings live in each shell's rc)

# Use fd (if available) for much faster and cleaner file searching
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Appearance & behavior: 16 ANSI colors so fzf follows the terminal / Omarchy theme
export FZF_DEFAULT_OPTS=" \
--color=16 \
--prompt=' ' --pointer='󰛂 ' --layout=reverse --border --height=40% \
--bind 'ctrl-j:down,ctrl-k:up'"
