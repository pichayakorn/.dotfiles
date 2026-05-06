alias code="codium"

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
