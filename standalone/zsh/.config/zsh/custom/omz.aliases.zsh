# OMZ Custom plugins handling scripts
ZSH_CUSTOM_SCRIPT="$ZSH_CUSTOM/scripts/"

# Run (not source): the scripts `exit` on errors, which would close the shell
alias omz-d-custom="bash $ZSH_CUSTOM_SCRIPT/download-plugins.sh"
alias omz-up-custom="bash $ZSH_CUSTOM_SCRIPT/update-plugins.sh"

# Edit configuration fies
alias va-omz="$EDITOR $ZSH_CUSTOM/omz.aliases.zsh"
