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

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

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

# conda
alias etconda="conda activate"
alias exconda="conda deactivate"
alias lsconda="conda env list"
alias mkconda="conda create -n"
alias rmconda="conda env remove -n"

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

# # ex = EXtractor for all kinds of archives
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *.tar.zst)   tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Backup temp directory of file
bak() {
  if [[ -z "$1" ]]; then
    echo "Usage: bak <filename|directory>"
    return 1
  fi

  if [[ -d "$1" ]]; then
    cp -r "$1" "${1}.bak"
    echo "Directory $1 backed up as ${1}.bak"
  elif [[ -f "$1" ]]; then
    cp "$1" "${1}.bak"
    echo "File $1 backed up as ${1}.bak"
  else
    echo "Error: $1 is not a valid file or directory"
    return 1
  fi
}

m3u8() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: (ffmpeg)-m3u8 [m3u8 url] [output-name]"
    return 1
  fi
  ffmpeg -protocol_whitelist file,http,https,tcp,tls,crypto -i "${1}" -c copy $2
}

dlt() {
  local title="$1"
  local url="$2"
  if [[ -z "$title" || -z "$url" ]]; then
    echo "Usage: ytcustom \"Title\" \"URL\""
    return 1
  fi
  yt-dlp -o "${title}.%(ext)s" "${url}"
}
