#! /usr/bin/env bash
source "../../test-helper.sh"
source "${root}/lib/layout-helpers.sh"

#
# split_hl() tests.
#

# When called without arguments, calls tmuxifier-tmux split-window with -h flag.
session="test-session"
window="0"
stub tmuxifier-tmux
stub __go_to_window_or_session_path
split_hl
assert_raises \
  "stub_called_with tmuxifier-tmux split-window -t test-session:0. -h" 0
assert "stub_called_times __go_to_window_or_session_path" "1"
restore __go_to_window_or_session_path
restore tmuxifier-tmux

# When called with column count argument, includes -l flag.
session="test-session"
window="0"
stub tmuxifier-tmux
stub __go_to_window_or_session_path
split_hl 20
assert_raises \
  "stub_called_with tmuxifier-tmux split-window -t test-session:0. -h -l 20" 0
assert "stub_called_times __go_to_window_or_session_path" "1"
restore __go_to_window_or_session_path
restore tmuxifier-tmux

# When called with column count and target pane, targets that pane.
session="mysession"
window="2"
stub tmuxifier-tmux
stub __go_to_window_or_session_path
split_hl 25 1
assert_raises \
  "stub_called_with tmuxifier-tmux split-window -t mysession:2.1 -h -l 25" 0
assert "stub_called_times __go_to_window_or_session_path" "1"
restore __go_to_window_or_session_path
restore tmuxifier-tmux

# When called with only target pane (empty column count), targets that pane.
session="test"
window="1"
stub tmuxifier-tmux
stub __go_to_window_or_session_path
split_hl "" 2
assert_raises \
  "stub_called_with tmuxifier-tmux split-window -t test:1.2 -h" 0
assert "stub_called_times __go_to_window_or_session_path" "1"
restore __go_to_window_or_session_path
restore tmuxifier-tmux

# Integration: actually splits pane in tmux session.
create-test-session
window="0"
stub __go_to_window_or_session_path
assert "test-socket-pane-count" "1"
split_hl
assert "test-socket-pane-count" "2"
split_hl 10
assert "test-socket-pane-count" "3"
restore __go_to_window_or_session_path
kill-test-session

# End of tests.
assert_end "split_hl()"
