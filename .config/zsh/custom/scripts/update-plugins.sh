#!/bin/bash

ZSH_CUSTOM="/home/$USER/.config/zsh/custom"

# Path to the configuration file
PLUGIN_CONF="$ZSH_CUSTOM/scripts/remote-plugins.conf"

# Check if the configuration file exists
if [ ! -f "$PLUGIN_CONF" ]; then
  echo "Configuration file $PLUGIN_CONF not found!"
  exit 1
fi

# Read the configuration file and update each plugin
while IFS='=' read -r plugin url; do
  if [ -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    echo "Updating $plugin..."
    cd "$ZSH_CUSTOM/plugins/$plugin" || continue
    git pull
    cd - || exit
  else
    echo "$plugin directory does not exist, skipping..."
  fi
done <"$PLUGIN_CONF"

echo "All plugins updated."
