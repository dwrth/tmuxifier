#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# run_cmd() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_run_cmd_sends_command_then_enter() {
  spy tmuxifier-tmux

  run_cmd "ls -la"

  assert_have_been_called_times 2 tmuxifier-tmux
}

function test_run_cmd_first_call_sends_command() {
  spy tmuxifier-tmux

  run_cmd "ls -la"

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0. ls -la" 1
}

function test_run_cmd_second_call_sends_enter_key() {
  spy tmuxifier-tmux

  run_cmd "ls -la"

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0. C-m" 2
}

function test_run_cmd_with_target_pane() {
  spy tmuxifier-tmux

  run_cmd "echo hello" 1

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0.1 echo hello" 1
  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0.1 C-m" 2
}

function test_run_cmd_with_different_session_and_window() {
  session="mysession"
  window="2"
  spy tmuxifier-tmux

  run_cmd "npm start" 3

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t mysession:2.3 npm start" 1
  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t mysession:2.3 C-m" 2
}

function test_run_cmd_with_complex_command() {
  spy tmuxifier-tmux

  run_cmd "cd /tmp && ls"

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0. cd /tmp && ls" 1
  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0. C-m" 2
}
