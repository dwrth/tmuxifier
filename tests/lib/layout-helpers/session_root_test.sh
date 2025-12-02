#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# session_root() tests
#

function set_up() {
  # Create temp directories for testing (per-test for parallel support)
  _test_tmp_dir=$(mktemp -d)
  _test_valid_dir="${_test_tmp_dir}/valid"
  mkdir -p "$_test_valid_dir"
  _test_nonexistent_dir="${_test_tmp_dir}/nonexistent"

  # Reset session_root variable before each test
  session_root=""
}

function tear_down() {
  unset session_root
  rm -rf "$_test_tmp_dir"
}

function test_session_root_sets_variable_for_existing_directory() {
  # Mock __expand_path to return the valid directory
  mock __expand_path echo "$_test_valid_dir"

  session_root "~/some/path"

  assert_same "$_test_valid_dir" "$session_root"
}

function test_session_root_does_not_set_variable_for_nonexistent_directory() {
  # Mock __expand_path to return a nonexistent directory
  mock __expand_path echo "$_test_nonexistent_dir"

  session_root "~/nonexistent"

  assert_empty "$session_root"
}

function test_session_root_calls_expand_path_with_arguments() {
  spy __expand_path
  # Since spy doesn't return anything, the dir check will fail
  # but we can still verify __expand_path was called

  session_root "~/Projects"

  assert_have_been_called_with __expand_path "~/Projects"
}

function test_session_root_passes_multiple_arguments_to_expand_path() {
  spy __expand_path

  session_root '~/$USER/path'

  assert_have_been_called_with __expand_path '~/$USER/path'
}

function test_session_root_preserves_existing_value_on_invalid_path() {
  session_root="$_test_valid_dir"
  mock __expand_path echo "$_test_nonexistent_dir"

  session_root "~/invalid"

  # Original value should be preserved since new path doesn't exist
  assert_same "$_test_valid_dir" "$session_root"
}

function test_session_root_overwrites_existing_value_on_valid_path() {
  local new_dir="${_test_tmp_dir}/another"
  mkdir -p "$new_dir"
  session_root="$_test_valid_dir"
  mock __expand_path echo "$new_dir"

  session_root "~/another"

  assert_same "$new_dir" "$session_root"
}

function test_session_root_handles_home_directory() {
  # Use actual HOME which should exist
  mock __expand_path echo "$HOME"

  session_root "~"

  assert_same "$HOME" "$session_root"
}
