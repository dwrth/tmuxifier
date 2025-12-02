#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# send_keys() tests
#

function set_up() {
  # Default session and window for tests
  session="test-session"
  window="0"
}

function tear_down() {
  unset session window
}

function test_send_keys_sends_string_to_current_pane() {
  spy tmuxifier-tmux

  send_keys "hello"

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0. hello"
}

function test_send_keys_with_target_pane() {
  spy tmuxifier-tmux

  send_keys "hello" 1

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0.1 hello"
}

function test_send_keys_with_special_key() {
  spy tmuxifier-tmux

  send_keys "C-m"

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0. C-m"
}

function test_send_keys_with_command_string() {
  spy tmuxifier-tmux

  send_keys "ls -la"

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t test-session:0. ls -la"
}

function test_send_keys_with_different_session_and_window() {
  session="mysession"
  window="2"
  spy tmuxifier-tmux

  send_keys "echo test" 3

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t mysession:2.3 echo test"
}

function test_send_keys_with_named_window() {
  session="dev"
  window="editor"
  spy tmuxifier-tmux

  send_keys "vim ." 0

  assert_have_been_called_with \
    tmuxifier-tmux "send-keys -t dev:editor.0 vim ."
}
