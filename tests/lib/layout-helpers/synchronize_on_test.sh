#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# synchronize_on() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_synchronize_on_uses_current_window_by_default() {
  spy tmuxifier-tmux

  synchronize_on

  assert_have_been_called_with \
    tmuxifier-tmux "set-window-option -t test-session:0 synchronize-panes on"
}

function test_synchronize_on_with_specific_window() {
  spy tmuxifier-tmux

  synchronize_on 2

  assert_have_been_called_with \
    tmuxifier-tmux "set-window-option -t test-session:2 synchronize-panes on"
}

function test_synchronize_on_with_window_name() {
  spy tmuxifier-tmux

  synchronize_on "editor"

  assert_have_been_called_with \
    tmuxifier-tmux "set-window-option -t test-session:editor synchronize-panes on"
}

function test_synchronize_on_with_different_session() {
  session="mysession"
  window="3"
  spy tmuxifier-tmux

  synchronize_on

  assert_have_been_called_with \
    tmuxifier-tmux "set-window-option -t mysession:3 synchronize-panes on"
}
