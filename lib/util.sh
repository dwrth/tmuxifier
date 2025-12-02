# Check if --help or -h flag is present in arguments.
#
# Usage:
#   calling-help "$@" && { show_help; exit 0; }
#
# Arguments:
#   $@ - Command-line arguments to check
#
# Returns:
#   0 - If --help or -h is present as a standalone argument
#   1 - Otherwise
calling-help() {
  if [[ " $* " != *" --help "* ]] && [[ " $* " != *" -h "* ]]; then
    return 1
  fi
}

# Check if --complete flag is present in arguments.
#
# Used to detect when shell completion is requesting completions.
#
# Usage:
#   calling-complete "$@" && { generate_completions; exit 0; }
#
# Arguments:
#   $@ - Command-line arguments to check
#
# Returns:
#   0 - If --complete is present as a standalone argument
#   1 - Otherwise
calling-complete() {
  if [[ " $* " != *" --complete "* ]]; then
    return 1
  fi
}

# Compare two dot-separated version strings.
#
# Based on: http://stackoverflow.com/a/4025065/42146
#
# Usage:
#   vercomp "1.9.0" "1.10.0"
#   case $? in
#     0) echo "equal" ;;
#     1) echo "first is greater" ;;
#     2) echo "second is greater" ;;
#   esac
#
# Arguments:
#   $1 - First version string (e.g., "1.2.3")
#   $2 - Second version string (e.g., "1.2.4")
#
# Returns:
#   0 - Versions are equal
#   1 - First version is greater than second
#   2 - First version is less than second
vercomp() {
  if [[ "$1" == "$2" ]]; then return 0; fi

  local IFS=. i
  local -a ver1 ver2
  read -ra ver1 <<< "$1"
  read -ra ver2 <<< "$2"

  # Fill empty fields in ver1 with zeros
  for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do ver1[i]=0; done

  for ((i = 0; i < ${#ver1[@]}; i++)); do
    # Fill empty fields in ver2 with zeros
    if [[ -z ${ver2[i]} ]]; then ver2[i]=0; fi

    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    elif ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}
