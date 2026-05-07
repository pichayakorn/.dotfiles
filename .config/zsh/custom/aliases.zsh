### ALIASES ###
if [[ "$(uname -s)" == "Darwin" ]]; then
  source $ZSH_CUSTOM/aliases/macos.zsh
elif [[ "$(uname -s)" == "Linux" ]]; then
  source $ZSH_CUSTOM/aliases/linux.zsh
fi

alias v="nvim"
alias vim="nvim"
alias vi="nvim"
alias oldvim="vim"

# source
alias so="source"

# list
export LS_OPTIONS='--color=auto'
alias ls='eza $LS_OPTIONS --icons --git --group-directories-first'
alias la='ls -a'
alias ll='ls -alh --header --smart-group'
alias lt='ls -a --tree --level=2'
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

# fastfetch --short
alias ff="fastfetch"

# btop --short
alias bt="btop"

# edit configuration files
alias vb="$EDITOR $HOME/.bashrc"
alias vz="$EDITOR $HOME/.zshrc"
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

# pnpm
alias pn=pnpm

# fix obvious typo's
alias cd..='cd ..'
alias pdw='pwd'
alias exiy='exit'
alias exity='exit'

# Short command
alias dl='yt-dlp'
alias dlfhd='yt-dlp -f "bestvideo[height<=1080]+bestaudio"'
alias get-title='yt-dlp --get-filename -o "%(title)s"'

# ex = EXtractor for all kinds of archives
# usage: ex <file>
alias ex='ouch decompress'
