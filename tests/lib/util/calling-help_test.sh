#!/usr/bin/env bash

# Load the util.sh library under test
source "${_root_dir}/lib/util.sh"

#
# calling-help() tests
#

function test_calling-help_returns_0_with_help_flag() {
  calling-help --help
  assert_exit_code "0"
}

function test_calling-help_returns_0_with_help_flag_after_arg() {
  calling-help foo --help
  assert_exit_code "0"
}

function test_calling-help_returns_0_with_help_flag_before_arg() {
  calling-help --help bar
  assert_exit_code "0"
}

function test_calling-help_returns_0_with_help_flag_between_args() {
  calling-help foo --help bar
  assert_exit_code "0"
}

function test_calling-help_returns_0_with_h_flag() {
  calling-help -h
  assert_exit_code "0"
}

function test_calling-help_returns_0_with_h_flag_after_arg() {
  calling-help foo -h
  assert_exit_code "0"
}

function test_calling-help_returns_0_with_h_flag_before_arg() {
  calling-help -h bar
  assert_exit_code "0"
}

function test_calling-help_returns_0_with_h_flag_between_args() {
  calling-help foo -h bar
  assert_exit_code "0"
}

function test_calling-help_returns_1_with_no_args() {
  calling-help
  assert_exit_code "1"
}

function test_calling-help_returns_1_with_unrelated_arg() {
  calling-help foo
  assert_exit_code "1"
}

function test_calling-help_returns_1_with_multiple_unrelated_args() {
  calling-help foo bar
  assert_exit_code "1"
}

function test_calling-help_returns_1_when_help_is_not_freestanding() {
  calling-help --help-me
  assert_exit_code "1"
}

function test_calling-help_returns_1_when_help_is_suffix() {
  calling-help foo--help
  assert_exit_code "1"
}

function test_calling-help_returns_1_when_h_is_not_freestanding() {
  calling-help -hj
  assert_exit_code "1"
}

function test_calling-help_returns_1_when_h_is_embedded_in_word() {
  calling-help welcome-home
  assert_exit_code "1"
}
