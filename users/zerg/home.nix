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
  imports = [
    ./mpv.nix
    ./fish.nix
    inputs.dankMaterialShell.homeModules.default
  ];
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
  home.file.".tmux.conf".source = smartLinkFile "tmux/tmux.conf";

  # Vesktop configuration (One Folder Plan)
  xdg.configFile."vesktop/settings.json".source = smartLinkFile "vesktop/settings.json";
  home.file.".local/share/applications/vesktop-wayland.desktop".source = smartLinkFile "vesktop/vesktop-wayland.desktop";
  home.file.".pi/agent/settings.json".source = smartLinkFile "pi/settings.json";

  # Принудительная запись (overwrite)
  xdg.configFile."vesktop/settings.json".force = true;
  home.file.".local/share/applications/vesktop-wayland.desktop".force = true;
  home.file.".pi/agent/settings.json".force = true;
  home.file.".tmux.conf".force = true;

  programs.dank-material-shell = {
    enable = true;
  };


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


  # programs.starship = {
  #   enable = true;
  #   enableFishIntegration = true;
  # };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # Синхронизация конфигов из директории dotfiles (Live-editing через smartLink)
  xdg.configFile = {
    "niri/config.kdl".source = smartLinkFile "niri/config.kdl";
    "mango".source = smartLink "mango";
    "noctalia".source = smartLink "noctalia";
    "starship.toml".source = smartLinkFile "starship/starship.toml";
    "kitty/kitty.conf".source = lib.mkForce (smartLinkFile "kitty/kitty.conf");
    "fuzzel/fuzzel.ini".source = lib.mkForce (smartLinkFile "fuzzel/fuzzel.ini");
  };
}
