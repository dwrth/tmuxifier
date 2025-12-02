#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# __go_to_window_or_session_path() tests
#

function set_up() {
  # Reset all path-related variables before each test
  window_root=""
  session_root=""
  TMUXIFIER_SESSION_ROOT=""

  # Default session and window for run_cmd context
  session="test-session"
  window="0"
}

function tear_down() {
  unset window_root session_root TMUXIFIER_SESSION_ROOT
  unset session window
}

#
# No path set
#

function test_does_nothing_when_no_paths_set() {
  spy run_cmd

  __go_to_window_or_session_path

  assert_not_called run_cmd
}

function test_does_nothing_with_empty_string_paths() {
  window_root=""
  session_root=""
  TMUXIFIER_SESSION_ROOT=""
  spy run_cmd

  __go_to_window_or_session_path

  assert_not_called run_cmd
}

#
# Single path set
#

function test_uses_session_root_when_only_session_root_is_set() {
  session_root="/path/to/session"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_times 2 run_cmd
  assert_have_been_called_with run_cmd ' cd "/path/to/session"' 1
  assert_have_been_called_with run_cmd ' clear' 2
}

function test_uses_tmuxifier_session_root_when_only_env_var_is_set() {
  TMUXIFIER_SESSION_ROOT="/path/from/env"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_times 2 run_cmd
  assert_have_been_called_with run_cmd ' cd "/path/from/env"' 1
  assert_have_been_called_with run_cmd ' clear' 2
}

function test_uses_window_root_when_only_window_root_is_set() {
  window_root="/path/to/window"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_times 2 run_cmd
  assert_have_been_called_with run_cmd ' cd "/path/to/window"' 1
  assert_have_been_called_with run_cmd ' clear' 2
}

#
# Priority: window_root > TMUXIFIER_SESSION_ROOT > session_root
#

function test_window_root_takes_priority_over_session_root() {
  window_root="/window/path"
  session_root="/session/path"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_with run_cmd ' cd "/window/path"' 1
}

function test_tmuxifier_session_root_takes_priority_over_session_root() {
  TMUXIFIER_SESSION_ROOT="/env/path"
  session_root="/session/path"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_with run_cmd ' cd "/env/path"' 1
}

function test_window_root_takes_priority_over_tmuxifier_session_root() {
  window_root="/window/path"
  TMUXIFIER_SESSION_ROOT="/env/path"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_with run_cmd ' cd "/window/path"' 1
}

function test_window_root_takes_priority_over_all_other_paths() {
  window_root="/window/path"
  TMUXIFIER_SESSION_ROOT="/env/path"
  session_root="/session/path"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_with run_cmd ' cd "/window/path"' 1
}

#
# Command format
#

function test_cd_command_has_leading_space_for_history_suppression() {
  session_root="/some/path"
  spy run_cmd

  __go_to_window_or_session_path

  # Leading space prevents command from being saved in shell history
  assert_have_been_called_with run_cmd ' cd "/some/path"' 1
}

function test_clear_command_has_leading_space_for_history_suppression() {
  session_root="/some/path"
  spy run_cmd

  __go_to_window_or_session_path

  # Leading space prevents command from being saved in shell history
  assert_have_been_called_with run_cmd ' clear' 2
}

function test_path_is_quoted_in_cd_command() {
  session_root="/path/with spaces/in it"
  spy run_cmd

  __go_to_window_or_session_path

  # Path should be quoted to handle spaces
  assert_have_been_called_with run_cmd ' cd "/path/with spaces/in it"' 1
}

#
# Edge cases
#

function test_handles_path_with_special_characters() {
  session_root="/path/with\$pecial-chars_123"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_with run_cmd ' cd "/path/with$pecial-chars_123"' 1
}

function test_handles_home_directory_path() {
  session_root="$HOME"
  spy run_cmd

  __go_to_window_or_session_path

  assert_have_been_called_with run_cmd " cd \"$HOME\"" 1
}

function test_always_calls_clear_after_cd() {
  window_root="/any/path"
  spy run_cmd

  __go_to_window_or_session_path

  # Verify order: cd first, then clear
  assert_have_been_called_times 2 run_cmd
  assert_have_been_called_with run_cmd ' cd "/any/path"' 1
  assert_have_been_called_with run_cmd ' clear' 2
}
