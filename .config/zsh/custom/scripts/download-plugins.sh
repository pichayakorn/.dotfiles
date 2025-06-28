#!/bin/bash

ZSH_CUSTOM="$HOME/.config/zsh/custom"

# Path to the configuration file
PLUGIN_CONF="$ZSH_CUSTOM/scripts/remote-plugins.conf"

# Check if the configuration file exists
if [ ! -f "$PLUGIN_CONF" ]; then
  echo "Configuration file $PLUGIN_CONF not found!"
  exit 1
fi

# Read the configuration file and clone each plugin
while IFS='=' read -r plugin url; do
  if [ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    echo "Cloning $plugin..."
    git clone --depth 1 "$url" "$ZSH_CUSTOM/plugins/$plugin"
  else
    echo "$plugin already exists, skipping..."
  fi
done <"$PLUGIN_CONF"

echo "All plugins downloaded."
