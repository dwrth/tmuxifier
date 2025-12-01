# Enable extended globbing for version string cleanup.
shopt -s extglob

# Output current Tmux version, or compare against a target version.
#
# Usage:
#   tmuxifier-tmux-version             # Outputs current Tmux version
#   tmuxifier-tmux-version "1.9"       # Outputs "=", "<", or ">"
#
# Arguments:
#   $1 - Optional target version to compare against
#
# Output:
#   Without arguments: The current Tmux version string
#   With target version: One of "=", "<", or ">" indicating if the current
#                        Tmux version is equal to, less than, or greater than
#                        the target version.
#
# Returns:
#   0 - Always succeeds
tmuxifier-tmux-version() {
  # Provide tmuxifier help
  if calling-help "$@"; then
    echo "usage: tmuxifier tmux-version [<target-version>]

Outputs current Tmux version. If given optional target-version it outputs one
of three possible characters indicating if the current Tmux version number is
equal to, less than, or greater than the <target-version>.

The three possible outputs are \"=\", \"<\", and \">\"."
    return
  fi

  local version
  version="$(tmux -V)"
  version="${version/tmux /}"

  # Fix for tmux next-* versions
  version="${version/next-/}"

  if [ -z "$1" ]; then
    echo "$version"
    return
  fi

  if [ "$version" == "master" ]; then
    # When version string is "master", tmux was compiled from source, and we
    # assume it's later than whatever the <target-version> is.
    echo '>'
  else
    # Fix for "1.9a" version comparison, as vercomp() can only deal with
    # purely numeric version numbers.
    version="${version//+([a-zA-Z])/}"

    local result
    vercomp "$version" "$1" && result=$? || result=$?
    case $result in
      0) echo '=' ;;
      1) echo '>' ;;
      2) echo '<' ;;
    esac
  fi
}
