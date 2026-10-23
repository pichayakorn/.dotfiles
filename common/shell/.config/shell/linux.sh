# Only alias when the binary exists (Omarchy ships VS Code as `code`)
command -v vscodium >/dev/null 2>&1 && alias code="vscodium"
command -v zeditor >/dev/null 2>&1 && alias zed="zeditor"

# list
eval "$(dircolors -b)"

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


# setlocale
alias setlocale="sudo localectl set-locale LANG=en_US.UTF-8"

# pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"
alias rmpacmanlock="sudo rm /var/lib/pacman/db.lck"

# free
# Show sizes in MB
alias free="free -mt"

# Omarchy updates must go through `omarchy update` (snapshots + migrations)
if command -v omarchy >/dev/null 2>&1; then
  _update_cmd="omarchy update"
else
  _update_cmd="sudo pacman -Syyu"
fi
alias update="$_update_cmd"
alias upd="$_update_cmd"
alias udpate="$_update_cmd"
alias upate="$_update_cmd"
alias updte="$_update_cmd"
alias updqte="$_update_cmd"
unset _update_cmd

# pamac (Manjaro only)
if command -v pamac >/dev/null 2>&1; then
  alias pamac-unlock="sudo rm /var/tmp/pamac/dbs/db.lock"
  alias pamac-update="sudo pamac update --no-confirm"
  alias upall="update && pamac-update"
fi

# switch between bash and zsh
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
# alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

# hardware info --short
command -v hwinfo >/dev/null 2>&1 && alias hw="hwinfo --short"

# audio check pulseaudio or pipewire
alias audio="pactl info | grep 'Server Name'"

# check vulnerabilities microcode
alias microcode='grep . /sys/devices/system/cpu/vulnerabilities/*'

# get fastest mirrors in your neighborhood (Manjaro only)
command -v pacman-mirrors >/dev/null 2>&1 && alias mirror='sudo pacman-mirrors --fasttrack 10 && sudo pacman -Syyu'

# give a list of the kernels installed
alias kernel="ls /usr/lib/modules"
alias kernels="ls /usr/lib/modules"

# shutdown or reboot
alias ssn="sudo shutdown now"
alias sr="reboot"

# conda (AUR miniconda3): load on demand instead of `conda init`, keeps shell startup fast
[[ -f /opt/miniconda3/etc/profile.d/conda.sh ]] && alias conda-on='source /opt/miniconda3/etc/profile.d/conda.sh'
