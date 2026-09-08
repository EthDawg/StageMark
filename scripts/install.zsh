#!/bin/zsh
set -euo pipefail
STAGEMARK_ROOT="${0:A:h:h}"
cd "$STAGEMARK_ROOT"
if pgrep -x StageMark >/dev/null; then
  print -u2 "Quit Workbench StageMark before installing."
  exit 1
fi
zsh scripts/build.zsh
STAGEMARK_INSTALL="$(mktemp -d "$STAGEMARK_ROOT/.build/install.XXXXXX")"
trap 'rm -rf -- "$STAGEMARK_INSTALL"' EXIT
ditto -x -k build/StageMark.zip "$STAGEMARK_INSTALL"
codesign --verify --deep --strict "$STAGEMARK_INSTALL/Workbench StageMark.app"
for old in "/Applications/Workbench StageMark.app" "/Applications/StageMark.app"; do
  if [[ -d "$old" ]]; then
    ditto -c -k --sequesterRsrc --keepParent "$old" "build/Previous-${old:t}.zip"
    rm -rf -- "$old"
  fi
done
mv "$STAGEMARK_INSTALL/Workbench StageMark.app" /Applications/
codesign --verify --deep --strict "/Applications/Workbench StageMark.app"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "/Applications/Workbench StageMark.app"
print "Installed: /Applications/Workbench StageMark.app"
