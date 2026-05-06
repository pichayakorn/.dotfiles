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

# Gemini-cli
alias ask='gemini -p'

# ex = EXtractor for all kinds of archives
# usage: ex <file>
alias ex='ouch decompress'

# Backup file or directory with date and versioning
backup() {
  local target="$1"
  if [[ -z "$target" ]]; then
    echo "Usage: backup <filename|directory>"
    return 1
  fi

  if [[ ! -e "$target" ]]; then
    echo "Error: $target is not a valid file or directory"
    return 1
  fi

  local date=$(date +%Y-%m-%d)
  local base_backup="${target}.${date}"
  local final_backup="${base_backup}.bak"

  if [[ -e "$final_backup" ]]; then
    local version=2
    while [[ -e "${base_backup}_v${version}.bak" ]]; do
      ((version++))
    done
    final_backup="${base_backup}_v${version}.bak"
  fi

  if [[ -d "$target" ]]; then
    cp -r "$target" "$final_backup"
    echo "Directory $target backed up as $final_backup"
  else
    cp "$target" "$final_backup"
    echo "File $target backed up as $final_backup"
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
    echo "Usage: dlt \"Title\" \"URL\""
    return 1
  fi
  yt-dlp -o "${title}.%(ext)s" "${url}"
}
