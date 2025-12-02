#!/usr/bin/env bash
set -euo pipefail
# Place your common test setup here

# Resolve the project root directory
_test_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_root_dir="$(cd "${_test_dir}/.." && pwd)"

# Set TMUXIFIER so libexec commands can find lib/util.sh
export TMUXIFIER="${_root_dir}"

# Add libexec to PATH so tmuxifier commands are available
export PATH="${_root_dir}/libexec:${PATH}"
