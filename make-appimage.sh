#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q gnome-calculator | awk '{print $2; exit}')
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg
export DESKTOP=/usr/share/applications/org.gnome.Calculator.desktop
export STARTUPWMCLASS=org.gnome.Calculator # Default to Wayland's wmclass. For X11, GTK_CLASS_FIX will force the wmclass to be the Wayland one.
export GTK_CLASS_FIX=1

# Trace and deploy all files and directories needed for the application (including binaries, libraries and others)
quick-sharun /usr/bin/gnome-calculator \
             /usr/bin/gcalccmd \
             /usr/lib/gnome-calculator-search-provider \
             /usr/share/vala \
             /usr/share/devhelp \
             /usr/share/help/*/gnome-calculator

## Copy files needed for search integration
mkdir -p ./AppDir/share/gnome-shell/search-providers/
cp -v /usr/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini ./AppDir/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini
mkdir -p ./AppDir/share/dbus-1/services/
cp -v /usr/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service ./AppDir/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service

# Turn AppDir into AppImage
quick-sharun --make-appimage
