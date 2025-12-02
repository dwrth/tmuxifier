#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# split_hl() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_split_hl_calls_tmux_then_go_to_path() {
  local calls=()
  function tmuxifier-tmux() { calls+=("tmuxifier-tmux:$*"); }
  function __go_to_window_or_session_path() { calls+=("go_to_path"); }

  split_hl

  assert_equals "tmuxifier-tmux:split-window -t test-session:0. -h" "${calls[0]}"
  assert_equals "go_to_path" "${calls[1]}"
}

function test_split_hl_with_column_count_includes_l_flag() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_hl 80

  assert_have_been_called_with \
    tmuxifier-tmux "split-window -t test-session:0. -h -l 80"
}

function test_split_hl_with_column_count_and_target_pane() {
  session="mysession"
  window="2"
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_hl 40 1

  assert_have_been_called_with \
    tmuxifier-tmux "split-window -t mysession:2.1 -h -l 40"
}

function test_split_hl_with_only_target_pane_empty_count() {
  session="test"
  window="1"
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_hl "" 2

  assert_have_been_called_with tmuxifier-tmux "split-window -t test:1.2 -h"
}

function test_split_hl_always_calls_go_to_window_or_session_path() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_hl 60 1

  assert_have_been_called_times 1 __go_to_window_or_session_path
}
