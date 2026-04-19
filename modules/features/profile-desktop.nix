{ inputs, ... }: {
  flake.nixosModules.profile-desktop = { ... }: {
    imports = [
      ../profiles/desktop/desktop.nix
    ];
  };
}
