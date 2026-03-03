session_root "$HOME/Developer/work/stuzubi-b2b"
sessions=$(tmux list-sessions || echo)

if [[ "$sessions" == *"vystem"* ]]; then
  echo "shutting down vystem before starting stuzubi"
  valkey-cli shutdown
  tmux kill-session -t vystem
fi
if initialize_session "stuzubi"; then

  new_window "nvim"
  run_cmd "cursor ."
  run_cmd "nvim"

  new_window "servers"
  run_cmd "cd backend/"
  run_cmd "npm run dev"

  select_pane 0
  split_v 50

  run_cmd "cd frontend/"
  run_cmd "nvm use 16 && npm run dev"

  new_window "valkey"
  run_cmd "valkey-server"

  select_window 0

fi

finalize_and_go_to_session
