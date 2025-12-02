#!/usr/bin/env bash

# Load the util.sh library under test
source "${_root_dir}/lib/util.sh"

#
# calling-complete() tests
#

function test_calling-complete_returns_0_with_complete_flag() {
  calling-complete --complete
  assert_exit_code "0"
}

function test_calling-complete_returns_0_with_complete_flag_after_arg() {
  calling-complete foo --complete
  assert_exit_code "0"
}

function test_calling-complete_returns_0_with_complete_flag_before_arg() {
  calling-complete --complete bar
  assert_exit_code "0"
}

function test_calling-complete_returns_0_with_complete_flag_between_args() {
  calling-complete foo --complete bar
  assert_exit_code "0"
}

function test_calling-complete_returns_1_with_no_args() {
  calling-complete
  assert_exit_code "1"
}

function test_calling-complete_returns_1_with_unrelated_arg() {
  calling-complete foo
  assert_exit_code "1"
}

function test_calling-complete_returns_1_with_multiple_unrelated_args() {
  calling-complete foo bar
  assert_exit_code "1"
}

function test_calling-complete_returns_1_when_complete_is_not_freestanding() {
  calling-complete --complete-me
  assert_exit_code "1"
}

function test_calling-complete_returns_1_when_complete_is_suffix() {
  calling-complete foo--complete
  assert_exit_code "1"
}
