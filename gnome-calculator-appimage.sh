#!/bin/sh

set -eux

ARCH="$(uname -m)"
PACKAGE=gnome-calculator
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

VERSION=$(pacman -Q "$PACKAGE" | awk 'NR==1 {print $2; exit}')
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

# Variables used by quick-sharun
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME="$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/org.gnome.Calculator.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg

# Prepare AppDir
mkdir -p ./AppDir/shared/lib

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
GSK_RENDERER=cairo ./quick-sharun /usr/bin/gnome-calculator /usr/bin/gcalccmd /usr/lib/gnome-calculator-search-provider
cp -vr /usr/share/vala ./AppDir/share/
cp -vr /usr/share/devhelp ./AppDir/share/

## Copy locale manually, as sharun doesn't do that at the moment
cp -vr /usr/lib/locale           ./AppDir/shared/lib
cp -r /usr/share/locale          ./AppDir/share
find ./AppDir/share/locale -type f ! -name '*glib*' ! -name '*gnome-calculator*' -delete
find ./AppDir/share/locale -type f 
## Fix hardcoded path for locale
sed -i 's|/usr/share|././/share|g' ./AppDir/shared/bin/gnome-calculator
## Needed when locale patch is used
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}' > ./AppDir/.env

## Copy help files for Help section to work
langs=$(find /usr/share/help/*/gnome-calculator/ -type f | awk -F'/' '{print $5}' | sort | uniq)
for lang in $langs; do
  mkdir -p ./AppDir/share/help/$lang/gnome-calculator/
  cp -vr /usr/share/help/$lang/gnome-calculator/* ./AppDir/share/help/$lang/gnome-calculator/
done

## Copy the icon to AppDir's share, as it's not copied by default
mkdir -p           ./AppDir/share/icons/hicolor/scalable/apps/
cp -v "$ICON"      ./AppDir/"${ICON#/usr/}"

# Patch StartupWMClass to work on X11
# Doesn't work when ran in Wayland, as it's 'org.gnome.Calculator' instead.
# It needs to be manually changed by the user in this case.
sed -i '/^\[Desktop Entry\]/a\
StartupWMClass=gnome-calculator
' ./AppDir/*.desktop

## Force use of cairo backend
echo "GSK_RENDERER=cairo" >> ./AppDir/.env

## Do search integration
mkdir -p ./AppDir/share/gnome-shell/search-providers/
cp -v /usr/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini ./AppDir/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini
mkdir -p ./AppDir/share/dbus-1/services/
cp -v /usr/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service ./AppDir/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
