#!/bin/sh

set -eux

ARCH="$(uname -m)"
PACKAGE=gnome-calculator
ICON=/usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg
DESKTOP=/usr/share/applications/org.gnome.Calculator.desktop
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

VERSION=$(pacman -Q "$PACKAGE" | awk 'NR==1 {print $2; exit}')
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME="$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage

# Prepare AppDir
mkdir -p ./AppDir/shared/lib

# Copy desktop file & icon
cp -v "$DESKTOP"   ./AppDir/
cp -v "$ICON"      ./AppDir/
cp -v "$ICON"      ./AppDir/.DirIcon

# Patch StartupWMClass to work on X11
# Doesn't work when ran in Wayland, as it's 'org.gnome.Calculator' instead.
# It needs to be manually changed by the user in this case.
sed -i '/^\[Desktop Entry\]/a\
StartupWMClass=gnome-calculator
' ./AppDir/*.desktop

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/gnome-calculator /usr/bin/gcalccmd /usr/lib/gnome-calculator-search-provider /usr/lib/pkcs11/*
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

# Symlink sharun AppRun
ln ./AppDir/sharun ./AppDir/AppRun

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
