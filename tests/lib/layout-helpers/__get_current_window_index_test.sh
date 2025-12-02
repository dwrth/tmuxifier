#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# __get_current_window_index() tests
#

function set_up() {
  # Reset session variable to known state
  session=""
}

function tear_down() {
  unset session
}

#
# Basic functionality
#

function test_get_current_window_index_returns_active_window_index() {
  session="test-session"
  mock tmuxifier-tmux << EOF
1:0
0:1
0:2
EOF

  local result
  result=$(__get_current_window_index)

  assert_same "0" "$result"
}

function test_get_current_window_index_returns_index_when_second_window_active() {
  session="test-session"
  mock tmuxifier-tmux << EOF
0:0
1:1
0:2
EOF

  local result
  result=$(__get_current_window_index)

  assert_same "1" "$result"
}

function test_get_current_window_index_returns_index_when_last_window_active() {
  session="test-session"
  mock tmuxifier-tmux << EOF
0:0
0:1
1:2
EOF

  local result
  result=$(__get_current_window_index)

  assert_same "2" "$result"
}

#
# Non-standard window indices
#

function test_get_current_window_index_handles_non_zero_base_index() {
  session="test-session"
  # When base-index is 1
  mock tmuxifier-tmux << EOF
1:1
0:2
0:3
EOF

  local result
  result=$(__get_current_window_index)

  assert_same "1" "$result"
}

function test_get_current_window_index_handles_high_window_index() {
  session="test-session"
  mock tmuxifier-tmux << EOF
0:0
0:1
1:999
EOF

  local result
  result=$(__get_current_window_index)

  assert_same "999" "$result"
}

function test_get_current_window_index_handles_gaps_in_window_indices() {
  session="test-session"
  # Windows 0, 5, 10 with window 5 being active
  mock tmuxifier-tmux << EOF
0:0
1:5
0:10
EOF

  local result
  result=$(__get_current_window_index)

  assert_same "5" "$result"
}

#
# Single window
#

function test_get_current_window_index_returns_index_for_single_window() {
  session="test-session"
  mock tmuxifier-tmux echo "1:0"

  local result
  result=$(__get_current_window_index)

  assert_same "0" "$result"
}

function test_get_current_window_index_returns_index_for_single_window_non_zero() {
  session="test-session"
  mock tmuxifier-tmux echo "1:5"

  local result
  result=$(__get_current_window_index)

  assert_same "5" "$result"
}

#
# Edge cases and error handling
#

function test_get_current_window_index_returns_empty_when_no_active_window() {
  session="test-session"
  # No window marked as active (shouldn't happen in practice)
  mock tmuxifier-tmux << EOF
0:0
0:1
0:2
EOF

  local result
  result=$(__get_current_window_index)

  assert_empty "$result"
}

function test_get_current_window_index_returns_empty_when_no_windows() {
  session="test-session"
  mock tmuxifier-tmux echo ""

  local result
  result=$(__get_current_window_index)

  assert_empty "$result"
}

function test_get_current_window_index_returns_empty_on_tmux_error() {
  session="test-session"
  # Simulate tmux error (stderr is redirected to /dev/null in the function)
  mock tmuxifier-tmux return 1

  local result
  result=$(__get_current_window_index)

  assert_empty "$result"
}

#
# Tmux command verification
#

function test_get_current_window_index_calls_tmux_with_correct_args() {
  session="my-session"
  spy tmuxifier-tmux

  __get_current_window_index

  assert_have_been_called_with tmuxifier-tmux \
    "list-windows -t my-session: -F #{window_active}:#{window_index}"
}

function test_get_current_window_index_uses_session_variable() {
  session="another-session"
  spy tmuxifier-tmux

  __get_current_window_index

  assert_have_been_called_with tmuxifier-tmux \
    "list-windows -t another-session: -F #{window_active}:#{window_index}"
}

function test_get_current_window_index_handles_special_session_names() {
  session="my-project_v2"
  spy tmuxifier-tmux

  __get_current_window_index

  assert_have_been_called_with tmuxifier-tmux \
    "list-windows -t my-project_v2: -F #{window_active}:#{window_index}"
}
