#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# new_window() tests
#

function set_up() {
  session="test-session"
  window=""
}

function tear_down() {
  unset session window
}

function test_new_window_calls_tmux_new_window() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path
  mock __get_current_window_index echo "1"

  new_window

  assert_have_been_called_with tmuxifier-tmux "new-window -t test-session:"
}

function test_new_window_calls_go_to_window_or_session_path() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path
  mock __get_current_window_index echo "1"

  new_window

  assert_have_been_called __go_to_window_or_session_path
}

function test_new_window_sets_window_variable_to_current_index() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path
  mock __get_current_window_index echo "5"

  new_window

  assert_same "5" "$window"
}

function test_new_window_with_name_includes_n_flag() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path
  mock __get_current_window_index echo "1"

  new_window "mywindow"

  assert_have_been_called_with tmuxifier-tmux "new-window -t test-session: -n mywindow" 1
}

function test_new_window_with_name_disables_allow_rename() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path
  mock __get_current_window_index echo "1"

  new_window "mywindow"

  assert_have_been_called_with tmuxifier-tmux "set-option -t mywindow allow-rename off" 2
}

function test_new_window_with_name_and_command() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path
  mock __get_current_window_index echo "1"

  new_window "editor" "vim"

  assert_have_been_called_with \
    tmuxifier-tmux "new-window -t test-session: -n editor vim" 1
}

function test_new_window_with_only_command_via_empty_name() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path
  mock __get_current_window_index echo "1"

  new_window "" "htop"

  assert_have_been_called_with tmuxifier-tmux "new-window -t test-session: htop"
}

function test_new_window_without_name_does_not_disable_rename() {
  spy tmuxifier-tmux
  spy __go_to_window_or_session_path
  mock __get_current_window_index echo "1"

  new_window

  # Only one call to tmuxifier-tmux (new-window), no set-option call
  assert_have_been_called_times 1 tmuxifier-tmux
}
