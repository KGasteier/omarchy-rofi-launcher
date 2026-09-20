-- Omarchy Rofi Launcher: Tastenbindung und Fensterregeln.
-- Wird von install.sh nach ~/.config/hypr/ kopiert und aus hyprland.lua
-- per require("hypr.rofi-launcher") eingebunden.

-- SUPER + R oeffnet den Launcher, ein zweiter Druck schliesst ihn.
-- Die Taste ist in Omarchy unbelegt: mit R existieren nur Kombinationen
-- mit zusaetzlichem CTRL, ALT oder SHIFT.
o.bind("SUPER + R", "App launcher (rofi)", "omarchy-launch-rofi")

-- rofi laeuft unter XWayland, die Fensterklasse ist "Rofi".
-- Kein eigener Rand noetig: Radius und Rahmen kommen aus dem .rasi-Theme.
-- stay_focused verhindert, dass ein Fokuswechsel das Overlay stehen laesst.
o.window("^(Rofi)$", {
  float = true,
  -- Nicht "center = true": das zentriert im nutzbaren Bereich, also unterhalb
  -- der von Waybar reservierten Leiste -> das Fenster sitzt sichtbar zu tief.
  -- "move" mit Ausdruecken rechnet dagegen gegen die volle Monitorhoehe.
  -- Waagerecht exakt mittig, senkrecht bewusst etwas oberhalb der Mitte:
  -- Ein Launcher wirkt mittig platziert, wenn er leicht hoeher sitzt.
  -- Kein fester Pixelwert, damit es auf jeder Aufloesung gleich aussieht.
  move = { "(monitor_w-window_w)/2", "(monitor_h-window_h)*0.43" },
  pin = true,
  stay_focused = true,
  tag = "-default-opacity",
})
