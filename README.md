# gnome-calculator-appimage
Test of Gnome Calculator AppImage, not intended for daily-driving yet.

## Known issues / TO-DO

- Build `gnome-calculator` from source instead of relying on Arch repos
- Search integration doesn't work when using AppImage's portable folders (like `.home`, `.config` or uruntime's `.share`)
- When used normally, files for integrating search provider are cluttered in `$HOME`, so for clean uninstall, you need to additionally remove:
  - `${XDG_DATA_HOME}/gnome-shell/search-providers/org.gnome.Calculator-search-provider.ini`
  - `${XDG_DATA_HOME}/dbus-1/services/org.gnome.Calculator.SearchProvider.service`
- On Fedora, currency conversion doesn't work while it works in other distros, investigating the issue here:  
https://github.com/VHSgunzo/sharun/issues/56
