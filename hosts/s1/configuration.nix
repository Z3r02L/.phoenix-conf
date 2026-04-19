{ config, pkgs, ... }: {
  imports = [
    ../zerg/hardware.nix
  ];

  networking.hostName = "s1";
  system.stateVersion = "25.05";

  # Специфические настройки для s1
  # ...
}
