#!/bin/bash

ZSH_CUSTOM="$HOME/.config/zsh/custom"

# Path to the configuration file
PLUGIN_CONF="$ZSH_CUSTOM/scripts/remote-plugins.conf"
echo $PLUGIN_CONF

# Check if the configuration file exists
if [ ! -f "$PLUGIN_CONF" ]; then
  echo "Configuration file $PLUGIN_CONF not found!"
  exit 1
fi

# Function to check for updates
check_for_updates() {
  local plugin=$1
  local url=$2

  cd "$ZSH_CUSTOM/plugins/$plugin" || return

  # Fetch the latest changes from the remote repository
  git fetch

  # Compare the local HEAD with the remote HEAD
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse @{u})

  if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Update available for $plugin"
  else
    echo "No updates for $plugin"
  fi

  cd - >/dev/null || return
}

# Read the configuration file and check for updates
while IFS='=' read -r plugin url; do
  if [ -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    check_for_updates "$plugin" "$url"
  else
    echo "$plugin directory does not exist, skipping..."
  fi
done <"$PLUGIN_CONF"

echo "Update check complete."
