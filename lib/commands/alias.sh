# Resolve a tmuxifier command alias to its full command name.
#
# Usage:
#   tmuxifier-alias <alias>
#
# Arguments:
#   $1 - Alias to resolve
#
# Output:
#   The full command name if alias is recognized, empty otherwise.
#
# Returns:
#   0 - Alias was recognized
#   1 - Alias was not recognized
tmuxifier-alias() {
  # Provide tmuxifier help
  if calling-help "$@"; then
    echo "usage: tmuxifier alias <alias>

Resolve a command alias to it's full name."
    return
  fi

  case "$1" in
    "session" | "ses" | "s")
      echo "load-session"
      ;;
    "window" | "win" | "w")
      echo "load-window"
      ;;
    "new-ses" | "nses" | "ns")
      echo "new-session"
      ;;
    "new-win" | "nwin" | "nw")
      echo "new-window"
      ;;
    "edit-ses" | "eses" | "es")
      echo "edit-session"
      ;;
    "edit-win" | "ewin" | "ew")
      echo "edit-window"
      ;;
    "l")
      echo "list"
      ;;
    "list-ses" | "lses" | "ls")
      echo "list-sessions"
      ;;
    "list-win" | "lwin" | "lw")
      echo "list-windows"
      ;;
    *)
      return 1
      ;;
  esac
}
