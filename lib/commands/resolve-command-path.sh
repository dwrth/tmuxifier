# Resolve the absolute path to a tmuxifier command or alias.
#
# Usage:
#   tmuxifier-resolve-command-path <command_or_alias>
#
# Arguments:
#   $1 - Command name or alias to resolve
#
# Output:
#   The absolute path to the command executable, or empty if not found.
#
# Returns:
#   0 - Command was found
#   1 - Command was not found
tmuxifier-resolve-command-path() {
  # Provide tmuxifier help
  if calling-help "$@"; then
    echo "usage: tmuxifier resolve-command-path <command_or_alias>

Outputs the absolute path to the given command or command alias."
    return
  fi

  local command_path=""

  if [ -n "$1" ]; then
    # Look for executable file, not functions.
    command_path="$(type -P "tmuxifier-$1" 2> /dev/null)" || true
    if [ -z "$command_path" ]; then
      local resolved
      resolved="$(tmuxifier-alias "$1")"
      if [ -n "$resolved" ]; then
        command_path="$(type -P "tmuxifier-$resolved" 2> /dev/null)" || true
      fi
    fi
  fi

  if [ -n "$command_path" ]; then
    echo "$command_path"
  else
    return 1
  fi
}
