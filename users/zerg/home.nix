{ config, pkgs, inputs, lib, ... }:

let
  # Переключатель: true = живые конфиги (для редактирования), false = замороженные (в Nix Store)
  isDev = true; 

  dotfilesAbs = "${config.home.homeDirectory}/.phoenix-conf/dotfiles";
  
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
  home.stateVersion = "25.05";
  # GTK theming is handled by Stylix

  home.packages = with pkgs; [
      # Shells
      zsh fish nushell
      starship direnv devenv

      # Terminal utilities
      tmux btop
      yazi pcmanfm file-roller
      microfetch fastfetch
      file eza zoxide bat fd ripgrep-all fzf
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
      zed-editor-fhs helix vscode-fhs antigravity

      # Browsers
      librewolf brave ungoogled-chromium
      inputs.helium.packages.${pkgs.system}.default
      xdg-utils

      # Communication
      telegram-desktop signal-desktop vesktop

      # Office and productivity
      onlyoffice-desktopeditors
      obsidian
      anki

      # VPN and networking
      amnezia-vpn v2rayn
      zapret
      cloudflare-warp
      cloudflared

      # Media
      qbittorrent syncthing
      audacity vlc mpv kdePackages.kdenlive

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

  # Vesktop configuration for Wayland screencast
  home.file.".config/vesktop/settings.json".text = builtins.toJSON {
    discordBranch = "stable";
    firstLaunch = false;
    minimizeToTray = false;
    arRPC = false;
    usePipewire = true;
  };

  # Desktop file для Vesktop с флагами PipeWire screencast
  home.file.".local/share/applications/vesktop-wayland.desktop".text = ''
    [Desktop Entry]
    Name=Vesktop (Wayland)
    Comment=Vesktop with PipeWire screencast support
    Exec=vesktop --ozone-platform-hint=wayland --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer
    Icon=vesktop
    Type=Application
    Categories=Network;InstantMessaging;
  '';

  # Принудительная запись если файлы уже существуют
  home.file.".config/vesktop/settings.json".force = true;
  home.file.".local/share/applications/vesktop-wayland.desktop".force = true;

#  programs.mpv = {
#     enable = true;
#     package = pkgs.mpv;
#     config = {
#       vo = "gpu";
#     };
#     scripts = [ pkgs.mpvScripts.mpris ];
#   };

  # Синхронизация конфигов из директории dotfiles
  # Используется умная функция smartLinkFile (зависит от переменной isDev в начале файла)
  xdg.configFile."niri/config.kdl".source = smartLinkFile "niri/config.kdl";
  
  xdg.configFile."mango".source = smartLink "mango";
  xdg.configFile."noctalia".source = smartLink "noctalia";
  xdg.configFile."starship.toml".source = smartLinkFile "starship/starship.toml";

  # GTK Icon Theme configuration
  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        icon-theme = "Papirus-Dark";
        include = "~/.config/fuzzel/themes/noctalia";
        width = 45;
        lines = 10;
        # font = "JetBrainsMono Nerd Font Mono:size=14"; # Managed by Stylix
        horizontal-pad = 25;
        vertical-pad = 15;
        inner-pad = 10;
        border-width = 2;
        border-radius = lib.mkForce 12;
      };
    };
  };
}
