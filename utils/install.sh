#!/bin/zsh

#
# Install Prune
#

# Validate OS and version.
if [[ "$OSTYPE" != darwin* ]]; then
  echo "This script is only compatible with macOS." >&2
  exit 1
fi

# Validate macOS version.
SW_VERS=$(sw_vers -buildVersion)
OS_VERS=$(sed -E -e 's/([0-9]{2}).*/\1/' <<<"$SW_VERS")
if [[ "$OS_VERS" -lt 21 ]]; then
  echo "Prune requires macOS 12.6.1 Monterey or later." >&2
  exit 1
fi

# Define paths.
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT_SOURCE="${HOME}/prune/agent/com.shell.Prune.plist"
AGENT_TARGET="${LIB_AGENTS}/com.shell.Prune.plist"
ZSHRC="${XDG_CONFIG_HOME:-$HOME}/.zshrc"

# Log directory and file.
ROOT_DIR="${0:h}/../"
LOG_DIR="${ROOT_DIR}log"

# Ensure the logs directory exists.
if [[ ! -d "$LOG_DIR" ]]; then
  mkdir -p "${LOG_DIR}" || { echo "Failed to create log directory."; exit 1; }
fi

# Ensure the agents directory exists.
if [[ ! -d "$LIB_AGENTS" ]]; then
  mkdir -p "${LIB_AGENTS}" || { echo "Failed to create LaunchAgents directory."; exit 1; }
fi

# Verify if the source agent file exists.
if [[ ! -f "$AGENT_SOURCE" ]]; then
  echo "Agent source file not found: ${AGENT_SOURCE}" >&2
  exit 1
fi

# Create a symbolic link from the agent directory to LIB_AGENTS.
if [[ ! -L "$AGENT_TARGET" ]]; then
  ln -s "${AGENT_SOURCE}" "${AGENT_TARGET}" && echo "Symbolic link created for the agent." || { echo "Failed to create symbolic link."; exit 1; }
fi

# Load the agent if it exists.
if [[ -f "$AGENT_TARGET" ]]; then
  launchctl load "${AGENT_TARGET}" && echo "Agent loaded successfully." || { echo "Failed to load the agent."; exit 1; }
fi

# Backup .zshrc before updating.
if [[ -f "$ZSHRC" ]]; then
  cp "${ZSHRC}" "${ZSHRC}.bak" || { echo "Failed to backup .zshrc."; exit 1; }
fi

# Update .zshrc
if [[ -f "$ZSHRC" ]]; then
  if ! grep -q "alias prune=" "$ZSHRC"; then
    cat << EOF >> "$ZSHRC"
# Launch the Prune script.
alias prune='${HOME}/prune/scripts/prune.zsh'
EOF
    echo "Prune alias added to .zshrc"
  else
    echo "Prune alias already exists in .zshrc"
  fi
else
  echo 'zsh: .zshrc not found! Attempting to create one.' >&2
  touch "$ZSHRC" || { echo "Failed to create .zshrc."; exit 1; }
  cat << EOF >> "${ZSHRC}"
# Launch the Prune script.
alias prune='${HOME}/prune/scripts/prune.zsh'
EOF
  echo "Prune alias added to a new .zshrc"
fi

# Reloads the shell configuration
source "${ZSHRC}" 2> /dev/null || echo "Reload of .zshrc failed. Please source manually."
