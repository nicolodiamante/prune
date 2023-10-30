#!/bin/sh

#
# Uninstall Prune
#

# Define paths
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT="${LIB_AGENTS}/com.shell.Prune.plist"

# Remove the agent from launchd if the plist file exists
if [[ -f "${AGENT}" ]]; then
  launchctl remove "${AGENT}"
  if [[ $? -eq 0 ]]; then
    echo "Successfully removed the agent."
  else
    echo "Failed to remove the agent." >&2
  fi
fi

# Check if the file is a symlink before attempting to remove
if [[ -L "${AGENT}" ]]; then
  # Remove the agent file
  if rm -f "${AGENT}"; then
    echo "Successfully removed the agent symlink."
  else
    echo "Failed to remove the agent symlink." >&2
  fi
else
  echo "The agent file is not a symlink or does not exist." >&2
fi
