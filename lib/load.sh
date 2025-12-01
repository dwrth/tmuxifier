# Setup layout path.
if [ -z "${TMUXIFIER_LAYOUT_PATH}" ]; then
  export TMUXIFIER_LAYOUT_PATH="${TMUXIFIER}/layouts"
else
  export TMUXIFIER_LAYOUT_PATH="${TMUXIFIER_LAYOUT_PATH%/}"
fi

# Add tmuxifier's internal commands to PATH.
export PATH="$TMUXIFIER/libexec:$PATH"

# Load utility functions.
source "$TMUXIFIER/lib/util.sh"

# Load command functions from lib/commands/ directory directly.
source "$TMUXIFIER/lib/commands/alias.sh"
source "$TMUXIFIER/lib/commands/resolve-command-path.sh"
source "$TMUXIFIER/lib/commands/tmux-version.sh"
