#!/bin/zsh

#
# Prune - Remove superfluous icons in the Launchpad.
#

# Directory paths
ROOT_DIR="${0:h}/../"
SCRIPTS_DIR="${ROOT_DIR}scripts/"

# File containing the list of applications
APPLICATIONS_FILE="${ROOT_DIR}apps"

# Temporary file for building the cleanup commands
TEMP_FILE="${SCRIPTS_DIR}temp_pruneops"

# File containing the cleanup commands
PRUNEOPS_FILE="${SCRIPTS_DIR}.pruneops.zsh"

# Function to display usage information
usage() {
  echo "Usage: prune [option]"
  echo "Options:"
  echo "  -l, --load      Load the Prune agent."
  echo "  -u, --unload    Unload the Prune agent."
  echo "  -d, --default   Reset the Launchpad layout to its default state."
  echo "  -c, --check     Check if the Prune agent is loaded."
  echo "  -h, --help      Display this help message and exit."
  echo ""
  echo "For more help, visit: https://github.com/nicolodiamante/prune"
}

LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT="${LIB_AGENTS}/com.shell.Prune.plist"

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
elif [[ "$1" == "-c" || "$1" == "--check" ]]; then
  launchctl list | grep com.shell.Prune
  exit 0
elif [[ "$1" == "-l" || "$1" == "--load" ]]; then
  if [[ -f "${AGENT}" ]]; then
    launchctl load "${AGENT}"
  else
    echo "Prune agent plist file not found." >&2
  fi
  exit 0
elif [[ "$1" == "-u" || "$1" == "--unload" ]]; then
  if [[ -f "${AGENT}" ]]; then
    launchctl unload "${AGENT}"
  else
    echo "Prune agent plist file not found." >&2
  fi
  exit 0
fi

# Function to update pruneops.zsh if the apps file has changed
update_pruneops() {
  # Read the new list of applications from the applications file
  applications=("${(@f)$(awk -F"'" '/\047/ {print $2}' "$APPLICATIONS_FILE")}")

  # Add shebang to the temporary file and leave a blank line
  echo "" >> "$TEMP_FILE"

  # Start the cleanup commands with 'sudo'
  echo -n "sudo " >> "$TEMP_FILE"

  # Build the cleanup commands
  for app in "${applications[@]:0:${#applications[@]}-1}"; do
    echo -n "sqlite3 \$(find /private/var/folders -name com.apple.dock.launchpad)/db/db \"DELETE FROM apps WHERE title='$app';\"; " >> "$TEMP_FILE"
  done

  # Add the last command without the semicolon (;) divider, followed by '&& killall Dock'
  echo -n "sqlite3 \$(find /private/var/folders -name com.apple.dock.launchpad)/db/db \"DELETE FROM apps WHERE title='${applications[-1]}';\" && killall Dock" >> "$TEMP_FILE"

  # Replace the existing pruneops.zsh file with the new commands
  mv "$TEMP_FILE" "$PRUNEOPS_FILE"
}

# Function to launch pruneops.zsh
manage_apps() {
  typeset LAUNCHD_SCRIPTS="$PRUNEOPS_FILE"
  # Remove superfluous icons from Launchpad.
  source "${LAUNCHD_SCRIPTS}" > /dev/null 2>&1 &&
  echo 'prune: removed superfluous icons from the Launchpad!'
}

# Check for '-d' flag to reset Launchpad to default
if [[ "$1" == "-d" || "$1" == "--default" ]]; then
  echo 'Resetting Launchpad to default...'
  sudo defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock
  exit 0
fi

# Update pruneops.zsh if it doesn't exist, is empty, or if the apps file is newer
if [[ ! -e "$PRUNEOPS_FILE" || ! -s "$PRUNEOPS_FILE" || "$APPLICATIONS_FILE" -nt "$PRUNEOPS_FILE" ]]; then
  update_pruneops
fi

# Run manage_apps each time, regardless of whether pruneops.zsh was updated
manage_apps
