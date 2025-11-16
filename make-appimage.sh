#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q gnome-calculator | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg
export DESKTOP=/usr/share/applications/org.gnome.Calculator.desktop
export DEPLOY_OPENGL=1
export STARTUPWMCLASS=gnome-calculator # For Wayland, this is 'org.gnome.Calculator', so this needs to be changed in desktop file manually by the user in that case until some potential automatic fix exists for this

# Trace and deploy all files and directories needed for the application (including binaries, libraries and others)
quick-sharun /usr/bin/gnome-calculator \
             /usr/bin/gcalccmd \
             /usr/lib/gnome-calculator-search-provider \
             /usr/share/vala \
             /usr/share/devhelp

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

# Turn AppDir into AppImage
quick-sharun --make-appimage
