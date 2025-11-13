#!/bin/sh

set -eux

ARCH="$(uname -m)"
VERSION="$(cat ~/version)"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

# Variables used by quick-sharun
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=gnome-calculator-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/org.gnome.Calculator.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg
export DEPLOY_OPENGL=1
export STARTUPWMCLASS=gnome-calculator # For Wayland, this is 'org.gnome.Calculator', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# Trace and deploy all files and directories needed for the application (including binaries, libraries and others)
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/gnome-calculator /usr/bin/gcalccmd /usr/lib/gnome-calculator-search-provider /usr/share/vala /usr/share/devhelp

## Copy help files for Help section to work
langs=$(find /usr/share/help/*/gnome-calculator/ -type f | awk -F'/' '{print $5}' | sort | uniq)
for lang in $langs; do
  mkdir -p ./AppDir/share/help/$lang/gnome-calculator/
  cp -vr /usr/share/help/$lang/gnome-calculator/* ./AppDir/share/help/$lang/gnome-calculator/
done

## Copy files needed for search integration
mkdir -p ./AppDir/share/gnome-shell/search-providers/
cp -v /usr/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini ./AppDir/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini
mkdir -p ./AppDir/share/dbus-1/services/
cp -v /usr/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service ./AppDir/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service

# Make the AppImage with uruntime
./quick-sharun --make-appimage

# Prepare the AppImage for release
mkdir -p ./dist
mv -v ./*.AppImage* ./dist
mv -v ~/version     ./dist
