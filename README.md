# gnome-calculator-appimage
Test of Gnome Calculator AppImage, not intended for daily-driving yet.

## Known issues

- On Fedora, Alpine & Maemo Leste, currency conversion doesn't work while it works in Arch-based distros, investigating the issue here:  
https://github.com/VHSgunzo/sharun/issues/56

## Known quirks

- Search-provider integration works only on Gnome (same as upstream) & it depends on:
  - the desktop file being present (which AppImage managers like `soar` & `am` already take care of).  
    Desktop file needs to be named `org.gnome.Calculator.desktop` for it to work.  
    The only exception is the detection for desktop file `gnome-calculator-AM.desktop` in local directories, which is added as a support for `am` AppImage manager.
  - the `XDG_DATA_DIRS` variable having the `XDG_DATA_HOME` in path, which the AppImage will detect if not present + warn about & suggest the solution.
