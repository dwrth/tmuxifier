#!/usr/bin/env bash

# Load the layout-helpers.sh library under test
source "${_root_dir}/lib/layout-helpers.sh"

#
# tmux() tests
#

function test_tmux_passes_single_arg_to_tmuxifier_tmux() {
  spy tmuxifier-tmux

  tmux -V

  assert_have_been_called_with tmuxifier-tmux "-V"
}

function test_tmux_passes_help_flag_to_tmuxifier_tmux() {
  spy tmuxifier-tmux

  tmux --help

  assert_have_been_called_with tmuxifier-tmux "--help"
}

function test_tmux_passes_multiple_args_to_tmuxifier_tmux() {
  spy tmuxifier-tmux

  tmux new -s dude

  assert_have_been_called_with tmuxifier-tmux "new -s dude"
}

function test_tmux_passes_complex_args_to_tmuxifier_tmux() {
  spy tmuxifier-tmux

  tmux new-session -d -s "my-session" -n "main"

  assert_have_been_called_with \
    tmuxifier-tmux "new-session -d -s my-session -n main"
}

function test_tmux_called_multiple_times() {
  spy tmuxifier-tmux

  tmux list-sessions
  tmux list-windows
  tmux list-panes

  assert_have_been_called_times 3 tmuxifier-tmux
  assert_have_been_called_with tmuxifier-tmux "list-sessions" 1
  assert_have_been_called_with tmuxifier-tmux "list-windows" 2
  assert_have_been_called_with tmuxifier-tmux "list-panes" 3
}
