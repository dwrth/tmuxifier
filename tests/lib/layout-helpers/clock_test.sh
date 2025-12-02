#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# clock() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_clock_calls_tmux_clock_mode() {
  spy tmuxifier-tmux

  clock

  assert_have_been_called_with tmuxifier-tmux "clock-mode -t test-session:0."
}

function test_clock_with_target_pane() {
  spy tmuxifier-tmux

  clock 1

  assert_have_been_called_with tmuxifier-tmux "clock-mode -t test-session:0.1"
}

function test_clock_with_different_session_and_window() {
  session="mysession"
  window="2"
  spy tmuxifier-tmux

  clock 3

  assert_have_been_called_with tmuxifier-tmux "clock-mode -t mysession:2.3"
}

function test_clock_with_named_window() {
  session="dev"
  window="editor"
  spy tmuxifier-tmux

  clock 0

  assert_have_been_called_with tmuxifier-tmux "clock-mode -t dev:editor.0"
}
