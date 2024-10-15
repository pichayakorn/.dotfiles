# OMZ Custom plugins handling scripts
ZSH_CUSTOM_SCRIPT="$ZSH_CUSTOM/scripts/"

alias omz-d-custom="source $ZSH_CUSTOM_SCRIPT/download-plugins.sh"
alias omz-sync-custom="source $ZSH_CUSTOM_SCRIPT/checks-update.sh"
alias omz-up-custom="source $ZSH_CUSTOM_SCRIPT/update-plugins.sh"

# Edit configuration fies
alias va="$EDITOR $ZSH_CUSTOM/aliases.zsh"
alias va-omz="$EDITOR $ZSH_CUSTOM/omz.aliases.zsh"
