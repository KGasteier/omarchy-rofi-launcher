**English** · [Deutsch](README.md)

# Omarchy Rofi Launcher

An app launcher in the style of the macOS Launchpad for
[Omarchy](https://omarchy.org): large icon grid, search field with a
magnifier, floating window.

![7×7 grid](docs/screenshot.png)

## Features

- **7 × 7 grid** with 92 px icons and labels
- **A "recently used" row** at the top, set off by a gentle line
- **Search field** with a magnifier glyph, title bar empty on start
- **Mouse and keyboard**: hover highlights, a single click launches; arrow
  keys and Enter do the same
- **Floating overlay**: centred, pinned, closes on app selection or `ESC`
- **Follows the theme**: recolours automatically when the Omarchy theme changes
- **Placeholder icons** for web apps and TUIs without an icon of their own

## Installation

`rofi` is required:

```bash
omarchy-pkg-install rofi
```

Then:

```bash
git clone https://github.com/KGasteier/omarchy-rofi-launcher.git
cd omarchy-rofi-launcher
./install.sh
```

**`SUPER + R`** opens the launcher, pressing it again closes it.

To remove: `./install.sh --uninstall`

## What gets installed

| File | Purpose |
|---|---|
| `~/.local/bin/omarchy-launch-rofi` | launcher with toggle |
| `~/.local/bin/omarchy-rofi-drun-recent` | rofi mode with a "recently used" row |
| `~/.local/bin/omarchy-rofi-placeholder-icons` | icon generator |
| `~/.config/hypr/rofi-launcher.lua` | key binding, window rules |
| `~/.config/omarchy/themed/applauncher.rasi.tpl` | theme template |
| `~/.config/rofi/applauncher.rasi` | static fallback |
| `~/.local/share/icons/hicolor/scalable/apps/*.svg` | placeholders |

A block between markers is added to `~/.config/hypr/hyprland.lua` and removed
again on uninstall; a backup is written beforehand.

## Customising

Grid and sizes live in `~/.config/omarchy/themed/applauncher.rasi.tpl`:

```css
listview { columns: 7; lines: 7; }   /* grid          */
element-icon { size: 92px; }         /* icon edge length */
window { width: 1770px; height: 1350px; }
```

After changing it, set the theme once more so the template takes effect:

```bash
omarchy-theme-set "$(< ~/.local/state/omarchy/current/theme.name)"
```

If you raise the number of rows, `height` has to grow with it, otherwise the
window cuts off the last row. A rule of thumb is roughly 169 px per row with
92 px icons; keep the height tight, or visible empty space remains at the
bottom.

`listview { spacing }` deliberately stays at `0px`; the row spacing sits in
`element { padding }`. Otherwise the separator line below the "recently used"
row gets gaps at the cell boundaries.

### Placeholder icons

To cover newly installed web apps:

```bash
omarchy-rofi-placeholder-icons            # generate
omarchy-rofi-placeholder-icons --dry-run  # show only
omarchy-rofi-placeholder-icons --force    # overwrite existing ones
```

The tile colour derives from a SHA-256 of the icon name: the same app keeps
its colour, and the palette spreads across the colour wheel. Generated files
carry a marker inside the SVG — real icons are never overwritten, and
`--uninstall` deletes only its own.

### The "recently used" row

The top row shows the most recently launched applications, sorted by
frequency. It is based on `~/.cache/rofi3.druncache` — the same file rofi's
built-in `drun` maintains.

If there are fewer than seven, the row still spans seven cells so the
alphabetical list starts cleanly on the next row; the empty cells are
invisible and do not react to the mouse. If there is not a single entry, the
row and its separator are dropped entirely.

The row can be emptied:

```bash
: > ~/.cache/rofi3.druncache
```

## Known quirks

**rofi runs through XWayland.** The `extra/rofi` package is X11-based; there
is currently no maintained Wayland fork in the Arch repos or the AUR. Under
Hyprland it works via XWayland — which is why the window rules target the
class `Rofi`.

**The magnifier needs a Nerd font.** The symbol is U+F002 from the Nerd Font
range; `Adwaita Sans`, the font used for labels, has no magnifier glyph.
`install.sh` warns if no suitable font is present. Remedy:
`ttf-jetbrains-mono-nerd`.

**The window deliberately sits slightly above centre.** `center = true`
centres within the *usable* area, i.e. below a bar such as Waybar — which
makes the launcher look too low. The window rule uses `move` against the full
monitor height instead.

**The window keeps its size**, even when the search yields only a few matches
— just like the original.

`fixed-height: false` is **not a usable alternative** here, obvious though it
seems: rofi then sizes the window by the *number of entries*, not by the grid
rows in use. With `flow: horizontal` four matches fit in one row, yet the
window becomes four rows tall. The surplus area gets no panel background and
stays transparent; on top of that the window jumps to a different position
for every match count. Measured: 4 matches → 4 row heights, 8 matches → 7.

## Licence

MIT

## Author

Klaus Gasteier
