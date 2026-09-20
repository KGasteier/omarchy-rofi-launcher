/* Mac-artiger App-Launcher fuer Omarchy.
   VORLAGE: Die Farb-Platzhalter werden von omarchy-theme-set-templates
   aus colors.toml des aktiven Themes ersetzt. Nicht direkt verwenden --
   die erzeugte Fassung liegt unter ~/.local/state/omarchy/current/theme/.

   Mac-artiger App-Launcher: Raster 7 Spalten x 6 Reihen, Icons mit Label.
   Aufruf: rofi -show drun -theme ~/.config/rofi/applauncher.rasi        */

configuration {
    modi:                        "drun";
    show-icons:                  true;
    drun-display-format:         "{name}";
    /* Suche: Treffer alphabetisch, Sortierung nach Eingabe */
    sorting-method:              "normal";
    sort:                        true;
    matching:                    "normal";
    icon-theme:                  "Yaru";
    drun-match-fields:           "name,generic,exec";
    /* Maus: Einfachklick startet */
    click-to-exit:               true;
    hover-select:                true;
    me-select-entry:             "";
    me-accept-entry:             "MousePrimary";
}

* {
    bg:        {{ background }}f7;   /* Panel, leicht transparent */
    bg-alt:    {{ lighter_background }}ff;   /* Suchzeile / Selektion */
    fg:        {{ foreground }}ff;
    fg-dim:    {{ dark_foreground }}ff;
    accent:    {{ accent }}ff;
    border-c:  #ffffff1f;
    line:      #ffffff21;   /* Trennlinie unter "zuletzt benutzt" */

    background-color: transparent;
    text-color:       @fg;
    font:             "Adwaita Sans 16";
}

window {
    /* Floating: zentriert, feste Groesse */
    location:         center;
    anchor:           center;
    width:            1770px;
    height:           1450px;
    padding:          0px;
    border:           1px;
    border-color:     @border-c;
    border-radius:    27px;
    background-color: @bg;
    transparency:     "real";
    cursor:           "default";
}

mainbox {
    padding:  30px 36px 21px 36px;
    spacing:  24px;
    children: [ inputbar, listview ];
}

/* ---------- Suchzeile ---------- */
inputbar {
    spacing:          10px;
    padding:          15px 21px;
    border-radius:    18px;
    background-color: @bg-alt;
    children:         [ prompt, entry ];
}

/* Lupe als Eingabeaufforderung. Adwaita Sans hat kein Lupen-Zeichen,
   deshalb nur fuer dieses Element die Nerd-Font-Glyphe U+F002. */
prompt {
    enabled:        true;
    text-color:     @fg-dim;
    font:           "JetBrainsMono Nerd Font 17";
    padding:        0px 14px 0px 4px;
    vertical-align: 0.5;
}

entry {
    placeholder:        "";
    placeholder-color:  @fg-dim;
    vertical-align:     0.5;
    cursor:             text;
}

/* ---------- Raster ---------- */
listview {
    columns:      7;
    lines:        7;
    fixed-height: true;
    fixed-columns: true;
    cycle:        true;
    scrollbar:    false;
    flow:         horizontal;   /* alphabetisch: links -> rechts, dann Zeile */
    /* spacing 0 + Abstand im element padding: nur so laeuft die Trennlinie
       unter der MRU-Zeile ohne Luecken durch. */
    spacing:      0px;
    padding:      9px 0px 0px 0px;
}

element {
    orientation:    vertical;
    padding:        21px 0px;
    spacing:        9px;
    border-radius:  21px;
    cursor:         pointer;
    children:       [ element-icon, element-text ];
}

element-icon {
    size:                 92px;
    horizontal-align:     0.5;
    background-color:     transparent;
    cursor:               inherit;
}

element-text {
    horizontal-align:  0.5;
    vertical-align:    0.5;
    text-color:        @fg;
    cursor:            inherit;
}

/* Zeile "zuletzt benutzt": Der Modus meldet ihre Zellen als urgent, hier
   bekommen sie die dezente Unterkante. Ohne MRU-Eintraege meldet der Modus
   nichts als urgent -- dann gibt es weder Zeile noch Linie. */
element normal.urgent, element alternate.urgent {
    border:           0px 0px 2px 0px;
    border-color:     @line;
    background-color: transparent;
    /* ohne Rundung, sonst bekommt die Trennlinie Kerben an den Zellgrenzen */
    border-radius:    0px;
}
element selected.urgent {
    border:           0px 0px 2px 0px;
    border-color:     @line;
    background-color: @bg-alt;
    /* oben gerundet, unten eckig: so bleibt die Trennlinie durchgehend */
    border-radius:    21px 21px 0px 0px;
}
element-text normal.urgent, element-text alternate.urgent,
element-text selected.urgent { text-color: @fg; }

/* Leere Fuellzellen der MRU-Zeile: Der Modus meldet sie als "active".
   Sie halten die Zeile auf volle Breite, duerfen aber nicht auf die Maus
   reagieren -- auch selected bleibt daher ohne Flaeche. */
element normal.active, element alternate.active, element selected.active {
    background-color: transparent;
    border:           0px 0px 2px 0px;
    border-color:     @line;
    border-radius:    0px;
}
element-text normal.active, element-text alternate.active,
element-text selected.active { text-color: transparent; }

element normal.normal { background-color: transparent; }
element alternate.normal { background-color: transparent; }

element selected.normal {
    background-color: @bg-alt;
    text-color:       @fg;
    /* bewusst ohne border: die Hervorhebung ist eine Flaeche, keine Kontur */
    border-radius:    21px;
}

element-text selected.normal { text-color: @fg; }

error-message { padding: 20px; background-color: @bg; }
