# desktop (GNOME / Ubuntu)
- `dconf/*.ini` — selected GNOME settings (interface, background, wm, shell + extensions, mutter, nautilus, input sources, power). `paths.txt` maps file→dconf path. `@HOME@` is substituted at load time. Apply with `desktop/install.sh`.
- `.themes/Windows XP Luna` — GTK/shell theme (stowed to `~/.themes`).
- `.local/share/backgrounds/` — wallpapers.
- **Not in repo (too large):** WhiteSur icons/cursors (installer clones `vinceliuice/WhiteSur-icon-theme`), the WinXP SVG icon theme (~410 MB; download from KDE Store "WinXP SVG icon theme" by blackysgate and extract to `~/.icons/` manually).
- **Extensions** (install via Extension Manager if missing): Vitals, tiling-assistant, ubuntu-dock, ubuntu-appindicators, user-theme, ding.
- **COSMIC/Pop!_OS:** dconf settings and GNOME extensions are skipped. Instead the installer adds the `io.github.cosmic_utils.sysinfo-applet` flatpak (the Vitals replacement); add it to the panel from COSMIC Settings > Desktop > Panel. Conky runs via XWayland.
