#!/bin/sh

# Determines the current user's shell.
[[ "$SHELL" == */zsh ]] || exit 1

SOURCE="https://github.com/nicolodiamante/prune"
TARBALL="${SOURCE}/tarball/master"
TARGET="${HOME}/prune"
TAR_CMD="tar -xzv -C \"${TARGET}\" --strip-components 1 --exclude .gitignore"

INSTALL=./utils/install.sh

is_executable() {
  command -v "$1" > /dev/null 2>&1
}

# Checks which executable is available then downloads and installs.
if is_executable "git"; then
  CMD="git clone ${SOURCE} ${TARGET}"
elif is_executable "curl"; then
  CMD="curl -L ${TARBALL} | ${TAR_CMD}"
elif is_executable "wget"; then
  CMD="wget --no-check-certificate -O - ${TARBALL} | ${TAR_CMD}"
fi

if [[ -z "$CMD" ]]; then
  echo 'No git, curl or wget available. Aborting!'
else
  echo 'Installing prune...'
  mkdir -p "$TARGET"

  if eval "$CMD"; then
    cd "$TARGET" && source "$INSTALL"
  else
    echo "Installation failed. Aborting!"
  fi
fi
