#!/bin/zsh
set -euo pipefail
STAGEMARK_ROOT="${0:A:h:h}"
cd "$STAGEMARK_ROOT"
if [ "${1:-}" = "--preview" ]; then
    shift
    exec python3 scripts/release/preview.py build "$@"
fi
mkdir -p .build/module-cache .build/cache build
export CLANG_MODULE_CACHE_PATH="$STAGEMARK_ROOT/.build/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$STAGEMARK_ROOT/.build/module-cache"
STAGEMARK_UNIVERSAL=0
if [[ "${1:-}" == "--universal" ]]; then STAGEMARK_UNIVERSAL=1; shift; fi
if (( $# > 0 )); then print -u2 "Usage: build.zsh [--preview [preview options] | --universal]"; exit 2; fi
if (( STAGEMARK_UNIVERSAL )); then
  # Two independent SwiftPM builds also work with Command Line Tools; SwiftPM's
  # multi-arch Xcode backend otherwise requires a full Xcode installation.
  for arch in arm64 x86_64; do
    swift build -c release --arch "$arch" --scratch-path ".build/universal-$arch" --disable-sandbox
  done
  STAGEMARK_BIN_DIR="$STAGEMARK_ROOT/.build/universal"
  mkdir -p "$STAGEMARK_BIN_DIR"
  lipo -create ".build/universal-arm64/arm64-apple-macosx/release/StageMark" ".build/universal-x86_64/x86_64-apple-macosx/release/StageMark" -output "$STAGEMARK_BIN_DIR/StageMark"
  lipo "$STAGEMARK_BIN_DIR/StageMark" -verify_arch arm64 x86_64
else
  swift build -c release --cache-path "$STAGEMARK_ROOT/.build/cache" --disable-sandbox
  STAGEMARK_BIN_DIR="$(swift build -c release --show-bin-path --disable-sandbox)"
fi
# Keep unpacked build products out of Spotlight and Launch Services. The only
# lasting .app should be the installed copy in /Applications.
STAGEMARK_PACKAGE_DIR="$(mktemp -d "$STAGEMARK_ROOT/.build/package.XXXXXX")"
trap 'rm -rf -- "$STAGEMARK_PACKAGE_DIR"' EXIT
STAGEMARK_APP="$STAGEMARK_PACKAGE_DIR/Workbench StageMark.app"
mkdir -p "$STAGEMARK_APP/Contents/MacOS" "$STAGEMARK_APP/Contents/Resources"
cp "$STAGEMARK_BIN_DIR/StageMark" "$STAGEMARK_APP/Contents/MacOS/StageMark"
cp Resources/Info.plist "$STAGEMARK_APP/Contents/Info.plist"
if [[ ! -f Resources/AppIcon.icns ]]; then
  swift scripts/make-icon.swift
  iconutil -c icns build/AppIcon.iconset -o Resources/AppIcon.icns
fi
cp Resources/AppIcon.icns "$STAGEMARK_APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - --identifier local.ethan.StageMark "$STAGEMARK_APP"
codesign --verify --deep --strict "$STAGEMARK_APP"
ditto -c -k --sequesterRsrc --keepParent "$STAGEMARK_APP" "$STAGEMARK_PACKAGE_DIR/StageMark.zip"
mv "$STAGEMARK_PACKAGE_DIR/StageMark.zip" build/StageMark.zip
print "Built and signed: $STAGEMARK_ROOT/build/StageMark.zip"
