{ config, pkgs, ... }: {
  imports = [
    ../zerg/hardware.nix
  ];

  networking.hostName = "l2";
  system.stateVersion = "25.05";

  # Специфические настройки для l2
  # ...
}
