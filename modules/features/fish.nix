{
  inputs,
  lib,
  ...
}: {
  # NixOS модуль для включения fish
  flake.nixosModules.fish = { config, pkgs, ... }: {
    programs.fish.enable = true;
  };

  # Standalone package for reference
  perSystem = { pkgs, ... }: {
    packages.fish-standalone = pkgs.fish;
  };
}
