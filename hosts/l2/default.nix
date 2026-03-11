{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../zerg/hardware-configuration.nix
    ../../modules/profiles/server.nix
  ];

  networking.hostName = "l2";
  
  # Дополнительные настройки для хоста l2
  # ...
}
