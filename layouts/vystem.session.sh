session_root "$HOME/Developer/work/vystem-platform/"
sessions=$(tmux list-sessions || echo)

if [[ "$sessions" == *"stuzubi"* ]]; then
  echo "shutting down stuzubi before starting stuzubi"
  valkey-cli shutdown
  tmux kill-session -t stuzubi
fi
if initialize_session "vystem-platform"; then

  new_window "nvim"
  run_cmd "cursor ."
  run_cmd "nvim"

  new_window "servers"
  run_cmd "cd backend/"
  run_cmd "npm run dev"

  split_v 50
  select_pane 0
  split_h 50
  run_cmd "ngrok http --url=ringtail-stirring-gladly.ngrok-free.app 8080"

  select_pane 2
  run_cmd "cd frontend/"
  run_cmd "yarn dev"

  new_window "valkey"
  run_cmd "valkey-server"

  select_window "servers"

fi

finalize_and_go_to_session
