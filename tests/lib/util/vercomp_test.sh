#!/usr/bin/env bash

# Load the util.sh library under test
source "${_root_dir}/lib/util.sh"

#
# vercomp() tests
#
# Return values:
#   0 = versions are equal
#   1 = first version is greater
#   2 = first version is less
#

# Equal versions
function test_vercomp_returns_0_for_identical_versions() {
  vercomp "1.0.0" "1.0.0"
  assert_exit_code "0"
}

function test_vercomp_returns_0_for_identical_two_part_versions() {
  vercomp "1.2" "1.2"
  assert_exit_code "0"
}

function test_vercomp_returns_0_for_identical_single_part_versions() {
  vercomp "5" "5"
  assert_exit_code "0"
}

function test_vercomp_returns_0_when_trailing_zeros_differ() {
  vercomp "1.0" "1.0.0"
  assert_exit_code "0"
}

function test_vercomp_returns_0_when_trailing_zeros_differ_reversed() {
  vercomp "1.0.0" "1.0"
  assert_exit_code "0"
}

function test_vercomp_returns_0_for_equal_versions_with_many_parts() {
  vercomp "1.2.3.4.5" "1.2.3.4.5"
  assert_exit_code "0"
}

# First version greater (returns 1)
function test_vercomp_returns_1_when_major_is_greater() {
  vercomp "2.0.0" "1.0.0"
  assert_exit_code "1"
}

function test_vercomp_returns_1_when_minor_is_greater() {
  vercomp "1.2.0" "1.1.0"
  assert_exit_code "1"
}

function test_vercomp_returns_1_when_patch_is_greater() {
  vercomp "1.0.2" "1.0.1"
  assert_exit_code "1"
}

function test_vercomp_returns_1_when_first_has_more_parts_and_greater() {
  vercomp "1.0.1" "1.0"
  assert_exit_code "1"
}

function test_vercomp_returns_1_for_double_digit_greater() {
  vercomp "1.10.0" "1.9.0"
  assert_exit_code "1"
}

function test_vercomp_returns_1_for_large_version_numbers() {
  vercomp "100.200.300" "100.200.299"
  assert_exit_code "1"
}

# First version less (returns 2)
function test_vercomp_returns_2_when_major_is_less() {
  vercomp "1.0.0" "2.0.0"
  assert_exit_code "2"
}

function test_vercomp_returns_2_when_minor_is_less() {
  vercomp "1.1.0" "1.2.0"
  assert_exit_code "2"
}

function test_vercomp_returns_2_when_patch_is_less() {
  vercomp "1.0.1" "1.0.2"
  assert_exit_code "2"
}

function test_vercomp_returns_2_when_second_has_more_parts_and_greater() {
  vercomp "1.0" "1.0.1"
  assert_exit_code "2"
}

function test_vercomp_returns_2_for_double_digit_less() {
  vercomp "1.9.0" "1.10.0"
  assert_exit_code "2"
}

function test_vercomp_returns_2_for_large_version_numbers() {
  vercomp "100.200.299" "100.200.300"
  assert_exit_code "2"
}

# Edge cases
function test_vercomp_returns_0_for_empty_strings() {
  vercomp "" ""
  assert_exit_code "0"
}

function test_vercomp_returns_0_for_zeros() {
  vercomp "0" "0"
  assert_exit_code "0"
}

function test_vercomp_returns_0_for_zero_and_zero_zero() {
  vercomp "0" "0.0"
  assert_exit_code "0"
}

function test_vercomp_handles_leading_zeros_in_parts() {
  vercomp "1.01" "1.1"
  assert_exit_code "0"
}

function test_vercomp_handles_leading_zeros_comparison() {
  vercomp "1.02" "1.1"
  assert_exit_code "1"
}
