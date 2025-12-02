#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# initialize_session() tests
#

function set_up() {
  # Create temp directory for testing
  _test_tmp_dir=$(mktemp -d)

  # Save original values
  _orig_home="$HOME"
  HOME="$_test_tmp_dir"

  # Reset variables to known state
  session=""
  session_root="$HOME"
  set_default_path=true
  window=""
  TMUX=""
}

function tear_down() {
  HOME="$_orig_home"
  unset session session_root set_default_path window
  rm -rf "$_test_tmp_dir"
}

#
# Session name handling
#

function test_initialize_session_uses_session_variable_when_no_argument() {
  session="my-session"
  mock tmuxifier-tmux echo ""
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  assert_same "my-session" "$session"
}

function test_initialize_session_uses_argument_as_session_name() {
  session=""
  mock tmuxifier-tmux echo ""
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session "custom-session"

  assert_same "custom-session" "$session"
}

function test_initialize_session_overrides_session_variable_with_argument() {
  session="original"
  mock tmuxifier-tmux echo ""
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session "override"

  assert_same "override" "$session"
}

#
# Server startup
#

function test_initialize_session_starts_tmux_server() {
  session="test"
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  assert_have_been_called_with tmuxifier-tmux "start-server" 1
}

#
# Session existence check
#

function test_initialize_session_returns_1_when_session_exists() {
  session="existing"
  # Mock list-sessions to return a matching session (output is also used by
  # start-server but ignored there)
  mock tmuxifier-tmux printf '%s\n' "existing: 1 windows"
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  local result
  initialize_session
  result=$?

  assert_same "1" "$result"
}

function test_initialize_session_returns_0_when_session_does_not_exist() {
  session="newsession"
  mock tmuxifier-tmux echo ""
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  local result
  initialize_session
  result=$?

  assert_same "0" "$result"
}

function test_initialize_session_checks_exact_session_name_match() {
  session="test"
  # Return a session with similar but different name - grep pattern "^test:"
  # won't match "test-other:"
  mock tmuxifier-tmux printf '%s\n' "test-other: 1 windows"
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  local result
  initialize_session
  result=$?

  # Should succeed because "test:" pattern doesn't match "test-other:"
  assert_same "0" "$result"
}

#
# Tmux 1.9+ behavior (modern tmux)
#

function test_initialize_session_creates_session_with_c_flag_for_tmux_19_plus() {
  session="newsession"
  session_root="$_test_tmp_dir"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  # Calls: start-server(1), list-sessions(2), new-session(3), setenv(4),
  # move-window(5)
  assert_have_been_called_with tmuxifier-tmux \
    "new-session -d -s newsession -c $_test_tmp_dir" 3
}

function test_initialize_session_omits_c_flag_when_set_default_path_false() {
  session="newsession"
  session_root="$_test_tmp_dir"
  set_default_path=false
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  # Calls: start-server(1), list-sessions(2), new-session(3), move-window(4)
  assert_have_been_called_with tmuxifier-tmux \
    "new-session -d -s newsession" 3
}

#
# Tmux 1.8 and earlier behavior (legacy tmux)
#

function test_initialize_session_creates_session_without_c_for_tmux_18() {
  session="newsession"
  session_root="$_test_tmp_dir"
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< "<"
  mock __get_first_window_index echo "0"

  initialize_session

  # Calls: start-server(1), list-sessions(2), new-session(3), ...
  assert_have_been_called_with tmuxifier-tmux \
    "new-session -d -s newsession" 3
}

function test_initialize_session_sets_default_path_option_for_tmux_18() {
  session="newsession"
  session_root="$_test_tmp_dir"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< "<"
  mock __get_first_window_index echo "0"

  initialize_session

  # Calls: start-server(1), list-sessions(2), new-session(3), set-option(4),
  # setenv(5), move-window(6)
  assert_have_been_called_with tmuxifier-tmux \
    "set-option -t newsession: default-path $_test_tmp_dir" 4
}

function test_initialize_session_skips_default_path_when_set_default_path_false() {
  session="newsession"
  session_root="$_test_tmp_dir"
  set_default_path=false
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< "<"
  mock __get_first_window_index echo "0"

  initialize_session

  # Should have 4 calls: start-server, list-sessions, new-session, move-window
  # (no set-option default-path call, no setenv call)
  assert_have_been_called_times 4 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux "start-server" 1
  assert_have_been_called_with tmuxifier-tmux "list-sessions" 2
  assert_have_been_called_with tmuxifier-tmux "new-session -d -s newsession" 3
  assert_have_been_called_with tmuxifier-tmux \
    "move-window -s newsession:0 -t newsession:999" 4
}

#
# Session root environment variable
#

function test_initialize_session_sets_session_root_env_when_not_home() {
  session="newsession"
  # Use a subdirectory so session_root != HOME
  mkdir -p "$_test_tmp_dir/project"
  session_root="$_test_tmp_dir/project"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  # Calls: start-server(1), list-sessions(2), new-session(3), setenv(4),
  # move-window(5)
  assert_have_been_called_with tmuxifier-tmux \
    "setenv -t newsession: TMUXIFIER_SESSION_ROOT $_test_tmp_dir/project" 4
}

function test_initialize_session_skips_session_root_env_when_equal_to_home() {
  session="newsession"
  session_root="$HOME"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  # Should have 4 calls (no setenv call when session_root == HOME)
  assert_have_been_called_times 4 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux "start-server" 1
  assert_have_been_called_with tmuxifier-tmux "list-sessions" 2
  assert_have_been_called_with tmuxifier-tmux \
    "new-session -d -s newsession -c $HOME" 3
  assert_have_been_called_with tmuxifier-tmux \
    "move-window -s newsession:0 -t newsession:999" 4
}

function test_initialize_session_skips_session_root_env_when_set_default_path_false() {
  session="newsession"
  session_root="$_test_tmp_dir"
  set_default_path=false
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  # Should have 4 calls (no setenv call when set_default_path is false)
  assert_have_been_called_times 4 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux "start-server" 1
  assert_have_been_called_with tmuxifier-tmux "list-sessions" 2
  assert_have_been_called_with tmuxifier-tmux "new-session -d -s newsession" 3
  assert_have_been_called_with tmuxifier-tmux \
    "move-window -s newsession:0 -t newsession:999" 4
}

#
# Default window handling
#

function test_initialize_session_moves_default_window_to_position_999() {
  session="newsession"
  session_root="$HOME"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  assert_have_been_called_with tmuxifier-tmux \
    "move-window -s newsession:0 -t newsession:999"
}

function test_initialize_session_uses_first_window_index_for_move() {
  session="newsession"
  session_root="$HOME"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "1"

  initialize_session

  # Should use the actual first window index (1 in this case)
  assert_have_been_called_with tmuxifier-tmux \
    "move-window -s newsession:1 -t newsession:999"
}

#
# Integration-style tests
#

function test_initialize_session_full_flow_tmux_19_returns_success() {
  session="myproject"
  mkdir -p "$_test_tmp_dir/project"
  session_root="$_test_tmp_dir/project"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  local result
  initialize_session
  result=$?

  assert_same "0" "$result"
  assert_same "myproject" "$session"
}

function test_initialize_session_full_flow_tmux_19_calls_expected_commands() {
  session="myproject"
  mkdir -p "$_test_tmp_dir/project"
  session_root="$_test_tmp_dir/project"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  initialize_session

  # Verify all expected calls
  assert_have_been_called_times 5 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux "start-server" 1
  assert_have_been_called_with tmuxifier-tmux "list-sessions" 2
  assert_have_been_called_with tmuxifier-tmux \
    "new-session -d -s myproject -c $_test_tmp_dir/project" 3
  assert_have_been_called_with tmuxifier-tmux \
    "setenv -t myproject: TMUXIFIER_SESSION_ROOT $_test_tmp_dir/project" 4
  assert_have_been_called_with tmuxifier-tmux \
    "move-window -s myproject:0 -t myproject:999" 5
}

function test_initialize_session_full_flow_tmux_18_returns_success() {
  session="oldproject"
  mkdir -p "$_test_tmp_dir/project"
  session_root="$_test_tmp_dir/project"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< "<"
  mock __get_first_window_index echo "0"

  local result
  initialize_session
  result=$?

  assert_same "0" "$result"
  assert_same "oldproject" "$session"
}

function test_initialize_session_full_flow_tmux_18_calls_expected_commands() {
  session="oldproject"
  mkdir -p "$_test_tmp_dir/project"
  session_root="$_test_tmp_dir/project"
  set_default_path=true
  spy tmuxifier-tmux
  mock tmuxifier-tmux-version <<< "<"
  mock __get_first_window_index echo "0"

  initialize_session

  # Verify all expected calls
  assert_have_been_called_times 6 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux "start-server" 1
  assert_have_been_called_with tmuxifier-tmux "list-sessions" 2
  assert_have_been_called_with tmuxifier-tmux \
    "new-session -d -s oldproject" 3
  assert_have_been_called_with tmuxifier-tmux \
    "set-option -t oldproject: default-path $_test_tmp_dir/project" 4
  assert_have_been_called_with tmuxifier-tmux \
    "setenv -t oldproject: TMUXIFIER_SESSION_ROOT $_test_tmp_dir/project" 5
  assert_have_been_called_with tmuxifier-tmux \
    "move-window -s oldproject:0 -t oldproject:999" 6
}

#
# Edge cases
#

function test_initialize_session_does_not_create_when_session_already_exists() {
  session="existing"
  mock tmuxifier-tmux printf '%s\n' "existing: 1 windows"
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  local result
  initialize_session
  result=$?

  assert_same "1" "$result"
}

function test_initialize_session_handles_session_with_special_chars() {
  session="my-project_v2"
  mock tmuxifier-tmux echo ""
  mock tmuxifier-tmux-version <<< ">"
  mock __get_first_window_index echo "0"

  local result
  initialize_session
  result=$?

  assert_same "0" "$result"
  assert_same "my-project_v2" "$session"
}
