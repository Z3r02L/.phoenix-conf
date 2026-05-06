{ config, pkgs, inputs, lib, ... }:

let
  # Переключатель: true = живые конфиги (для редактирования), false = замороженные (в Nix Store)
  isDev = true;

  dotfilesAbs = "${config.home.homeDirectory}/.phoenix-conf/dotfiles";

  vesktopWrapped = pkgs.writeShellScriptBin "vesktop" ''
    exec ${pkgs.vesktop}/bin/vesktop \
      --ozone-platform=wayland \
      --use-gl=egl \
      --disable-gpu \
      --disable-gpu-sandbox \
      --enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer \
      "$@"
  '';

  # Умная функция для папок
  smartLink = folder: 
    if isDev 
    then config.lib.file.mkOutOfStoreSymlink "${dotfilesAbs}/${folder}"
    else ../../dotfiles + "/${folder}";

  # Умная функция для одиночных файлов
  smartLinkFile = file: 
    if isDev 
    then config.lib.file.mkOutOfStoreSymlink "${dotfilesAbs}/${file}"
    else ../../dotfiles + "/${file}";
in
{
  imports = [
    ./mpv.nix
    ./fish.nix
  ];
  home.username = "zerg";
  home.homeDirectory = "/home/zerg";
  home.stateVersion = "25.05";
  # GTK theming is handled by Stylix

  home.packages = with pkgs; [
      # Shells
      starship nushell zsh
      direnv devenv

      bitwarden-desktop bitwarden-cli

      # Terminal utilities
      tmux btop
      yazi pcmanfm file-roller
      microfetch fastfetch
      file eza bat fd ripgrep-all fzf
      killall zip unzip jq rsync tree
      trash-cli tldr
      ydotool

      # Network utilities
      wget curl nmap
      borgbackup

      # Version control
      git lazygit jujutsu lazyjj
      gnupg age

      # Nix tools
      nix-output-monitor alejandra statix

      # Terminal emulators
      alacritty kitty

      # Editors
      zed-editor-fhs vscode-fhs antigravity-fhs

      # Browsers
      librewolf brave ungoogled-chromium
      inputs.helium.packages.${pkgs.system}.default
      xdg-utils

      # Communication
      telegram-desktop signal-desktop vesktopWrapped

      # Office and productivity
      onlyoffice-desktopeditors
      obsidian
      anki

      # Media
      qbittorrent syncthing
      audacity kdePackages.kdenlive obs-studio yt-dlp ffmpeg-full
      
      blender 
      
      krita
      inkscape-with-extensions # vector
      darktable 
      
      lunacy # figma alt

      # Icon themes
      papirus-icon-theme
      adwaita-icon-theme
  ];

  # ── Password store (pass) ──────────────────────────────────────
  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland.withExtensions (exts: with exts; [
      pass-otp
      pass-import
      pass-audit
    ]);
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
    };
  };

  # ── Синхронизация конфигов из директории dotfiles (Live-editing через smartLink) ──
  xdg.configFile."yazi".source = smartLink "yazi";
  xdg.configFile."nvim".source = smartLink "nvim";
  home.file.".tmux.conf".source = smartLinkFile "tmux/tmux.conf";
  xdg.configFile."Code/User/settings.json".source = smartLinkFile "vscode/settings.json";
  xdg.configFile."Code/User/keybindings.json".source = smartLinkFile "vscode/keybindings.json";
  xdg.configFile."Code/User/mcp.json".source = smartLinkFile "vscode/mcp.json";
  xdg.configFile."zed/settings.json".source = smartLinkFile "zed/settings.json";
  xdg.configFile."zed/keymap.json".source = smartLinkFile "zed/keymap.json";
  xdg.configFile."Antigravity/User/settings.json".source = smartLinkFile "antigravity/settings.json";

  # Vesktop configuration (One Folder Plan)
  xdg.configFile."vesktop/settings.json".source = smartLinkFile "vesktop/settings.json";
  home.file.".local/share/applications/vesktop.desktop".source = smartLinkFile "vesktop/vesktop.desktop";
  home.file.".local/share/applications/vesktop-wayland.desktop".source = smartLinkFile "vesktop/vesktop-wayland.desktop";
  home.file.".pi/agent/settings.json".source = smartLinkFile "pi/settings.json";

  # Принудительная запись (overwrite)
  xdg.configFile."vesktop/settings.json".force = true;
  xdg.configFile."nvim".force = true;
  xdg.configFile."Code/User/settings.json".force = true;
  xdg.configFile."Code/User/keybindings.json".force = true;
  xdg.configFile."Code/User/mcp.json".force = true;
  xdg.configFile."zed/settings.json".force = true;
  xdg.configFile."zed/keymap.json".force = true;
  xdg.configFile."Antigravity/User/settings.json".force = true;
  home.file.".local/share/applications/vesktop.desktop".force = true;
  home.file.".local/share/applications/vesktop-wayland.desktop".force = true;
  home.file.".pi/agent/settings.json".force = true;
  home.file.".tmux.conf".force = true;

  # GTK Icon Theme configuration
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  programs.kitty.enable = true;
  programs.fuzzel.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Синхронизация конфигов из директории dotfiles (Live-editing через smartLink)
  xdg.configFile = {
    "niri/config.kdl".source = smartLinkFile "niri/config.kdl";
    "noctalia".source = smartLink "noctalia";
    "starship.toml".source = smartLinkFile "starship/starship.toml";
    "kitty/kitty.conf".source = lib.mkForce (smartLinkFile "kitty/kitty.conf");
    "fuzzel/fuzzel.ini".source = lib.mkForce (smartLinkFile "fuzzel/fuzzel.ini");
  };
}
