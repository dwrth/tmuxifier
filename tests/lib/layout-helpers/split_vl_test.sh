#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# split_vl() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_split_vl_calls_tmux_then_go_to_path() {
  local calls=()
  function tmuxifier-tmux() { calls+=("tmuxifier-tmux:$*"); }
  function __go_to_window_or_session_path() { calls+=("go_to_path"); }

  split_vl

  assert_equals "tmuxifier-tmux:split-window -t test-session:0. -v" "${calls[0]}"
  assert_equals "go_to_path" "${calls[1]}"
}

function test_split_vl_with_line_count_includes_l_flag() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_vl 20

  assert_have_been_called_with \
    tmuxifier-tmux "split-window -t test-session:0. -v -l 20"
}

function test_split_vl_with_line_count_and_target_pane() {
  session="mysession"
  window="2"
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_vl 15 1

  assert_have_been_called_with \
    tmuxifier-tmux "split-window -t mysession:2.1 -v -l 15"
}

function test_split_vl_with_only_target_pane_empty_count() {
  session="test"
  window="1"
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_vl "" 2

  assert_have_been_called_with tmuxifier-tmux "split-window -t test:1.2 -v"
}

function test_split_vl_always_calls_go_to_window_or_session_path() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_vl 10 1

  assert_have_been_called_times 1 __go_to_window_or_session_path
}
