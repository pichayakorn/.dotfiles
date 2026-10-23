# Bash-only additions (zsh has its own equivalents in ~/.config/zsh/custom/)

# tmux prefix is C-t, so move fzf's file widget (normally C-t) to C-f
if declare -F fzf-file-widget >/dev/null; then
  bind -m emacs-standard -x '"\C-f": fzf-file-widget'
  bind -m vi-insert -x '"\C-f": fzf-file-widget'
fi

# OpenSSH agent (`systemctl --user enable --now ssh-agent.socket`); normally set
# session-wide by ~/.config/environment.d/50-ssh-agent.conf, this covers the rest
if [[ -z "$SSH_AUTH_SOCK" && -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

