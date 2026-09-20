#!/bin/bash
# Installiert den Rofi-App-Launcher in ein Omarchy-System (Hyprland mit Lua-Config).
# Aufruf: ./install.sh              installieren / aktualisieren
#         ./install.sh --uninstall  restlos entfernen
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
HYPR="$CFG/hypr"
BIN="$HOME/.local/bin"
MAIN="$HYPR/hyprland.lua"
THEMED="$CFG/omarchy/themed"
ICONS="$HOME/.local/share/icons/hicolor/scalable/apps"
MARK_BEGIN="-- >>> omarchy-rofi-launcher >>>"
MARK_END="-- <<< omarchy-rofi-launcher <<<"

strip_block() {
  [[ -f "$MAIN" ]] || return 0
  if grep -qF -- "$MARK_BEGIN" "$MAIN"; then
    cp "$MAIN" "$MAIN.bak.rofi-launcher.$(date +%s)"
    sed -i "\\|$MARK_BEGIN|,\\|$MARK_END|d" "$MAIN"
  fi
}

if [[ "${1:-}" == "--uninstall" ]]; then
  strip_block
  pkill -x -u "$USER" rofi 2>/dev/null || true
  rm -f "$HYPR/rofi-launcher.lua" "$BIN/omarchy-launch-rofi" \
        "$BIN/omarchy-rofi-placeholder-icons" \
        "$CFG/rofi/applauncher.rasi" "$THEMED/applauncher.rasi.tpl"
  # Nur selbst erzeugte Platzhalter entfernen, fremde Icons bleiben liegen.
  if [[ -d $ICONS ]]; then
    grep -rlF "omarchy-rofi-placeholder" "$ICONS" 2>/dev/null | xargs -r rm -f
    gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" >/dev/null 2>&1 || true
  fi
  hyprctl reload >/dev/null 2>&1 || true
  echo "Rofi-Launcher entfernt."
  exit 0
fi

# --- Voraussetzungen -------------------------------------------------------
command -v hyprctl >/dev/null \
  || { echo "hyprctl nicht gefunden - ist Hyprland installiert?" >&2; exit 1; }
command -v rofi >/dev/null \
  || { echo "rofi nicht gefunden. Installieren mit: omarchy-pkg-install rofi" >&2; exit 1; }
[[ -f "$MAIN" ]] \
  || { echo "$MAIN nicht gefunden - erwartet wird Omarchy mit Lua-Konfiguration." >&2; exit 1; }

# rofi 1.7.5 spricht X11; unter Hyprland laeuft es ueber XWayland.
if [[ -z "${DISPLAY:-}" ]]; then
  echo "Warnung: DISPLAY ist leer - laeuft XWayland? rofi benoetigt es." >&2
fi

# Die Lupe im Suchfeld ist eine Nerd-Font-Glyphe (U+F002).
if ! fc-list ':charset=f002' family 2>/dev/null | grep -qi "nerd"; then
  echo "Hinweis: keine Nerd-Schrift mit U+F002 gefunden - statt der Lupe" >&2
  echo "         erscheint ein Ersatzkaestchen. Abhilfe: ttf-jetbrains-mono-nerd" >&2
fi

# --- Dateien ---------------------------------------------------------------
mkdir -p "$BIN" "$CFG/rofi" "$THEMED"
install -m 755 "$SRC/bin/omarchy-launch-rofi"            "$BIN/omarchy-launch-rofi"
install -m 755 "$SRC/bin/omarchy-rofi-placeholder-icons" "$BIN/omarchy-rofi-placeholder-icons"
install -m 644 "$SRC/hypr/rofi-launcher.lua"             "$HYPR/rofi-launcher.lua"

# Statische Fassung als Rueckfallebene (Theme ohne colors.toml, Nicht-Omarchy).
install -m 644 "$SRC/config/applauncher.rasi"     "$CFG/rofi/applauncher.rasi"
# Vorlage: faerbt den Launcher beim Theme-Wechsel automatisch um.
# Nutzer-Templates haben Vorrang vor den mitgelieferten.
install -m 644 "$SRC/config/applauncher.rasi.tpl" "$THEMED/applauncher.rasi.tpl"

# --- Einbindung in hyprland.lua -------------------------------------------
strip_block
cat >>"$MAIN" <<LUA

$MARK_BEGIN
require("hypr.rofi-launcher")
$MARK_END
LUA

# --- Platzhalter-Icons -----------------------------------------------------
if command -v python3 >/dev/null; then
  "$BIN/omarchy-rofi-placeholder-icons" || true
fi

# --- Theme sofort erzeugen -------------------------------------------------
# omarchy-theme-set-templates schreibt nur beim Theme-Wechsel; einmal anstossen,
# damit der Launcher nicht bis dahin auf der statischen Palette sitzen bleibt.
# Der Themenname steht in theme.name -- "current/theme" ist ein Verzeichnis
# und liefert ueber readlink nur sich selbst zurueck.
THEME_NAME_FILE="$HOME/.local/state/omarchy/current/theme.name"
if command -v omarchy-theme-set >/dev/null && [[ -r $THEME_NAME_FILE ]]; then
  omarchy-theme-set "$(<"$THEME_NAME_FILE")" >/dev/null 2>&1 || true
fi

hyprctl reload >/dev/null 2>&1 || true

echo "Rofi-Launcher installiert. SUPER + R oeffnet ihn."
echo "Platzhalter-Icons spaeter erneuern: omarchy-rofi-placeholder-icons"
