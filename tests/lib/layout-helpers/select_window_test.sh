#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# select_window() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_select_window_calls_tmux_select_window() {
  spy tmuxifier-tmux
  mock __get_current_window_index echo "1"

  select_window 1

  assert_have_been_called_with tmuxifier-tmux "select-window -t test-session:1"
}

function test_select_window_with_window_name() {
  spy tmuxifier-tmux
  mock __get_current_window_index echo "editor"

  select_window "editor"

  assert_have_been_called_with \
    tmuxifier-tmux "select-window -t test-session:editor"
}

function test_select_window_updates_window_variable() {
  spy tmuxifier-tmux
  mock __get_current_window_index echo "5"

  select_window 5

  assert_equals "5" "$window"
}

function test_select_window_with_different_session() {
  session="mysession"
  spy tmuxifier-tmux
  mock __get_current_window_index echo "2"

  select_window 2

  assert_have_been_called_with tmuxifier-tmux "select-window -t mysession:2"
}
