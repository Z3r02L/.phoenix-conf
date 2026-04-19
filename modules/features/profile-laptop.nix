{ inputs, ... }: {
  flake.nixosModules.profile-laptop = { ... }: {
    imports = [
      ../profiles/laptop.nix
    ];
  };
}
