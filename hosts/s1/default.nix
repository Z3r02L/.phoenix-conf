{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../zerg/hardware-configuration.nix
    ../../modules/profiles/laptop.nix
  ];

  networking.hostName = "s1";
  
  # Дополнительные настройки для хоста s1
  # ...
}
