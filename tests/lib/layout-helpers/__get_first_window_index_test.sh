#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# __get_first_window_index() tests
#

function set_up() {
  # Reset session variable to known state
  session=""
}

function tear_down() {
  unset session
}

#
# Return value behavior
#

function test_get_first_window_index_returns_first_index_from_list() {
  session="test-session"
  mock tmuxifier-tmux echo "0"

  local result
  result=$(__get_first_window_index)

  assert_same "0" "$result"
}

function test_get_first_window_index_returns_first_of_multiple_indices() {
  session="test-session"
  mock tmuxifier-tmux echo $'1\n2\n3'

  local result
  result=$(__get_first_window_index)

  assert_same "1" "$result"
}

function test_get_first_window_index_returns_0_when_list_empty() {
  session="test-session"
  mock tmuxifier-tmux echo ""

  local result
  result=$(__get_first_window_index)

  assert_same "0" "$result"
}

function test_get_first_window_index_returns_0_when_command_fails() {
  session="test-session"
  # Simulate tmux command failure by returning nothing
  mock tmuxifier-tmux true

  local result
  result=$(__get_first_window_index)

  assert_same "0" "$result"
}

#
# Non-zero first window index
#

function test_get_first_window_index_handles_nonzero_first_index() {
  session="test-session"
  mock tmuxifier-tmux echo "5"

  local result
  result=$(__get_first_window_index)

  assert_same "5" "$result"
}

function test_get_first_window_index_returns_first_even_when_not_sequential() {
  session="test-session"
  # Simulate windows at indices 3, 7, 12
  mock tmuxifier-tmux echo $'3\n7\n12'

  local result
  result=$(__get_first_window_index)

  assert_same "3" "$result"
}

#
# Session target format
#

function test_get_first_window_index_uses_session_variable() {
  session="my-project"
  spy tmuxifier-tmux

  __get_first_window_index > /dev/null

  assert_have_been_called_with tmuxifier-tmux \
    "list-windows -t my-project: -F #{window_index}"
}

function test_get_first_window_index_includes_trailing_colon_in_target() {
  session="test"
  spy tmuxifier-tmux

  __get_first_window_index > /dev/null

  # Verify the -t argument includes trailing colon
  assert_have_been_called_with tmuxifier-tmux \
    "list-windows -t test: -F #{window_index}"
}

#
# Edge cases
#

function test_get_first_window_index_handles_session_with_special_chars() {
  session="my-project_v2"
  spy tmuxifier-tmux

  __get_first_window_index > /dev/null

  assert_have_been_called_with tmuxifier-tmux \
    "list-windows -t my-project_v2: -F #{window_index}"
}

function test_get_first_window_index_handles_high_window_index() {
  session="test-session"
  mock tmuxifier-tmux echo "999"

  local result
  result=$(__get_first_window_index)

  assert_same "999" "$result"
}

function test_get_first_window_index_handles_empty_session_name() {
  session=""
  spy tmuxifier-tmux

  __get_first_window_index > /dev/null

  assert_have_been_called_with tmuxifier-tmux \
    "list-windows -t : -F #{window_index}"
}
