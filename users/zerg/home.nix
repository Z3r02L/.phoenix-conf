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
      zed-editor-fhs helix # vscode-fhs временно отключён из-за повреждённого tarball

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
      
      # Media
      qbittorrent syncthing
      audacity vlc mpv kdePackages.kdenlive
      # reaper
 ];

#  programs.mpv = {
#     enable = true;
#     package = pkgs.mpv;
#     config = {
#       vo = "gpu";
#     };
#     scripts = [ pkgs.mpvScripts.mpris ];
#   };


}
