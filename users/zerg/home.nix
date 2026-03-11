{ config, pkgs, inputs, ... }:
{
  home.stateVersion = "25.05"; # Устанавливаем версию состояния
  
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
      zed-editor-fhs vscode-fhs helix
      
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
      
      # Media
      qbittorrent syncthing
      audacity vlc mpv kdePackages.kdenlive
      reaper
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
