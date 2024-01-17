#!/bin/zsh

#
# Prune - Remove superfluous icons in the Launchpad.
#

# Directory PATHs.
ROOT_DIR="${0:h}/.."
SCRIPTS_DIR="${ROOT_DIR}/scripts"

# File containing the list of applications.
APPLICATIONS_FILE="${ROOT_DIR}/config/apps"

# Temporary file for building the cleanup commands.
TEMP_FILE="${SCRIPTS_DIR}/temp_pruneops"

# File containing the cleanup commands.
PRUNEOPS_FILE="${SCRIPTS_DIR}/.pruneops.zsh"

# Define PATHs.
LIB_AGENTS="${HOME}/Library/LaunchAgents"
AGENT="${LIB_AGENTS}/com.shell.Prune.plist"
PLIST_FILE='com.shell.Prune.plist'

# Log file.
LOG_FILE="${ROOT_DIR}/log/prune.log"

# Function to display usage information.
usage() {
  echo "Usage: prune [OPTION]"
  echo "Options:"
  echo "  -l, --load      Load the Prune agent."
  echo "  -u, --unload    Unload the Prune agent."
  echo "  -d, --default   Reset the Launchpad layout to its default state."
  echo "  -c, --check     Check if the Prune agent is loaded."
  echo "  -r, --remove    Remove a specific app from the Launchpad."
  echo "  -h, --help      Display this help message and exit."
  echo ""
  echo "For more help, visit: https://github.com/nicolodiamante/prune"
}

# Check for required commands.
required_commands=(awk sqlite3 find launchctl defaults killall)
for cmd in "${required_commands[@]}"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Required command '$cmd' is not available. Please install it before running this script."
    exit 1
  fi
done

# Function to remove a single app.
remove_single_app() {
  local app_to_remove=$1
  local sqlite_cmd="sqlite3 \$(find /private/var/folders -name com.apple.dock.launchpad)/db/db \"DELETE FROM apps WHERE title='$app_to_remove';\" && killall Dock"

  if ! sudo zsh -c "$sqlite_cmd" 2> "${LOG_FILE}"; then
    echo "Failed to remove ${app_to_remove}. Check log for details." >&2
    exit 1
  else
    echo "Removed ${app_to_remove} from the Launchpad!"
  fi
}

# Parse command-line arguments.
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
elif [[ "$1" == "-c" || "$1" == "--check" ]]; then
  launchctl list | grep com.shell.Prune
  exit 0
elif [[ "$1" == "-l" || "$1" == "--load" ]]; then
  if [[ -f "${AGENT}" ]]; then
    cd "${LIB_AGENTS}" && echo "loading ${PLIST_FILE}"
    launchctl load "${PLIST_FILE}" && popd > /dev/null 2>&1
  else
    echo "Prune agent plist file not found." >&2
  fi
  exit 0
elif [[ "$1" == "-u" || "$1" == "--unload" ]]; then
  if [[ -f "${AGENT}" ]]; then
    cd "${LIB_AGENTS}" && echo "unloading ${PLIST_FILE}"
    launchctl unload "${PLIST_FILE}" && popd > /dev/null 2>&1
  else
    echo "Prune agent plist file not found." >&2
  fi
  exit 0
elif [[ "$1" == "-r" || "$1" == "--remove" ]]; then
  if [[ -z "$2" ]]; then
    echo "Error: No app name provided for removal."
    exit 1
  else
    remove_single_app "${2}"
    exit 0
  fi
fi

# Function to update pruneops.zsh if the apps file has changed.
update_pruneops() {
  # Read the new list of applications from the applications file.
  applications=("${(@f)$(awk -F"'" '/\047/ {print $2}' "$APPLICATIONS_FILE")}")

  # Add shebang to the temporary file and leave a blank line.
  echo "#!/bin/zsh" > "${TEMP_FILE}"
  echo "" >> "${TEMP_FILE}"

  # Build the cleanup commands.
  for app in "${applications[@]:0:${#applications[@]}-1}"; do
    echo -n "sqlite3 \$(find /private/var/folders -name com.apple.dock.launchpad)/db/db \"DELETE FROM apps WHERE title='$app';\"; " >> "${TEMP_FILE}"
  done

  # Add the last command without the semicolon (;) divider, followed by '&& killall Dock'.
  echo -n "sqlite3 \$(find /private/var/folders -name com.apple.dock.launchpad)/db/db \"DELETE FROM apps WHERE title='${applications[-1]}';\" && killall Dock" >> "${TEMP_FILE}"

  # Replace the existing pruneops.zsh file with the new commands
  mv "${TEMP_FILE}" "${PRUNEOPS_FILE}"

  # Check if the mv operation was successful.
  if [[ $? -ne 0 ]]; then
    echo "Failed to update the prune operations file." >&2
    exit 1
  fi

  # Set executable permission only if the file wasn't already executable.
  if [[ ! -x "$PRUNEOPS_FILE" ]]; then
    chmod +x "${PRUNEOPS_FILE}"
  fi
}

# Function to launch pruneops.zsh.
manage_apps() {
  local LAUNCHD_SCRIPTS="${PRUNEOPS_FILE}"

  # Check if sudo requires a password prompt.
  if ! sudo -n true 2>/dev/null; then
    echo "This operation may require elevated privileges."
  fi

  # Run the pruneops script with sudo, always prompting for the password if necessary.
  # Redirect stderr to LOG_FILE only on error.
  if ! sudo zsh "${LAUNCHD_SCRIPTS}" 2> "$LOG_FILE"; then
    echo 'prune: failed to remove icons from the Launchpad. Check log for details.' >&2
    exit 1
  else
    echo 'prune: removed superfluous icons from the Launchpad!'
    # If successful, remove the log file as it was created but it's empty.
    rm -f "${LOG_FILE}"
  fi
}

# Check for '-d' flag to reset Launchpad to default.
if [[ "$1" == "-d" || "$1" == "--default" ]]; then
  echo 'Resetting Launchpad to default...'
  sudo defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock
  exit 0
fi

# Update pruneops.zsh if it doesn't exist, is empty, or if the apps file is newer.
if [[ ! -e "$PRUNEOPS_FILE" || ! -s "$PRUNEOPS_FILE" || "$APPLICATIONS_FILE" -nt "$PRUNEOPS_FILE" ]]; then
  update_pruneops
fi

# Run manage_apps each time, regardless of whether pruneops.zsh was updated.
manage_apps

# Always exit with an explicit status.
exit 0
