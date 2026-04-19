{ ... }: {
  flake.nixosModules.profile-server = { ... }: {
    imports = [
      ../profiles/server.nix
    ];
  };
}
