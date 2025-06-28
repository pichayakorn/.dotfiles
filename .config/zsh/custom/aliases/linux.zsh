alias code="vscodium"

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

alias udpate='sudo pacman -Syyu'
alias upate='sudo pacman -Syyu'
alias updte='sudo pacman -Syyu'
alias updqte='sudo pacman -Syyu'

# setlocale
alias setlocale="sudo localectl set-locale LANG=en_US.UTF-8"
alias setlocales="sudo localectl set-x11-keymap be && sudo localectl set-locale LANG=en_US.UTF-8"

# pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"
alias rmpacmanlock="sudo rm /var/lib/pacman/db.lck"

# free
# Show sizes in MB
alias free="free -mt"

# Aliases for software managment
# pacman
alias pacman="sudo pacman --color auto"
alias update="sudo pacman -Syyu"
alias upd="sudo pacman -Syyu"

# pamac
alias pamac-unlock="sudo rm /var/tmp/pamac/dbs/db.lock"
alias pamac-update="sudo pamac update --no-confirm"

alias upall="update && pamac-update"

# switch between bash and zsh
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
# alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

# hardware info --short
alias hw="hwinfo --short"

# fastfetch --short
alias ffp="pokeget random --hide-name | fastfetch --file-raw -"

# audio check pulseaudio or pipewire
alias audio="pactl info | grep 'Server Name'"

# check vulnerabilities microcode
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'

# get fastest mirrors in your neighborhood
alias mirror='sudo pacman-mirrors --fasttrack 10 && sudo pacman -Syyu'

# give a list of the kernels installed
alias kernel="ls /usr/lib/modules"
alias kernels="ls /usr/lib/modules"

# shutdown or reboot
alias ssn="sudo shutdown now"
alias sr="reboot"

# Zerotier-one
alias ztstart="sudo systemctl start zerotier-one"
alias ztstop="sudo systemctl stop zerotier-one"
alias ztstatus="sudo systemctl status zerotier-one"
alias zt="sudo zerotier-cli"
alias zti="zt info"
alias ztl="zt listnetworks"