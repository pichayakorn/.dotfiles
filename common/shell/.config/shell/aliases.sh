### ALIASES ###
# Shared by bash (Omarchy) and zsh (macOS / standalone). Keep it POSIX-ish.
if [[ "$(uname -s)" == "Darwin" ]]; then
  source "$HOME/.config/shell/macos.sh"
elif [[ "$(uname -s)" == "Linux" ]]; then
  source "$HOME/.config/shell/linux.sh"
fi

alias v="nvim"
alias vim="nvim"
alias vi="nvim"
alias oldvim="command vim"  # traditional vim (vim/vi above are nvim)

# source
alias so="source"

# list (eza)
alias ls='eza --icons --group-directories-first'
alias la='ls -a'
alias ll='ls -al --header --smart-group --git'
alias lt='ls -a --tree --level=2 -I ".git|node_modules"'
alias ld='ls -aD'
alias l='ls'
alias l.="ls -d .*"

# copy
alias cp="cp -i"

# cat -> bat
alias cat='bat'

# grep -> ripgrep
alias grep='rg'
alias egrep='rg'
alias fgrep='rg'

# Human-readable sizes
alias df='df -h'

# continue download
alias wget="wget -c"

# userlist
alias userlist="cut -d: -f1 /etc/passwd | sort"

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

# add new fonts
alias update-fc='sudo fc-cache -fv'

# fastfetch --short (Omarchy already uses `ff` for an fzf file preview, keep that one)
alias ff >/dev/null 2>&1 || alias ff="fastfetch"
# fastfetch with a random Pokémon (pokeget comes from mise)
alias ffp="pokeget random --hide-name | fastfetch --file-raw -"

# btop --short
alias bt="btop"

# edit configuration files
alias vb="$EDITOR $HOME/.bashrc"
alias vz="$EDITOR $HOME/.zshrc"
alias va="$EDITOR $HOME/.config/shell/aliases.sh"
# alias vf="$EDITOR ~/.config/fish/config.fish"
alias valacritty="$EDITOR $HOME/.config/alacritty/alacritty.toml"
alias vfastfetch="$EDITOR $HOME/.config/fastfetch/config.jsonc"

# source files
alias sb="source ~/.bashrc"
alias sz="source ~/.zshrc"

# Python
alias py="python"

# mise
alias m="mise"
alias mu="mise use"
alias mi="mise install"
alias ml="mise ls"
alias mra="mise run"

# git
alias g="git"
alias ghc="ghq clone"

# pnpm (not installed globally; `mise use pnpm` inside pnpm projects)
alias pn=pnpm

# fix obvious typo's
alias cd..='cd ..'
alias pdw='pwd'
alias exiy='exit'
alias exity='exit'

# Short command
alias dl='yt-dlp'
alias dlfhd='yt-dlp -f "bestvideo[height<=1080]+bestaudio" --merge-output-format mp4 --output "%(title)s.%(ext)s"'
alias dls='yt-split'  # ~/.local/bin/yt-split
alias get-title='yt-dlp --get-filename -o "%(title)s"'
alias dlx='yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s"'  # audio only, as mp3

# ex = EXtractor for all kinds of archives
# usage: ex <file>
alias ex='ouch decompress'

# Kiro CLI chat (clear screen first)
alias kx='printf "\033[2J\033[3J\033[H" && kiro-cli chat --trust-tools=fs_read,fs_write'
