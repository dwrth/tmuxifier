# AGENTS.md

This file provides guidance to AI Agents when working with code in this
repository.

## Project Overview

Tmuxifier is a shell-based tool for creating and managing complex Tmux session
and window layouts. Users write layout files as shell scripts that use tmux
commands and helper functions to define session/window configurations.

## Architecture

### Core Components

- **bin/tmuxifier**: Main executable that bootstraps the environment, validates
  Tmux version (≥1.6), and dispatches to libexec commands
- **libexec/**: Command implementations (tmuxifier-*, e.g.,
  tmuxifier-load-session, tmuxifier-new-window)
- **lib/layout-helpers.sh**: Helper functions available within layout files
  (new_window, split_v, split_h, run_cmd, select_pane, etc.)
- **lib/runtime.sh**: Runtime environment loader sourced by layout files
- **lib/env.sh**: Sets up TMUXIFIER_LAYOUT_PATH (defaults to $TMUXIFIER/layouts)
- **templates/**: Templates for new session.sh and window.sh layout files
- **examples/**: Example layout files demonstrating usage

### Layout File Types

**Session layouts** (*.session.sh):

- Define entire Tmux sessions with multiple windows
- Must call `initialize_session` to create the session
- Can load window layouts via `load_window` or define windows inline
- Must call `finalize_and_go_to_session` at the end
- Can set `session_root` for default directory

**Window layouts** (*.window.sh):

- Define single window configurations with panes
- Loaded into existing sessions or from session layouts
- Can set `window_root` for window-specific directory
- Use helper functions to split panes and run commands

### Key Concepts

- Layout files are executed as shell scripts with lib/layout-helpers.sh sourced
- Helper functions wrap tmux commands, managing session/window context
- The `tmux` command itself is aliased to tmuxifier-tmux wrapper
- Session creation moves default window to position 999, then kills it in
  finalize_and_go_to_session
- TMUXIFIER_TMUX_OPTS allows passing custom arguments to tmux

## Development Commands

### Testing

Tests use [bashunit](https://github.com/TypedDevs/bashunit) framework. Use
deepwiki MCP tool to lookup bashunit documentation if needed.

```bash
make test                                  # Run all tests
make test FILE=tests/lib/util/foo_test.sh  # Run a single test file
make bootstrap                             # Fetch test dependencies
```

Tests are located in `tests/` directory and follow bashunit conventions. Test
files are named `*_test.sh`.

Legacy tests in `test-legacy/` use test-runner.sh framework with assert.sh and
stub.sh libraries. Run with `make test-legacy`.

### Manual Testing

```bash
# Create and load a test window layout
./bin/tmuxifier new-window test-window
./bin/tmuxifier load-window test-window

# Create and load a test session layout
./bin/tmuxifier new-session test-session
./bin/tmuxifier load-session test-session

# List available layouts
./bin/tmuxifier list-sessions
./bin/tmuxifier list-windows
```

## Code Style

- Shell scripts follow Bash conventions
- 2-space indentation
- Functions document arguments in comments
- Use local variables for function scope
- Prefer `[ ]` over `[[ ]]` for basic tests
- Command substitution uses `$()` not backticks

## Important Implementation Details

### Helper Function Pattern

Helper functions in lib/layout-helpers.sh follow this pattern:

```bash
function_name() {
  # Parse optional arguments
  if [ -n "$1" ]; then local arg=(-flag "$1"); fi

  # Execute tmux command with session/window context
  tmuxifier-tmux command -t "$session:$window" "${arg[@]}"

  # Update state if needed
  __go_to_window_or_session_path
}
```

### Tmux Version Handling

Code must support Tmux 1.6+. Version-specific behavior uses
tmuxifier-tmux-version comparisons:

```bash
if [ "$(tmuxifier-tmux-version "1.9")" == "<" ]; then
  # Tmux 1.8 and earlier
else
  # Tmux 1.9 and later
fi
```

### Path Expansion

Use `__expand_path` to handle ~ and variables in paths:

```bash
session_root() {
  local dir="$(__expand_path $@)"
  if [ -d "$dir" ]; then
    session_root="$dir"
  fi
}
```

## Environment Variables

- **TMUXIFIER**: Set to installation directory (auto-detected from bin location)
- **TMUXIFIER_LAYOUT_PATH**: Custom layouts directory (default:
  $TMUXIFIER/layouts)
- **TMUXIFIER_TMUX_OPTS**: Custom arguments passed to tmux
- **TMUXIFIER_TMUX_ITERM_ATTACH**: Set to "-CC" for iTerm2 integration
- **TMUXIFIER_NO_COMPLETE**: Disable shell completion if set
- **TMUXIFIER_MIN_TMUX_VERSION**: Minimum required Tmux version (1.6)
