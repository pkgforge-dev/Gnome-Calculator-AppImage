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
cd ./AppDir

# Copy desktop file & icon
cp -v "$DESKTOP"   ./
cp -v "$ICON"      ./
cp -v "$ICON"      ./.DirIcon

# Patch StartupWMClass to work on X11
# Doesn't work when ran in Wayland, as it's 'org.gnome.Calculator' instead.
# It needs to be manually changed by the user in this case.
sed -i '/^\[Desktop Entry\]/a\
StartupWMClass=gnome-calculator
' "$DESKTOP"

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
export DST_DIR="$PWD"/AppDir
./quick-sharun /usr/bin/gnome-calculator

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

# Set up the PELF toolchain
wget --retry-connrefused --tries=30 \
	"https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH" -O ./pelf
chmod +x ./pelf

echo "Generating [dwfs]AppBundle...(Go runtime)"
./pelf --add-appdir ./AppDir \
	--appbundle-id="$PACKAGE-$VERSION" \
	--compression "-C zstd:level=22 -S26 -B8" \
	--output-to "$PACKAGE-$VERSION-anylinux-$ARCH.dwfs.AppBundle" \

zsyncmake *.AppBundle -u *.AppBundle

echo "All Done!"
