# Gnome-Calculator-AppImage 🐧

[![GitHub Downloads](https://img.shields.io/github/downloads/pkgforge-dev/Gnome-Calculator-AppImage/total?logo=github&label=GitHub%20Downloads)](https://github.com/pkgforge-dev/Gnome-Calculator-AppImage/releases/latest)
[![CI Build Status](https://github.com//pkgforge-dev/Gnome-Calculator-AppImage/actions/workflows/blank.yml/badge.svg)](https://github.com/pkgforge-dev/Gnome-Calculator-AppImage/releases/latest)

* [Latest Stable Release](https://github.com/pkgforge-dev/Gnome-Calculator-AppImage/releases/latest)

---

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks. 

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i rnote` or `appman -i rnote`

* [dbin](https://github.com/xplshn/dbin) `dbin install rnote.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install rnote`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

More at: [AnyLinux-AppImages](https://pkgforge-dev.github.io/Anylinux-AppImages/)

---

## Known quirks

- Search-provider integration works only on Gnome (same as upstream) & it depends on:
  - the desktop file being present (which AppImage managers like `soar` & `am` already take care of).  
    Desktop file needs to be named `org.gnome.Calculator.desktop` for it to work.  
    The only exception is the detection for desktop file `gnome-calculator-AM.desktop` in local directories, which is added as a support for `am` AppImage manager.
  - the `XDG_DATA_DIRS` variable having the `XDG_DATA_HOME` in path, which the AppImage will detect if not present + warn about & suggest the solution.
- If you use AppImage portable folders feature & you want to use the search-provider functionality, than only use portable `appimage-filename.config` folder to make the functionality work.
  - If you want to clean `$HOME` after uninstallation, besides regular application dotfiles, you also need to remove the files below, which are used for search-provider integration:
    - `${XDG_DATA_HOME}/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini`
    - `${XDG_DATA_HOME}/dbus-1/services/org.gnome.Calculator.SearchProvider.service`
