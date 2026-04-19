{ pkgs, ... }: 
  let
    monoFont = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Mono";
    };
  in {
  stylix = {
    enable = true;
    image = ./../../../dotfiles/wallpapers/gruvbox-mountain-village.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    polarity = "dark";
    
    fonts = {
      monospace = monoFont;
      serif = monoFont;
      sansSerif = monoFont;
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
    
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    opacity = {
      applications = 0.9;
      terminal = 0.8;
      desktop = 0.8;
      popups = 0.9;
    };

    targets.grub.enable = false;
    targets.nixos-icons.enable = true;
    
  };
}
