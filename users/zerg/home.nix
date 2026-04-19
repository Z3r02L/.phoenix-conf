{ config, pkgs, inputs, ... }:
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
    Exec=vesktop --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer,WaylandWindowDecorations --ozone-platform-hint=wayland --enable-webrtc-pipewire-capturer --disable-gpu-sandbox --disable-features=GpuProcessSandbox --disable-gpu-memory-buffer-video-frames --ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy
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


}
