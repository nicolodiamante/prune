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
echo "Checking for the logs directory..."
if [[ ! -d "$LOG_DIR" ]]; then
  echo "Creating the logs directory..."
  if ! mkdir -p "${LOG_DIR}"; then
    echo "Failed to create log directory." >&2
    exit 1
  fi
  echo "Logs directory created."
else
  echo "Logs directory already exists."
fi

# Ensure the agents directory exists.
echo "Checking for the LaunchAgents directory..."
if [[ ! -d "$LIB_AGENTS" ]]; then
  echo "Creating the LaunchAgents directory..."
  if ! mkdir -p "${LIB_AGENTS}"; then
    echo "Failed to create LaunchAgents directory." >&2
    exit 1
  fi
  echo "LaunchAgents directory created."
else
  echo "LaunchAgents directory already exists."
fi

# Verify if the source agent file exists.
echo "Checking for the agent source file..."
if [[ ! -f "$AGENT_SOURCE" ]]; then
  echo "Agent source file not found: ${AGENT_SOURCE}" >&2
  exit 1
else
  # Update plist file with actual home directory.
  sed -i '' "s|@USER_HOME@|${HOME}|g" "${AGENT_SOURCE}"
  echo "Updated the home directory in the Agent."
fi

# Create a symbolic link for the agent.
echo "Setting up the agent symbolic link..."
if [[ ! -L "$AGENT_TARGET" ]]; then
  if ! ln -s "${AGENT_SOURCE}" "${AGENT_TARGET}"; then
    echo "Failed to create symbolic link for the agent." >&2
    exit 1
  else
    echo "Symbolic link created for the agent."
  fi
else
  echo "Symbolic link for the agent already exists."
fi

# Load the agent.
echo "Loading the agent..."
if [[ -f "$AGENT_TARGET" ]]; then
  if ! launchctl load "${AGENT_TARGET}"; then
    echo "Failed to load the agent." >&2
    exit 1
  else
    echo "Agent loaded successfully."
  fi
else
  echo "Agent file does not exist, no need to load."
fi

# Update .zshrc with Prune alias.
if [[ -f "$ZSHRC" ]]; then
  echo "Updating .zshrc..."

  # Check if the alias already exists.
  if ! grep -q "alias prune=" "${ZSHRC}"; then
    echo "" >> "${ZSHRC}"
    echo "# Run the Prune script." >> "${ZSHRC}"
    echo "alias prune='${HOME}/prune/scripts/prune.zsh'" >> "${ZSHRC}"
    echo "Prune alias added to .zshrc."
  else
    echo "Prune alias already exists in .zshrc."
  fi
else
  # .zshrc not found, create a new one.
  echo ".zshrc not found, creating a new one..."
  if ! touch "${ZSHRC}"; then
    echo "Failed to create .zshrc." >&2
    exit 1
  fi

  # Add the alias to the new .zshrc file.
  echo "Adding 'prune' alias to new .zshrc..."
  echo "" >> "${ZSHRC}"
  echo "# Run the Prune script." >> "${ZSHRC}"
  echo "alias prune='${HOME}/prune/scripts/prune.zsh'" >> "${ZSHRC}"
  echo "Prune alias added to a new .zshrc."
fi

# Attempt to reload .zshrc to apply changes.
if ! source "${ZSHRC}" &>/dev/null; then
  echo "Please source .zshrc manually to apply changes." >&2
fi

echo "Prune setup complete."
