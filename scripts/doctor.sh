#!/bin/bash
# Read-only prerequisite check; does not install tools, models, or apps.
set -euo pipefail
fail() { printf 'Setup needed: %s
' "$1" >&2; exit 1; }
[ "$(uname -s)" = Darwin ] || fail "Build and run on macOS. Documentation contributions work on any OS."
[ "$(uname -m)" = arm64 ] || fail "Use an Apple Silicon Mac and a native Terminal (not Rosetta)."
xcode-select -p >/dev/null 2>&1 || fail "Run xcode-select --install, then retry."
command -v swift >/dev/null 2>&1 || fail "Install Apple Command Line Tools with xcode-select --install."
OS_MAJOR="$(sw_vers -productVersion | cut -d. -f1)"
[ "$OS_MAJOR" -ge 14 ] || fail "macOS 14 or later is required."
SDK_VERSION="$(xcrun --sdk macosx --show-sdk-version)"
SWIFT_VERSION="$(swift --version)"
printf '%s
' "$SWIFT_VERSION"
printf 'macOS SDK: %s
' "$SDK_VERSION"
printf 'Ready to build. See CONTRIBUTING.md for the next command.
'
