#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# load_window() tests
#

function set_up() {
  # Create temp directory structure for testing (per-test for parallel support)
  _test_tmp_dir=$(mktemp -d)
  _test_layout_path="${_test_tmp_dir}/layouts"
  mkdir -p "$_test_layout_path"

  # Create a simple window layout file in layout path
  cat > "${_test_layout_path}/mywindow.window.sh" << 'EOF'
_test_layout_sourced="mywindow"
EOF

  # Create layout file with .sh extension only
  cat > "${_test_layout_path}/other.sh" << 'EOF'
_test_layout_sourced="other"
EOF

  # Create a layout file as a direct path
  cat > "${_test_tmp_dir}/direct.window.sh" << 'EOF'
_test_layout_sourced="direct"
EOF

  # Create a layout that modifies window_root
  cat > "${_test_layout_path}/chroot.window.sh" << 'EOF'
_test_layout_sourced="chroot"
EOF

  # Save original TMUXIFIER_LAYOUT_PATH and set test value
  _orig_layout_path="$TMUXIFIER_LAYOUT_PATH"
  TMUXIFIER_LAYOUT_PATH="$_test_layout_path"

  # Reset variables
  window=""
  window_root=""
  session_root=""
  _test_layout_sourced=""
}

function tear_down() {
  TMUXIFIER_LAYOUT_PATH="$_orig_layout_path"
  unset window window_root session_root _test_layout_sourced
  rm -rf "$_test_tmp_dir"
}

function test_load_window_finds_layout_by_name_in_layout_path() {
  load_window "mywindow"

  assert_same "mywindow" "$_test_layout_sourced"
}

function test_load_window_finds_layout_by_direct_file_path() {
  load_window "${_test_tmp_dir}/direct.window.sh"

  assert_same "direct" "$_test_layout_sourced"
}

function test_load_window_sets_window_from_name_stripping_window_sh() {
  # We need to capture window value during source, before it's reset
  cat > "${_test_layout_path}/capture.window.sh" << 'EOF'
_captured_window="$window"
EOF

  load_window "capture"

  assert_same "capture" "$_captured_window"
}

function test_load_window_sets_window_from_name_stripping_sh_only() {
  cat > "${_test_layout_path}/simple.sh" << 'EOF'
_captured_window="$window"
EOF

  # Load by direct path to test .sh stripping
  load_window "${_test_layout_path}/simple.sh"

  assert_same "${_test_layout_path}/simple" "$_captured_window"
}

function test_load_window_uses_override_name_when_provided() {
  cat > "${_test_layout_path}/named.window.sh" << 'EOF'
_captured_window="$window"
EOF

  load_window "named" "custom-name"

  assert_same "custom-name" "$_captured_window"
}

function test_load_window_resets_window_variable_after_load() {
  load_window "mywindow"

  assert_empty "$window"
}

function test_load_window_resets_window_root_when_different_from_session_root() {
  session_root="$_test_tmp_dir"
  window_root="${_test_tmp_dir}/layouts"

  # Mock the window_root function to track if it's called
  _window_root_called=""
  _window_root_arg=""
  function window_root() {
    _window_root_called="yes"
    _window_root_arg="$1"
  }

  load_window "mywindow"

  assert_same "yes" "$_window_root_called"
  assert_same "$_test_tmp_dir" "$_window_root_arg"
}

function test_load_window_does_not_reset_window_root_when_equal_to_session_root() {
  session_root="$_test_tmp_dir"
  window_root="$_test_tmp_dir"

  _window_root_called=""
  function window_root() {
    _window_root_called="yes"
  }

  load_window "mywindow"

  assert_empty "$_window_root_called"
}

function test_load_window_returns_1_when_file_not_found() {
  load_window "nonexistent" 2> /dev/null
  local exit_code=$?

  assert_same "1" "$exit_code"
}

function test_load_window_prints_error_to_stderr_when_not_found() {
  local stderr_output
  stderr_output=$(load_window "nonexistent" 2>&1 > /dev/null)

  assert_contains "nonexistent" "$stderr_output"
  assert_contains "not found" "$stderr_output"
}

function test_load_window_sources_file_content() {
  cat > "${_test_layout_path}/content.window.sh" << 'EOF'
_test_var_one="value1"
_test_var_two="value2"
EOF

  load_window "content"

  assert_same "value1" "$_test_var_one"
  assert_same "value2" "$_test_var_two"
}

function test_load_window_prefers_direct_file_over_layout_path() {
  # Create a file that would match both direct path and layout path lookup
  cat > "${_test_layout_path}/conflict.window.sh" << 'EOF'
_test_layout_sourced="from_layout_path"
EOF
  cat > "${_test_tmp_dir}/conflict.window.sh" << 'EOF'
_test_layout_sourced="from_direct_path"
EOF

  # When given as direct path, should use direct file
  load_window "${_test_tmp_dir}/conflict.window.sh"

  assert_same "from_direct_path" "$_test_layout_sourced"
}
