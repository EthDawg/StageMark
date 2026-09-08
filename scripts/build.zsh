#!/bin/zsh
set -euo pipefail
STAGEMARK_ROOT="${0:A:h:h}"
cd "$STAGEMARK_ROOT"
mkdir -p .build/module-cache .build/cache build
export CLANG_MODULE_CACHE_PATH="$STAGEMARK_ROOT/.build/module-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$STAGEMARK_ROOT/.build/module-cache"
swift build -c release --cache-path "$STAGEMARK_ROOT/.build/cache" --disable-sandbox
# Keep unpacked build products out of Spotlight and Launch Services. The only
# lasting .app should be the installed copy in /Applications.
STAGEMARK_PACKAGE_DIR="$(mktemp -d "$STAGEMARK_ROOT/.build/package.XXXXXX")"
trap 'rm -rf -- "$STAGEMARK_PACKAGE_DIR"' EXIT
STAGEMARK_APP="$STAGEMARK_PACKAGE_DIR/Workbench StageMark.app"
mkdir -p "$STAGEMARK_APP/Contents/MacOS" "$STAGEMARK_APP/Contents/Resources"
cp .build/release/StageMark "$STAGEMARK_APP/Contents/MacOS/StageMark"
cp Resources/Info.plist "$STAGEMARK_APP/Contents/Info.plist"
if [[ ! -f Resources/AppIcon.icns || scripts/make-icon.swift -nt Resources/AppIcon.icns ]]; then
  swift scripts/make-icon.swift
  iconutil -c icns build/AppIcon.iconset -o Resources/AppIcon.icns
fi
cp Resources/AppIcon.icns "$STAGEMARK_APP/Contents/Resources/AppIcon.icns"
codesign --force --sign - --identifier local.ethan.StageMark "$STAGEMARK_APP"
codesign --verify --deep --strict "$STAGEMARK_APP"
ditto -c -k --sequesterRsrc --keepParent "$STAGEMARK_APP" "$STAGEMARK_PACKAGE_DIR/StageMark.zip"
mv "$STAGEMARK_PACKAGE_DIR/StageMark.zip" build/StageMark.zip
print "Built and signed: $STAGEMARK_ROOT/build/StageMark.zip"
