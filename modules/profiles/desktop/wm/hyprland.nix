{ config, pkgs, inputs, lib, ... }: {
  config = {
    # Enable hyprland
    programs.hyprland.enable = true;
    
    # Add hyprland to system packages
    environment.systemPackages = with pkgs; [
      hyprland
    ];
  };
}
