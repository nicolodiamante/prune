#!/bin/zsh

#
# Install Prune.
#

# Check if macOS.
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is only compatible with macOS" >&2
  exit 1
fi

# Check if macOS Monterey or later.
SW_VERS=$(sw_vers --productVersion)
OS_VERS=$(echo "$SW_VERS" | cut -d '.' -f 1)
if [[ "$OS_VERS" -lt 12 ]]; then
  echo "Prune requires macOS Monterey (v12) or later." >&2
  exit 1
fi

# Defines the PATHs.
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT_SOURCE="${HOME}/prune/agent/com.shell.Prune.plist"
AGENT_TARGET="${LIB_AGENTS}/com.shell.Prune.plist"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"

# Log directory and file.
ROOT_DIR="${0:h}/.."
LOG_DIR="${ROOT_DIR}/log"

# Ensure the logs directory exists.
echo "Prune: Checking for the logs directory..."
if [[ ! -d "$LOG_DIR" ]]; then
  echo "Prune: Creating the logs directory..."
  if ! mkdir -p "${LOG_DIR}"; then
    echo "Prune: Failed to create log directory." >&2
    exit 1
  fi
  echo "Prune: Logs directory created."
else
  echo "Prune: Logs directory already exists."
fi

# Ensure the agents directory exists.
echo "Prune: Checking for the LaunchAgents directory..."
if [[ ! -d "$LIB_AGENTS" ]]; then
  echo "Prune: Creating the LaunchAgents directory..."
  if ! mkdir -p "${LIB_AGENTS}"; then
    echo "Prune: Failed to create LaunchAgents directory." >&2
    exit 1
  fi
  echo "Prune: LaunchAgents directory created."
else
  echo "Prune: LaunchAgents directory already exists."
fi

# Verify if the source agent file exists.
echo "Checking for the agent source file..."
if [[ ! -f "$AGENT_SOURCE" ]]; then
  echo "Prune: Agent source file not found: ${AGENT_SOURCE}" >&2
  exit 1
else
  # Update plist file with actual home directory.
  sed -i '' "s|@USER_HOME@|${HOME}|g" "${AGENT_SOURCE}"
  echo "Prune: Updated the home directory in the Agent."
fi

# Create a symbolic link for the agent.
echo "Prune: Setting up the agent symbolic link..."
if [[ ! -L "$AGENT_TARGET" ]]; then
  if ! ln -s "${AGENT_SOURCE}" "${AGENT_TARGET}"; then
    echo "Prune: Failed to create symbolic link for the agent." >&2
    exit 1
  else
    echo "Prune: Symbolic link created for the agent."
  fi
else
  echo "Prune: Symbolic link for the agent already exists."
fi

# Load the agent.
echo "Prune: Loading agent..."
if [[ -f "$AGENT_TARGET" ]]; then
  if ! launchctl load "${AGENT_TARGET}"; then
    echo "Prune: Failed to load the agent." >&2
    exit 1
  else
    echo "Prune: Agent loaded successfully."
  fi
else
  echo "Prune: Agent file does not exist, no need to load."
fi

# Update .zshrc with Prune alias.
if [[ -f "$ZSHRC" ]]; then
  echo "Prune: Updating .zshrc..."

  # Check if the alias already exists.
  if ! grep -q "alias prune=" "${ZSHRC}"; then
    echo "" >> "${ZSHRC}"
    echo "# Launch Prune." >> "${ZSHRC}"
    echo "alias prune='${HOME}/prune/script/prune.zsh'" >> "${ZSHRC}"
    echo "Prune: Alias added to .zshrc."
  else
    echo "Prune: Alias already exists in .zshrc."
  fi
else
  # .zshrc not found, create a new one.
  echo ".zshrc not found, creating a new one..."
  if ! touch "${ZSHRC}"; then
    echo "Prune: Failed to create .zshrc." >&2
    exit 1
  fi

  # Add the alias to the new .zshrc file.
  echo "Prune: Adding alias to new .zshrc..."
  echo "" >> "${ZSHRC}"
  echo "# Launch Prune." >> "${ZSHRC}"
  echo "alias prune='${HOME}/prune/script/prune.zsh'" >> "${ZSHRC}"
  echo "Prune: Alias added to a new .zshrc."
fi

# Attempt to reload .zshrc to apply changes.
if ! source "${ZSHRC}" &>/dev/null; then
  echo "Prune: Failed to reload .zshrc. Please reload manually to apply changes." >&2
fi

echo "Prune: Setup complete."
