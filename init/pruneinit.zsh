#!/bin/zsh

#
# Prune - Initialization script for startup processes.
#

# Directory PATHs.
ROOT_DIR="${0:h}/.."
INIT="${ROOT_DIR}/init"

# Delays execution for 5 minutes and then runs pruneops.zsh
sleep 180 && source "${INIT}/.pruneops.zsh"
