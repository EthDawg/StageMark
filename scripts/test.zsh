#!/bin/zsh
set -euo pipefail
STAGEMARK_ROOT="${0:A:h:h}"
cd "$STAGEMARK_ROOT"
mkdir -p .build/module-cache .build/cache
export CLANG_MODULE_CACHE_PATH="$STAGEMARK_ROOT/.build/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$STAGEMARK_ROOT/.build/module-cache"
STAGEMARK_SOURCES=(Sources/StageMark/*.swift)
STAGEMARK_SOURCES=("${(@)STAGEMARK_SOURCES:#Sources/StageMark/main.swift}")
swiftc -swift-version 5 -module-name StageMarkTests -module-cache-path "$CLANG_MODULE_CACHE_PATH" -framework Carbon \
  "${STAGEMARK_SOURCES[@]}" Tests/StageMarkTests/*.swift -o .build/StageMarkTests
.build/StageMarkTests "$@"
