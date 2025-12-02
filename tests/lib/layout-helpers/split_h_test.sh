#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# split_h() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_split_h_calls_tmux_then_go_to_path() {
  local calls=()
  function tmuxifier-tmux() { calls+=("tmuxifier-tmux:$*"); }
  function __go_to_window_or_session_path() { calls+=("go_to_path"); }

  split_h

  assert_equals "tmuxifier-tmux:split-window -t test-session:0. -h" "${calls[0]}"
  assert_equals "go_to_path" "${calls[1]}"
}

#
# Tmux 3.1+ tests (uses -l with % suffix)
#

function test_split_h_tmux_31_with_percentage_uses_l_flag() {
  mock tmuxifier-tmux-version <<< ">"
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_h 30

  assert_have_been_called_with \
    tmuxifier-tmux "split-window -t test-session:0. -h -l 30%"
}

function test_split_h_tmux_31_with_percentage_and_target_pane() {
  session="mysession"
  window="2"
  mock tmuxifier-tmux-version <<< ">"
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_h 50 1

  assert_have_been_called_with \
    tmuxifier-tmux "split-window -t mysession:2.1 -h -l 50%"
}

function test_split_h_tmux_31_with_only_target_pane_empty_percentage() {
  session="test"
  window="1"
  mock tmuxifier-tmux-version <<< ">"
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_h "" 2

  assert_have_been_called_with tmuxifier-tmux "split-window -t test:1.2 -h"
}

#
# Tmux 3.0 and earlier tests (uses -p flag)
#

function test_split_h_tmux_30_with_percentage_uses_p_flag() {
  mock tmuxifier-tmux-version <<< "="
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_h 30

  assert_have_been_called_with \
    tmuxifier-tmux "split-window -t test-session:0. -h -p 30"
}

function test_split_h_tmux_30_with_percentage_and_target_pane() {
  session="mysession"
  window="2"
  mock tmuxifier-tmux-version <<< "<"
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_h 50 1

  assert_have_been_called_with \
    tmuxifier-tmux "split-window -t mysession:2.1 -h -p 50"
}

function test_split_h_tmux_30_with_only_target_pane_empty_percentage() {
  session="test"
  window="1"
  mock tmuxifier-tmux-version <<< "="
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_h "" 2

  assert_have_been_called_with tmuxifier-tmux "split-window -t test:1.2 -h"
}

function test_split_h_always_calls_go_to_window_or_session_path() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path

  split_h 50 1

  assert_have_been_called_times 1 __go_to_window_or_session_path
}
