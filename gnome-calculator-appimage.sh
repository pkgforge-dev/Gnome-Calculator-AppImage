#!/bin/sh

set -eux

ARCH="$(uname -m)"
PACKAGE=gnome-calculator
ICON=/usr/share/icons/hicolor/scalable/apps/org.gnome.Calculator.svg
DESKTOP=/usr/share/applications/org.gnome.Calculator.desktop
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
APPRUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/AppRun-generic"
UPDATER="https://github.com/pkgforge-dev/AppImageUpdate-Enhanced-Edition/releases/latest/download/appimageupdatetool+validate-$ARCH.AppImage"
UPHOOK="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/self-updater.bg.hook"

VERSION=$(pacman -Q "$PACKAGE" | awk 'NR==1 {print $2; exit}')
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME="$PACKAGE"-"$VERSION"-anylinux-"$ARCH".AppImage

# Prepare AppDir
mkdir -p ./AppDir/shared/lib

# Copy desktop file & icon
cp -v "$DESKTOP"   ./AppDir/
cp -v "$ICON"      ./AppDir/

# Patch StartupWMClass to work on X11
# Doesn't work when ran in Wayland, as it's 'org.gnome.Calculator' instead.
# It needs to be manually changed by the user in this case.
sed -i '/^\[Desktop Entry\]/a\
StartupWMClass=gnome-calculator
' ./AppDir/*.desktop

# DEPLOY ALL LIBS
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/gnome-calculator /usr/bin/gcalccmd /usr/lib/gnome-calculator-search-provider
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

## Copy search integration files
mkdir -p ./AppDir/share/gnome-shell/search-providers/
cp -v /usr/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini ./AppDir/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini
mkdir -p ./AppDir/share/dbus-1/services/
cp -v /usr/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service ./AppDir/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service

# Get AppRun, integrate self-updater & integrate search into settings
wget --retry-connrefused --tries=30 "$APPRUN"  -O ./AppDir/AppRun
wget --retry-connrefused --tries=30 "$UPHOOK"  -O ./AppDir/bin/self-updater.bg.hook
wget --retry-connrefused --tries=30 "$UPDATER" -O ./AppDir/bin/appimageupdatetool

cat << 'EOF' > ./AppDir/bin/search-integration.hook
#!/bin/sh

CURRENTDIR="$(cd "${0%/*}"/.. && echo "$PWD")"
SHAREDIR="${XDG_DATA_HOME:-$HOME/.local/share}"

# Attempt to copy search-provider files to the host, so Gnome Calculator entry is available in search options
if command -v gnome-shell 1>/dev/null; then
  if [ ! -d "${SHAREDIR}/gnome-shell/search-providers/" ]; then
    mkdir -p "${SHAREDIR}/gnome-shell/search-providers/"
  fi
  if [ ! -f "${SHAREDIR}/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini" ]; then
    cp "${CURRENTDIR}/share/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini" "${SHAREDIR}/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini"
  fi
fi
if [ ! -d "${SHAREDIR}/dbus-1/services/" ]; then
  mkdir -p "${SHAREDIR}/dbus-1/services/"
fi
if [ ! -f "${SHAREDIR}/dbus-1/services/org.gnome.Calculator.SearchProvider.service" ]; then
  cp "${CURRENTDIR}/share/dbus-1/services/org.gnome.Calculator.SearchProvider.service" "${SHAREDIR}/dbus-1/services/org.gnome.Calculator.SearchProvider.service"
fi
# Dir needs to changed every time AppImage launches for search provider to work
if [ "${APPIMAGE##*/}" = "gnome-calculator" ]; then
  sed -i 's|/usr/lib/gnome-calculator-search-provider|'"${CURRENTDIR}/bin/gnome-calculator-search-provider"'|g' "${SHAREDIR}/dbus-1/services/org.gnome.Calculator.SearchProvider.service"
else
  sed -i 's|/usr/lib/gnome-calculator-search-provider|'"${APPIMAGE} gnome-calculator-search-provider"'|g' "${SHAREDIR}/dbus-1/services/org.gnome.Calculator.SearchProvider.service"
fi
EOF

chmod +x ./AppDir/AppRun ./AppDir/bin/*.hook ./AppDir/bin/appimageupdatetool

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
