#! /usr/bin/env bash
source "../test-helper.sh"
source "${root}/lib/util.sh"

#
# tmuxifier-tmux tests.
#

# Setup.
test-socket-tmux new-session -d -s foobar
test-socket-tmux new-session -d -s dude
baseCommand="${root}/bin/tmuxifier tmux"

# Passes all arguments to Tmux.
assert "${baseCommand} list-sessions -F \"- #{session_name}\"" \
       "- dude\n- foobar"

# Tear down.
kill-test-server

# End of tests.
assert_end "tmuxifier-tmux"
