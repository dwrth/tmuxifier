#!/usr/bin/env bash

# Mango tmux worktree launcher session layout.

session_root_dir="$HOME"
if [ -n "${MANGO_ROOT-}" ] && [ -d "$MANGO_ROOT" ]; then
  session_root_dir="$MANGO_ROOT"
fi

session_root "$session_root_dir"

session_name="${MANGO_SESSION_NAME:-mango}"

has_service() {
  local name="$1"
  if [ -z "${MANGO_SERVICES-}" ]; then
    return 1
  fi

  case ",$MANGO_SERVICES," in
    *,"$name",*) return 0 ;;
    *)           return 1 ;;
  esac
}

if initialize_session "$session_name"; then

  # Editor window: start Cursor in project root.
  new_window "cursor" "cursor ."

  # Main application window.
  new_window "app"

  # Backend in the large top pane (pane 0).
  if has_service "backend"; then
    run_cmd "cd backend && npm run dev"
  fi

  # Collect non-backend app services for the bottom strip.
  bottom_services=()
  for svc in frontend admin sales organizer_app mobile_app; do
    if has_service "$svc"; then
      bottom_services+=("$svc")
    fi
  done

  if [ "${#bottom_services[@]}" -gt 0 ]; then
    # Create a bottom row taking a smaller portion of the screen.
    split_v 35

    # Ensure we're on the bottom pane.
    select_pane 1

    idx=0
    for svc in "${bottom_services[@]}"; do
      if [ "$idx" -gt 0 ]; then
        # Split the current bottom-right pane horizontally for the next service.
        split_h 50
      fi

      case "$svc" in
        frontend)
          run_cmd "cd frontend && yarn dev"
          ;;
        admin)
          run_cmd "cd admin && PORT=3001 npm run dev"
          ;;
        sales)
          run_cmd "cd sales && PORT=3002 npm run dev"
          ;;
        organizer_app)
          run_cmd "cd organizer_app && npx expo start"
          ;;
        mobile_app)
          run_cmd "cd mobile_app && npx expo start"
          ;;
      esac

      idx=$((idx + 1))
    done
  fi

  # Infra window: valkey + ngrok side by side.
  new_window "infra"
  run_cmd "valkey-server"
  split_h 50
  run_cmd "ngrok http --url=ringtail-stirring-gladly.ngrok-free.app 8080"

  # Land back on the app window.
  select_window "app"

fi

finalize_and_go_to_session

