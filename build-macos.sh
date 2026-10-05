#!/bin/zsh
# Builds build/Inputify.app on macOS.
# Input Monitoring is granted to a code signature: an ad-hoc one changes with every build, so each rebuild would need a
# new grant. Set INPUTIFY_SIGN_IDENTITY to a stable identity (a self-signed one is enough) to keep the grant.
set -e
cd "$(dirname "$0")"
export PUREBASIC_HOME="${PUREBASIC_HOME:-/Applications/PureBasic.app/Contents/Resources}"
PBFLAGS="${PBFLAGS:-}"
IDENTITY="${INPUTIFY_SIGN_IDENTITY:--}"
APP=build/Inputify.app

mkdir -p build
rm -rf build/Inputify.iconset "$APP"
mkdir build/Inputify.iconset
for s in 16 32 128 256 512; do
	sips -z $s $s Media/Icon/512.png --out build/Inputify.iconset/icon_${s}x${s}.png >/dev/null
	sips -z $((s * 2)) $((s * 2)) Media/Icon/512.png --out build/Inputify.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns build/Inputify.iconset -o build/Inputify.icns

# --dpiaware is what the IDE passes for the target's dpiaware="1": PB canvases then render at Retina resolution
"$PUREBASIC_HOME/compilers/pbcompiler" -q -z -ibp --dpiaware ${=PBFLAGS} Main.pb -n build/Inputify.icns -o "$APP"

PL="$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier net.lastlife.inputify" "$PL" 2>/dev/null || /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string net.lastlife.inputify" "$PL"
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$PL" 2>/dev/null || true	# No Dock icon: Inputify lives in the menu bar
/usr/libexec/PlistBuddy -c "Add :NSHighResolutionCapable bool true" "$PL" 2>/dev/null || true

codesign --force --sign "$IDENTITY" --identifier net.lastlife.inputify "$APP"
echo "Built $APP"
