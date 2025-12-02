#! /usr/bin/env bash
source "../../test-helper.sh"
source "${root}/lib/layout-helpers.sh"

#
# split_v() tests.
#

# When called without arguments, calls tmuxifier-tmux split-window with -v flag.
session="test-session"
window="0"
stub tmuxifier-tmux
stub __go_to_window_or_session_path
split_v
assert_raises \
  "stub_called_with tmuxifier-tmux split-window -t test-session:0. -v" 0
assert "stub_called_times __go_to_window_or_session_path" "1"
restore __go_to_window_or_session_path
restore tmuxifier-tmux

# When called with percentage argument, includes -p flag.
session="test-session"
window="0"
stub tmuxifier-tmux
stub __go_to_window_or_session_path
split_v 30
assert_raises \
  "stub_called_with tmuxifier-tmux split-window -t test-session:0. -v -p 30" 0
assert "stub_called_times __go_to_window_or_session_path" "1"
restore __go_to_window_or_session_path
restore tmuxifier-tmux

# When called with percentage and target pane, targets that pane.
session="mysession"
window="2"
stub tmuxifier-tmux
stub __go_to_window_or_session_path
split_v 50 1
assert_raises \
  "stub_called_with tmuxifier-tmux split-window -t mysession:2.1 -v -p 50" 0
assert "stub_called_times __go_to_window_or_session_path" "1"
restore __go_to_window_or_session_path
restore tmuxifier-tmux

# When called with only target pane (empty percentage), targets that pane.
session="test"
window="1"
stub tmuxifier-tmux
stub __go_to_window_or_session_path
split_v "" 2
assert_raises \
  "stub_called_with tmuxifier-tmux split-window -t test:1.2 -v" 0
assert "stub_called_times __go_to_window_or_session_path" "1"
restore __go_to_window_or_session_path
restore tmuxifier-tmux

# Integration: actually splits pane in tmux session.
create-test-session
window="0"
stub __go_to_window_or_session_path
assert "test-socket-pane-count" "1"
split_v
assert "test-socket-pane-count" "2"
split_v 30
assert "test-socket-pane-count" "3"
restore __go_to_window_or_session_path
kill-test-session

# End of tests.
assert_end "split_v()"
