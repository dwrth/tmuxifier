#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# select_pane() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_select_pane_calls_tmux_select_pane() {
  spy tmuxifier-tmux

  select_pane 1

  assert_have_been_called_with \
    tmuxifier-tmux "select-pane -t test-session:0.1"
}

function test_select_pane_with_pane_zero() {
  spy tmuxifier-tmux

  select_pane 0

  assert_have_been_called_with \
    tmuxifier-tmux "select-pane -t test-session:0.0"
}

function test_select_pane_with_different_session_and_window() {
  session="mysession"
  window="2"
  spy tmuxifier-tmux

  select_pane 3

  assert_have_been_called_with tmuxifier-tmux "select-pane -t mysession:2.3"
}

function test_select_pane_with_named_window() {
  session="dev"
  window="editor"
  spy tmuxifier-tmux

  select_pane 1

  assert_have_been_called_with tmuxifier-tmux "select-pane -t dev:editor.1"
}
