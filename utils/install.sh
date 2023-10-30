#!/bin/sh

#
# Install Prune
#

# Validate OS and version
if [[ "$OSTYPE" != darwin* ]]; then
  echo "This script is only compatible with macOS." >&2
  exit 1
fi

SW_VERS=$(sw_vers -buildVersion)
OS_VERS=$(sed -E -e 's/([0-9]{2}).*/\1/' <<<"$SW_VERS")
if [[ "$OS_VERS" -lt 21 ]]; then
  echo "Prune requires macOS 12.6.1 Monterey or later." >&2
  exit 1
fi

# Define paths
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT_SOURCE="./agent/com.shell.Prune.plist"
AGENT_TARGET="${LIB_AGENTS}/com.shell.Prune.plist"
XDG_CONFIG_HOME="${HOME}/.config/zsh"
ZSHRC="${XDG_CONFIG_HOME:-$HOME}/.zshrc"

# Create necessary directories
[[ ! -d "$LIB_AGENTS" ]] && mkdir -p "$LIB_AGENTS"

# Create a symbolic link from the agent directory to LIB_AGENTS
ln -s "$AGENT_SOURCE" "$AGENT_TARGET"

# Load the agent if it exists
if [[ -f "${AGENT_TARGET}" ]]; then
  launchctl load "${AGENT_TARGET}"
fi

# Update .zshrc
if [[ -f "$ZSHRC" ]]; then
  # Append the necessary lines to zshrc.
  cat << EOF >> ${ZSHRC}
# Launch the Prune script.
alias prune='$HOME/prune/scripts/prune.zsh'
EOF
  echo "zsh: append prune's necessary lines to .zshrc"

  # Reloads shell.
  source "${ZSHRC}"
else
  echo 'zsh: zshrc not found!' >&2
fi
