{ pkgs, ... }: 
{
  stylix = {
    enable = true;
    image = ./../../../dotfiles/wallpapers/current.png;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.geist-font;
        name = "Geist Sans";
      };
      serif = {
        package = pkgs.ibm-plex;
        name = "IBM Plex Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 16;
        terminal = 16;
        desktop = 16;
        popups = 16;
      };
    };
    
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    opacity = {
      applications = 1.0;
      terminal = 0.95;
      desktop = 0.95;
      popups = 1.0;
    };

    targets.grub.enable = false;
    targets.nixos-icons.enable = true;
  };
}
