#!/bin/zsh

#
# Uninstall Prune
#

# Defines the PATHs.
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT="${LIB_AGENTS}/com.shell.Prune.plist"
ZSHRC="${XDG_CONFIG_HOME:-$HOME}/.zshrc"

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

# Check for .zshrc and back it up before making changes.
if [[ -f "$ZSHRC" ]]; then
  echo "Found .zshrc at ${ZSHRC}."

  # Check for existing backups.
  existing_backups=( ${ZSHRC}.bak_* )
  if (( ${#existing_backups[@]} > 0 )); then
    # Sort backups by date, descending.
    sorted_backups=($(echo "${existing_backups[@]}" | tr ' ' '\n' | sort -r))
    latest_backup=${sorted_backups[0]}
    echo "Latest backup found at ${latest_backup}."
    read -q "REPLY?Do you want to restore the latest backup instead of creating a new one? [y/N] "
    echo ""
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      # Restore the latest backup.
      if ! cp "$latest_backup" "$ZSHRC"; then
        echo "Failed to restore .zshrc from the latest backup." >&2
        exit 1
      else
        echo "Restored .zshrc from the latest backup."
      fi
    fi
  fi

  if [[ "$REPLY" =~ ^[Nn]$ ]] || [[ -z "$REPLY" ]]; then
    # If the user chooses not to use the latest backup, create a new one.
    BACKUP="${ZSHRC}.bak_$(date +%F-%H%M%S)"
    if ! cp "$ZSHRC" "${BACKUP}"; then
      echo "Failed to backup .zshrc." >&2
      exit 1
    else
      echo "Backup saved as ${BACKUP}."
    fi
  fi

  # Prompt the user before removing the Prune alias.
  read -q "REPLY?Do you want to remove the Prune alias from .zshrc? [y/N] "
  echo ""
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    # Use 'sed' to remove lines related to Prune.
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS requires an empty string as an argument to -i.
      sed -i '' '/alias prune=/d' "$ZSHRC"
    else
      # Linux does not require an empty string as an argument to -i.
      sed -i '/alias prune=/d' "$ZSHRC"
    fi
    echo "Prune configurations have been removed from .zshrc."
  else
    echo "No changes made to .zshrc."
  fi
else
  echo ".zshrc file not found. No cleanup needed."
fi

# Optionally, remove the logs directory.
echo "Checking for the Prune logs directory to remove..."
if [[ -d "$LOG_DIR" ]]; then
  if rm -rf "$LOG_DIR"; then
    echo "Prune logs directory removed."
  else
    echo "Failed to remove the Prune logs directory." >&2
    exit 1
  fi
else
  echo "Prune logs directory not found, no removal necessary."
fi

echo "Prune uninstallation completed."
