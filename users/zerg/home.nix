{ config, pkgs, inputs, ... }:

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

  # ── Password store (pass) ──────────────────────────────────────
  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland;
    settings = {
      PASSWORD_STORE_DIR = "/home/zerg/.password-store";
    };
  };

  gtk = {
    enable = true;
    # theme = {
    #   name = "Adwaita-dark"; # Your theme
    #   package = pkgs.gnome.adwaita-icon-theme;
    # };
    # Add this to adopt the new default
    gtk4.theme = null;
  };


  home.packages = with pkgs; [
      # Shells
      zsh fish

      # Terminal utilities
      tmux starship
      yazi lf
      btop microfetch fastfetch

      # Network utilities
      wget curl

      # Version control
      git lazygit jujutsu lazyjj

      # Terminal emulators
      alacritty kitty wezterm

      # Editors
      zed-editor-fhs helix vscode-fhs antigravity # временно отключён из-за повреждённого tarball

      # Browsers
      librewolf brave ungoogled-chromium
      # Additional packages for Wayland support
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
      # reaper
 ];

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
  
  # Пример: если захотите привязать целую папку, используйте smartLink:
  # xdg.configFile."waybar".source = smartLink "waybar";

}
