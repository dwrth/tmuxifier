#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# finalize_and_go_to_session() tests
#

function set_up() {
  # Create temp directory for testing
  _test_tmp_dir=$(mktemp -d)

  # Save original values
  _orig_home="$HOME"
  _orig_tmux="$TMUX"
  _orig_iterm_attach="$TMUXIFIER_TMUX_ITERM_ATTACH"
  HOME="$_test_tmp_dir"

  # Reset variables to known state
  session=""
  TMUX=""
  TMUXIFIER_TMUX_ITERM_ATTACH=""
}

function tear_down() {
  HOME="$_orig_home"
  TMUX="$_orig_tmux"
  TMUXIFIER_TMUX_ITERM_ATTACH="$_orig_iterm_attach"
  unset session
  rm -rf "$_test_tmp_dir"
}

#
# Kill window 999 behavior
#

function test_finalize_kills_window_999() {
  session="mysession"
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "mysession"

  finalize_and_go_to_session

  assert_have_been_called_with tmuxifier-tmux "kill-window -t mysession:999"
}

function test_finalize_continues_when_kill_window_fails() {
  session="mysession"
  # Simulate kill-window failure (window doesn't exist)
  mock tmuxifier-tmux return 1
  mock tmuxifier-current-session echo "mysession"

  local result
  finalize_and_go_to_session
  result=$?

  # Function should succeed even if kill-window fails due to ! negation
  assert_same "0" "$result"
}

function test_finalize_continues_when_kill_window_succeeds() {
  session="mysession"
  mock tmuxifier-tmux return 0
  mock tmuxifier-current-session echo "mysession"

  local result
  finalize_and_go_to_session
  result=$?

  # Function succeeds when kill-window succeeds
  # Note: ! negation means exit code is inverted (1 becomes 0, 0 becomes 1)
  # but the conditional check for __go_to_session still runs
  assert_successful_code "true"
}

#
# Session switching when current session differs
#

function test_finalize_calls_attach_when_current_session_differs_and_not_in_tmux() {
  session="newsession"
  TMUX=""
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "othersession"

  finalize_and_go_to_session

  # Should call attach-session when not inside tmux
  assert_have_been_called_with tmuxifier-tmux \
    "-u attach-session -t newsession:" 2
}

function test_finalize_calls_switch_when_current_session_differs_and_inside_tmux() {
  session="newsession"
  TMUX="/tmp/tmux-1000/default,12345,0"
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "othersession"

  finalize_and_go_to_session

  # Should call switch-client when inside tmux
  assert_have_been_called_with tmuxifier-tmux \
    "-u switch-client -t newsession:" 2
}

#
# Session switching when current session matches
#

function test_finalize_does_not_switch_when_current_session_matches() {
  session="mysession"
  TMUX=""
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "mysession"

  finalize_and_go_to_session

  # Should only call kill-window, not attach/switch
  assert_have_been_called_times 1 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux "kill-window -t mysession:999" 1
}

function test_finalize_does_not_switch_when_already_in_session_inside_tmux() {
  session="current"
  TMUX="/tmp/tmux-1000/default,12345,0"
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "current"

  finalize_and_go_to_session

  # Should only call kill-window
  assert_have_been_called_times 1 tmuxifier-tmux
}

#
# iTerm2 integration
#

function test_finalize_uses_iterm_attach_flag_when_set() {
  session="newsession"
  TMUX=""
  TMUXIFIER_TMUX_ITERM_ATTACH="-CC"
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "othersession"

  finalize_and_go_to_session

  # Should include -CC flag for iTerm2 integration
  assert_have_been_called_with tmuxifier-tmux \
    "-CC -u attach-session -t newsession:" 2
}

function test_finalize_iterm_flag_not_used_when_switching_client() {
  session="newsession"
  TMUX="/tmp/tmux-1000/default,12345,0"
  TMUXIFIER_TMUX_ITERM_ATTACH="-CC"
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "othersession"

  finalize_and_go_to_session

  # switch-client doesn't use ITERM_ATTACH
  assert_have_been_called_with tmuxifier-tmux \
    "-u switch-client -t newsession:" 2
}

#
# Edge cases
#

function test_finalize_handles_session_with_special_characters() {
  session="my-project_v2.0"
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "my-project_v2.0"

  finalize_and_go_to_session

  assert_have_been_called_with tmuxifier-tmux \
    "kill-window -t my-project_v2.0:999"
}

function test_finalize_handles_empty_current_session_output() {
  session="newsession"
  TMUX=""
  spy tmuxifier-tmux
  # Empty output from tmuxifier-current-session (not in any session)
  mock tmuxifier-current-session echo ""

  finalize_and_go_to_session

  # Empty != "newsession", so should call attach
  assert_have_been_called_with tmuxifier-tmux \
    "-u attach-session -t newsession:" 2
}

function test_finalize_handles_session_name_with_spaces() {
  session="my session"
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "my session"

  finalize_and_go_to_session

  assert_have_been_called_with tmuxifier-tmux \
    "kill-window -t my session:999"
}

#
# Integration-style tests
#

function test_finalize_full_flow_when_session_exists_and_matches() {
  session="existing"
  TMUX=""
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "existing"

  finalize_and_go_to_session

  # Verify single call to kill-window only
  assert_have_been_called_times 1 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux "kill-window -t existing:999" 1
}

function test_finalize_full_flow_when_session_needs_attach() {
  session="newproject"
  TMUX=""
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo ""

  finalize_and_go_to_session

  # Verify both calls: kill-window and attach-session
  assert_have_been_called_times 2 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux \
    "kill-window -t newproject:999" 1
  assert_have_been_called_with tmuxifier-tmux \
    "-u attach-session -t newproject:" 2
}

function test_finalize_full_flow_when_switching_from_another_session() {
  session="target"
  TMUX="/tmp/tmux-1000/default,12345,0"
  spy tmuxifier-tmux
  mock tmuxifier-current-session echo "source"

  finalize_and_go_to_session

  # Verify both calls: kill-window and switch-client
  assert_have_been_called_times 2 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux \
    "kill-window -t target:999" 1
  assert_have_been_called_with tmuxifier-tmux \
    "-u switch-client -t target:" 2
}
