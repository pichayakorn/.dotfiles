### ALIASES ###
alias vim="nvim"
alias vi="nvim"
alias oldvim="vim"

# list
# File and Dir colors for ls and other outputs
export LS_OPTIONS='--color=auto'
eval "$(dircolors -b)"
alias ls='exa $LS_OPTIONS'
alias la='ls -a'
alias ll='ls -alh'
alias l='ls'
alias l.="ls -A | grep -E '^\.'"
alias listdir="ls -d */ > list"

# copy 
# Confirm before overwriting something
alias cp="cp -i"

# remove
alias trash="rmtrash"
alias del="rmtrash"
alias deld="del -d"
alias rm="echo Use 'del', or the full path i.e. '/bin/rm'"

# source
alias so="source"

# pacman
alias sps='sudo pacman -S'
alias spr='sudo pacman -R'
alias sprs='sudo pacman -Rs'
alias sprdd='sudo pacman -Rdd'
alias spqo='sudo pacman -Qo'
alias spsii='sudo pacman -Sii'

# show the list of packages that need this package - depends mpv as example
function_depends()  {
    search=$(echo "$1")
    sudo pacman -Sii $search | grep "Required" | sed -e "s/Required By     : //g" | sed -e "s/  /\n/g"
    }

alias depends='function_depends'

# fix obvious typo's
alias cd..='cd ..'
alias pdw='pwd'
alias udpate='sudo pacman -Syyu'
alias upate='sudo pacman -Syyu'
alias updte='sudo pacman -Syyu'
alias updqte='sudo pacman -Syyu'

## Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Human-readable sizes
alias df='df -h'

# setlocale
alias setlocale="sudo localectl set-locale LANG=en_US.UTF-8"
alias setlocales="sudo localectl set-x11-keymap be && sudo localectl set-locale LANG=en_US.UTF-8"

# pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"
alias rmpacmanlock="sudo rm /var/lib/pacman/db.lck"

# free
# Show sizes in MB
alias free="free -mt"

# continue download
alias wget="wget -c"

# userlist
alias userlist="cut -d: -f1 /etc/passwd | sort"

# Aliases for software managment
# pacman
alias pacman="sudo pacman --color auto"
alias update="sudo pacman -Syyu"
alias upd="sudo pacman -Syyu"

# pamac
alias pamac-unlock="sudo rm /var/tmp/pamac/dbs/db.lock"
alias pamac-update="sudo pamac update --no-confirm"

alias upall="update && pamac-update"

# ps
alias psa="ps auxf"
alias psgrep="ps aux | grep -v grep | grep -i -e VSZ -e"

# add new fonts
alias update-fc='sudo fc-cache -fv'

# switch between bash and zsh
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
# alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

# hardware info --short
alias hw="hwinfo --short"

# fastfetch --short
alias ff="fastfetch"
alias ffp="pokeget random --hide-name | fastfetch --file-raw -"

# btop --short
alias bt="btop"

# audio check pulseaudio or pipewire
alias audio="pactl info | grep 'Server Name'"

# check vulnerabilities microcode
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'

# get fastest mirrors in your neighborhood
alias mirror='sudo pacman-mirrors --fasttrack 10 && sudo pacman -Syyu'

# edit configuration files
alias vb="$EDITOR ~/.bashrc"
alias vz="$EDITOR ~/.zshrc"
# alias vf="$EDITOR ~/.config/fish/config.fish"
alias valacritty="$EDITOR /home/$USER/.config/alacritty/alacritty.toml"
alias vfastfetch="$EDITOR /home/$USER/.config/fastfetch/config.jsonc"

# source files
alias sb="source ~/.bashrc"
alias sz="source ~/.zshrc"

# shutdown or reboot
alias ssn="sudo shutdown now"
alias sr="reboot"

# give a list of the kernels installed
alias kernel="ls /usr/lib/modules"
alias kernels="ls /usr/lib/modules"

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

# conda
alias etconda="conda activate"
alias exconda="conda deactivate"
alias lsconda="conda env list"

# git
alias g="git"

# pnpm
alias pn=pnpm

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

