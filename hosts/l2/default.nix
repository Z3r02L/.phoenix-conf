{ inputs, self, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ./configuration.nix
    self.nixosModules.profile-server
    self.nixosModules.nix
  ];
}
