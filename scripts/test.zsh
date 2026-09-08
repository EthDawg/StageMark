#!/bin/zsh
set -euo pipefail
STAGEMARK_ROOT="${0:A:h:h}"
cd "$STAGEMARK_ROOT"
PYTHONDONTWRITEBYTECODE=1 python3 scripts/release/test_release.py
mkdir -p .build/module-cache .build/cache
export CLANG_MODULE_CACHE_PATH="$STAGEMARK_ROOT/.build/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$STAGEMARK_ROOT/.build/module-cache"
STAGEMARK_SOURCES=(Sources/StageMark/*.swift)
STAGEMARK_SOURCES=("${(@)STAGEMARK_SOURCES:#Sources/StageMark/main.swift}")
swiftc -swift-version 5 -module-name StageMarkTests -module-cache-path "$CLANG_MODULE_CACHE_PATH" -framework Carbon \
  "${STAGEMARK_SOURCES[@]}" Tests/StageMarkTests/*.swift -o .build/StageMarkTests
STAGEMARK_TEST_LOG="$(mktemp)"
trap 'rm -f -- "$STAGEMARK_TEST_LOG"' EXIT
.build/StageMarkTests "$@" | tee "$STAGEMARK_TEST_LOG"
# AppKit can exit during initialization with status zero in a restricted
# session. Require the actual suite result so that is never a false pass.
grep -Eq '^[0-9]+ tests · [0-9]+ assertions · 0 failures$' "$STAGEMARK_TEST_LOG"
