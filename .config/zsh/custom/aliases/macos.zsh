alias code="codium"

# list
# File and Dir colors for ls and other outputs
export LS_OPTIONS='--color=auto'
alias ls='eza $LS_OPTIONS --icons --git'
alias la='ls -a'
alias ll='ls -alh'
alias l='ls'
alias l.="ls -A | rg -E '^\.'"
alias listdir="ls -d */ > list"

# copy
# Confirm before overwriting something
alias cp="cp -i"

# shutdown or reboot
alias ssn="sudo shutdown -h now"
alias sr="sudo reboot"

# Finder
alias of="open ."

# brew udpate
alias upgrade='brew upgrade'
alias update='brew update && brew upgrade'

# fix obvious typo's
alias b='brew'
alias brwe='brew'
alias brwew='brew'
alias udpate='brew update && brew upgrade'

function brewfix() {
    if [ $# -eq 1 ]; then
        brew uninstall --cask $1 && brew install --cask $1
    else
        echo "Usage: brewfix <cask_name>"
    fi
}

alias bfx='brewfix'
