#!/bin/zsh

#
# Start Prune Installation.
#

# Validate OS.
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is only compatible with macOS" >&2
  exit 1
fi

# Determines the current user's shell.
if [[ "$SHELL" != */zsh ]]; then
  echo "Please switch to zsh shell to continue."
  exit 1
fi

# Defines the PATHs.
SOURCE="https://github.com/nicolodiamante/prune"
TARBALL="${SOURCE}/tarball/master"
TARGET="${HOME}/prune"
TAR_CMD="tar -xzv -C \"${TARGET}\" --strip-components 1 --exclude .gitignore"
INSTALL="${TARGET}/utils/install.zsh"

# Check if a command is executable.
is_executable() {
  command -v "$1" &> /dev/null
}

# Ensure TARGET directory doesn't already exist.
if [[ -d "$TARGET" ]]; then
  echo "Target directory ${TARGET} already exists. Please remove or rename it and try again."
  exit 1
fi

# Checks which executable is available then downloads and installs.
if is_executable "git"; then
  CMD="git clone ${SOURCE} ${TARGET}"
elif is_executable "curl"; then
  CMD="curl -L ${TARBALL} | ${TAR_CMD}"
elif is_executable "wget"; then
  CMD="wget --no-check-certificate -O - ${TARBALL} | ${TAR_CMD}"
else
  echo 'No git, curl, or wget available. Aborting!'
  exit 1
fi

echo 'Installing Prune...'

# Create the target directory and proceed with the chosen download method.
if ! mkdir -p "${TARGET}"; then
  echo "Error: Failed to create target directory. Aborting!" >&2
  exit 1
fi

# Execute the download command and run the installation script.
if eval "${CMD}"; then
  if cd "${TARGET}"; then
    if ! source "${INSTALL}"; then
      echo "Error: Failed to run the install script. Aborting!" >&2
      exit 1
    fi
  else
    echo "Error: Failed to navigate to ${TARGET}. Aborting!" >&2
    exit 1
  fi
else
  echo "Download failed. Aborting!" >&2
  exit 1
fi
