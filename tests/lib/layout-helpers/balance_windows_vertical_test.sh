#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# balance_windows_vertical() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_balance_windows_vertical_uses_current_window_by_default() {
  spy tmuxifier-tmux

  balance_windows_vertical

  assert_have_been_called_with \
    tmuxifier-tmux "select-layout -t test-session:0 even-vertical"
}

function test_balance_windows_vertical_with_specific_window() {
  spy tmuxifier-tmux

  balance_windows_vertical 2

  assert_have_been_called_with \
    tmuxifier-tmux "select-layout -t test-session:2 even-vertical"
}

function test_balance_windows_vertical_with_window_name() {
  spy tmuxifier-tmux

  balance_windows_vertical "editor"

  assert_have_been_called_with \
    tmuxifier-tmux "select-layout -t test-session:editor even-vertical"
}

function test_balance_windows_vertical_with_different_session() {
  session="mysession"
  window="3"
  spy tmuxifier-tmux

  balance_windows_vertical

  assert_have_been_called_with \
    tmuxifier-tmux "select-layout -t mysession:3 even-vertical"
}
