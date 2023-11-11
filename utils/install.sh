#!/bin/zsh

#
# Install Prune.
#

# Validate OS.
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is only compatible with macOS" >&2
  exit 1
fi

# Validate macOS version.
SW_VERS=$(sw_vers -buildVersion)
OS_VERS=$(sed -E -e 's/([0-9]{2}).*/\1/' <<<"$SW_VERS")
if [[ "$OS_VERS" -lt 21 ]]; then
  echo "Prune requires macOS 12.6.1 Monterey or later." >&2
  exit 1
fi

# Defines the PATHs.
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT_SOURCE="${HOME}/prune/agent/com.shell.Prune.plist"
AGENT_TARGET="${LIB_AGENTS}/com.shell.Prune.plist"
ZSHRC="${XDG_CONFIG_HOME:-$HOME}/.zshrc"

# Log directory and file.
ROOT_DIR="${0:h}/../"
LOG_DIR="${ROOT_DIR}log"

# Ensure the logs directory exists.
echo "Checking for the logs directory..."
if ! [[ -d "$LOG_DIR" ]]; then
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
if ! [[ -d "$LIB_AGENTS" ]]; then
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
if ! [[ -f "$AGENT_SOURCE" ]]; then
  echo "Agent source file not found: ${AGENT_SOURCE}" >&2
  exit 1
else
  echo "Agent source file found."
fi

# Create a symbolic link for the agent.
echo "Setting up the agent symbolic link..."
if ! [[ -L "$AGENT_TARGET" ]]; then
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

# Backup .zshrc before updating.
if [[ -f "$ZSHRC" ]]; then
  BACKUP="${ZSHRC}.bak_$(date +%F-%H%M%S)"
  echo "Backing up .zshrc..."
  if ! cp "${ZSHRC}" "${BACKUP}"; then
    echo "Failed to backup .zshrc." >&2
    exit 1
  else
    echo "Backup of .zshrc saved as ${BACKUP}."
  fi

  if ! grep -q "alias prune=" "$ZSHRC"; then
    cat << EOF >> "$ZSHRC"
# Run the Prune script.
alias prune='${HOME}/prune/scripts/prune.zsh'
EOF
    echo "Prune alias added to .zshrc"
  else
    echo "Prune alias already exists in .zshrc"
  fi
else
  echo ".zshrc not found, attempting to create a new one..."
  if ! touch "$ZSHRC"; then
    echo "Failed to create .zshrc." >&2
    exit 1
  fi
  echo "Adding 'prune' alias to new .zshrc..."
  cat << EOF >> "$ZSHRC"

# Run the Prune script.
alias prune='${HOME}/prune/scripts/prune.zsh'
EOF
  echo "Prune alias added to a new .zshrc."
fi

# Attempt to reload .zshrc to apply changes.
if ! source "${ZSHRC}" &>/dev/null; then
  echo "Please source .zshrc manually to apply changes." >&2
fi
