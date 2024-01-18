#!/bin/zsh

#
# Uninstall Prune.
#

# Defines the PATHs.
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT="${LIB_AGENTS}/com.shell.Prune.plist"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
LOG_DIR="${HOME}/prune/log" # Update this path as needed.

# Unload the agent if the plist file exists.
echo "Checking for the Prune agent to unload..."
if [[ -f "${AGENT}" ]]; then
  if launchctl unload "${AGENT}"; then
    echo "Prune agent unloaded successfully."
    # Remove the plist file after unloading.
    rm -f "${AGENT}" && echo "Prune agent plist file removed."
  else
    echo "Failed to unload the Prune agent." >&2
    exit 1
  fi
else
  echo "Prune agent plist file does not exist or has already been unloaded."
fi

# Prompt the user before removing the Prune alias.
if [[ -f "$ZSHRC" ]]; then
  echo "Checking for Prune alias in .zshrc..."
  echo "ZSHRC is set to: $ZSHRC"
  if grep -q "alias prune=" "${ZSHRC}"; then
    read -q "REPLY?Do you want to remove the Prune alias from .zshrc? [y/N] "
    echo ""
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/# Run the Prune script./d' "$ZSHRC"
        sed -i '' '/alias prune=/d' "$ZSHRC"
      else
        sed -i '/# Run the Prune script./d' "$ZSHRC"
        sed -i '/alias prune=/d' "$ZSHRC"
      fi
      echo "Prune alias removed from .zshrc."
    else
      echo "No changes made to .zshrc."
    fi
  else
    echo "Prune alias not found in .zshrc."
  fi
else
  echo ".zshrc file not found. No cleanup needed."
fi

# Optionally, remove the logs directory.
read -q "REPLY?Do you want to remove the Prune logs directory? [y/N] "
echo ""
if [[ "$REPLY" =~ ^[Yy]$ ]] && [[ -d "$LOG_DIR" ]]; then
  if rm -rf "$LOG_DIR"; then
    echo "Prune logs directory removed."
  else
    echo "Failed to remove the Prune logs directory." >&2
    exit 1
  fi
else
  echo "Prune logs directory not removed."
fi

echo "Prune uninstallation completed."
