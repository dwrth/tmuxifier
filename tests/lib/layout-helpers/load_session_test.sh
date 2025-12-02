#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# load_session() tests
#

function set_up() {
  # Create temp directory structure for testing (per-test for parallel support)
  _test_tmp_dir=$(mktemp -d)
  _test_layout_path="${_test_tmp_dir}/layouts"
  mkdir -p "$_test_layout_path"

  # Create a simple session layout file in layout path
  cat > "${_test_layout_path}/mysession.session.sh" << 'EOF'
_test_layout_sourced="mysession"
EOF

  # Create layout file with .sh extension only
  cat > "${_test_layout_path}/other.sh" << 'EOF'
_test_layout_sourced="other"
EOF

  # Create a layout file as a direct path (with slash)
  cat > "${_test_tmp_dir}/direct.session.sh" << 'EOF'
_test_layout_sourced="direct"
EOF

  # Save original values and set test values
  _orig_layout_path="$TMUXIFIER_LAYOUT_PATH"
  _orig_home="$HOME"
  TMUXIFIER_LAYOUT_PATH="$_test_layout_path"

  # Reset variables
  session=""
  session_root=""
  set_default_path=""
  _test_layout_sourced=""
}

function tear_down() {
  TMUXIFIER_LAYOUT_PATH="$_orig_layout_path"
  HOME="$_orig_home"
  unset session session_root set_default_path _test_layout_sourced
  rm -rf "$_test_tmp_dir"
}

function test_load_session_finds_layout_by_name_in_layout_path() {
  load_session "mysession"

  assert_same "mysession" "$_test_layout_sourced"
}

function test_load_session_finds_layout_by_direct_file_path() {
  load_session "${_test_tmp_dir}/direct.session.sh"

  assert_same "direct" "$_test_layout_sourced"
}

function test_load_session_sets_session_from_name_stripping_session_sh() {
  # Capture session value during source, before it's reset
  cat > "${_test_layout_path}/capture.session.sh" << 'EOF'
_captured_session="$session"
EOF

  load_session "capture"

  assert_same "capture" "$_captured_session"
}

function test_load_session_sets_session_from_path_stripping_session_sh() {
  cat > "${_test_tmp_dir}/pathtest.session.sh" << 'EOF'
_captured_session="$session"
EOF

  load_session "${_test_tmp_dir}/pathtest.session.sh"

  assert_same "${_test_tmp_dir}/pathtest" "$_captured_session"
}

function test_load_session_uses_override_name_when_provided() {
  cat > "${_test_layout_path}/named.session.sh" << 'EOF'
_captured_session="$session"
EOF

  load_session "named" "custom-session"

  assert_same "custom-session" "$_captured_session"
}

function test_load_session_resets_session_variable_after_load() {
  load_session "mysession"

  assert_empty "$session"
}

function test_load_session_sets_set_default_path_to_true() {
  cat > "${_test_layout_path}/checkpath.session.sh" << 'EOF'
_captured_set_default_path="$set_default_path"
EOF

  load_session "checkpath"

  assert_same "true" "$_captured_set_default_path"
}

function test_load_session_resets_session_root_to_home_when_different() {
  HOME="$_test_tmp_dir"
  session_root="${_test_tmp_dir}/layouts"

  load_session "mysession"

  assert_same "$_test_tmp_dir" "$session_root"
}

function test_load_session_does_not_reset_session_root_when_equal_to_home() {
  HOME="$_test_tmp_dir"
  session_root="$_test_tmp_dir"

  # Create a layout that changes session_root
  cat > "${_test_layout_path}/nochange.session.sh" << 'EOF'
# This layout doesn't change session_root
EOF

  load_session "nochange"

  # session_root should still be the same (HOME)
  assert_same "$_test_tmp_dir" "$session_root"
}

function test_load_session_returns_1_when_file_not_found() {
  load_session "nonexistent" 2> /dev/null
  local exit_code=$?

  assert_same "1" "$exit_code"
}

function test_load_session_prints_error_to_stderr_when_not_found() {
  local stderr_output
  stderr_output=$(load_session "nonexistent" 2>&1 > /dev/null)

  assert_contains "nonexistent" "$stderr_output"
  assert_contains "not found" "$stderr_output"
}

function test_load_session_sources_file_content() {
  cat > "${_test_layout_path}/content.session.sh" << 'EOF'
_test_var_one="session_value1"
_test_var_two="session_value2"
EOF

  load_session "content"

  assert_same "session_value1" "$_test_var_one"
  assert_same "session_value2" "$_test_var_two"
}

function test_load_session_prefers_layout_path_when_no_slash_in_name() {
  # Create a file in layout path
  cat > "${_test_layout_path}/conflict.session.sh" << 'EOF'
_test_layout_sourced="from_layout_path"
EOF

  # When given name without slash, should use layout path
  load_session "conflict"

  assert_same "from_layout_path" "$_test_layout_sourced"
}

function test_load_session_uses_direct_path_when_slash_present() {
  mkdir -p "${_test_layout_path}/sub"
  cat > "${_test_layout_path}/sub/nested.session.sh" << 'EOF'
_test_layout_sourced="from_nested"
EOF

  # When given path with slash, should use it directly
  load_session "${_test_layout_path}/sub/nested.session.sh"

  assert_same "from_nested" "$_test_layout_sourced"
}

function test_load_session_handles_relative_path_in_current_dir() {
  # Save current directory and change to temp dir
  local orig_pwd="$PWD"
  cd "$_test_tmp_dir"

  # Create a file without .session.sh suffix in current dir
  cat > "localfile.sh" << 'EOF'
_test_layout_sourced="from_local"
EOF

  # When file exists locally and no slash, it should prepend ./
  load_session "localfile.sh"

  assert_same "from_local" "$_test_layout_sourced"

  cd "$orig_pwd"
}
