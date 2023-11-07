#!/bin/zsh

#
# Uninstall Prune
#

# Define paths
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT="${LIB_AGENTS}/com.shell.Prune.plist"
ZSHRC="${XDG_CONFIG_HOME:-$HOME}/.zshrc"

# Remove the agent from launchd if the plist file exists
if [[ -f "${AGENT}" ]]; then
  launchctl unload "${AGENT}" && echo "Agent unloaded successfully." || { echo "Failed to unload the agent." >&2; exit 1; }
fi

# Check if the file is a symlink before attempting to remove
if [[ -L "${AGENT}" ]]; then
  # Remove the agent file
  rm -f "${AGENT}" && echo "Successfully removed the agent symlink." || { echo "Failed to remove the agent symlink." >&2; exit 1; }
else
  echo "The agent symlink does not exist, skipping removal."
fi

# Check if .zshrc contains the prune alias and remove it
if [[ -f "$ZSHRC" ]]; then
  if grep -q "alias prune=" "${ZSHRC}"; then
    # Use sed to remove the alias line
    sed -i '' '/alias prune=/d' "${ZSHRC}" && echo "Prune alias removed from .zshrc." || { echo "Failed to remove Prune alias from .zshrc." >&2; exit 1; }
  else
    echo "Prune alias not found in .zshrc, skipping removal."
  fi
else
  echo "zshrc file does not exist, skipping alias removal."
fi

# Optionally, you can also remove the logs directory
LOG_DIR="${HOME}/prune/logs"
if [[ -d "$LOG_DIR" ]]; then
  rm -rf "${LOG_DIR}" && echo "Prune logs directory removed." || { echo "Failed to remove Prune logs directory." >&2; exit 1; }
else
  echo "Prune logs directory does not exist, skipping removal."
fi

echo "Uninstallation of Prune is complete."
