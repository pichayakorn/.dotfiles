alias code="codium"

# list
# File and Dir colors for ls and other outputs
export LS_OPTIONS='--color=auto'
alias ls='lsd $LS_OPTIONS'
alias la='ls -a'
alias ll='ls -alh'
alias l='ls'
alias l.="ls -A | grep -E '^\.'"
alias listdir="ls -d */ > list"

# copy 
# Confirm before overwriting something
alias cp="cp -i"

# shutdown or reboot
alias ssn="sudo shutdown -h now"
alias sr="sudo reboot"

# Finder
alias fd="open ."

# brew udpate
alias update='brew update'
alias upgrade='brew upgrade'

# fix obvious typo's
alias b='brew'
alias brwe='brew'
alias brwew='brew'
alias udpate='brew update'

function brewfix() {
    if [ $# -eq 1 ]; then
        brew uninstall --cask $1 && brew install --cask $1
    else
        echo "Usage: brewfix <cask_name>"
    fi
}
