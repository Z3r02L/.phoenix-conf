{ config, pkgs, inputs, lib, ... }: {
  config = {
    # Enable niri
    programs.niri.enable = true;

    # Add niri to system packages
    environment.systemPackages = with pkgs; [
      niri
      xwayland-satellite
    ];
  };
}
