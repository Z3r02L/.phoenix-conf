{ lib, ... }:
let
  common = {
    mod = "Mod"; # Super в Niri по умолчанию, в Mango Super
    terminal = "kitty";
    launcher = "fuzzel";
  };

  # Маппинг абстрактных действий на команды WM
  actions = {
    spawn = cmd: {
      mango = "spawn, ${cmd}";
      niri = "spawn \"${cmd}\"";
    };
    close = {
      mango = "killclient";
      niri = "close-window";
    };
    fullscreen = {
      mango = "togglefullscreen";
      niri = "maximize-column";
    };
    floating = {
      mango = "togglefloating";
      niri = "toggle-window-floating";
    };
    overview = {
      mango = "toggleoverview";
      niri = "toggle-overview";
    };
    
    # Навигация
    focus-left = { mango = "focusstack, -1"; niri = "focus-column-left"; };
    focus-right = { mango = "focusstack, 1"; niri = "focus-column-right"; };
    focus-up = { mango = "focusstack, -1"; niri = "focus-window-up"; };
    focus-down = { mango = "focusstack, 1"; niri = "focus-window-down"; };

    # Воркспейсы
    workspace = n: {
      mango = "view, ${toString n}";
      niri = "focus-workspace ${toString n}";
    };
    move-to-workspace = n: {
      mango = "tag, ${toString n}";
      niri = "move-column-to-workspace ${toString n}";
    };
    
    # Выход/Релоад
    quit = { mango = "quit"; niri = "quit"; };
    reload = { mango = "reload_config"; niri = "spawn \"niri msg action reload-config\""; };
  };

  # Список клавиш
  keys = [
    { key = "Return"; mods = [ common.mod ]; action = actions.spawn common.terminal; }
    { key = "D";      mods = [ common.mod ]; action = actions.spawn common.launcher; }
    { key = "Q";      mods = [ common.mod ]; action = actions.close; }
    { key = "F";      mods = [ common.mod ]; action = actions.fullscreen; }
    { key = "V";      mods = [ common.mod ]; action = actions.floating; }
    { key = "O";      mods = [ common.mod ]; action = actions.overview; }

    # J/K/H/L
    { key = "H"; mods = [ common.mod ]; action = actions.focus-left; }
    { key = "L"; mods = [ common.mod ]; action = actions.focus-right; }
    { key = "J"; mods = [ common.mod ]; action = actions.focus-down; }
    { key = "K"; mods = [ common.mod ]; action = actions.focus-up; }

    # System
    { key = "E"; mods = [ common.mod "Shift" ]; action = actions.quit; }
    { key = "R"; mods = [ common.mod "Shift" ]; action = actions.reload; }
  ] 
  ++ (map (n: { key = toString n; mods = [ common.mod ]; action = actions.workspace n; }) [1 2 3 4 5 6 7 8 9])
  ++ (map (n: { key = toString n; mods = [ common.mod "Shift" ]; action = actions.move-to-workspace n; }) [1 2 3 4 5 6 7 8 9]);

  # Генераторы строк
  genMango = b: "bind = ${lib.concatStringsSep "+", b.mods}, ${b.key}, ${b.action.mango}";
  genNiri = b: "    ${lib.concatStringsSep "+", (map (m: if m == "Mod" then "Mod" else m) b.mods)}+${b.key} { ${b.action.niri}; }";

in {
  mangoLines = lib.concatStringsSep "\n" (map genMango keys);
  niriLines = lib.concatStringsSep "\n" (map genNiri keys);
}