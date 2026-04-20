{ inputs, self, ... }:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    ./configuration.nix
    ./hardware.nix
    ./dev-tools.nix
    ./nvidia.nix
    ./amd-cpu.nix

    # Features
    self.nixosModules.nix
    self.nixosModules.profile-desktop
    self.nixosModules.user-zerg
    self.nixosModules.fish
    self.nixosModules.neovim
    self.nixosModules.git

    inputs.stylix.nixosModules.stylix
    inputs.mangowm.nixosModules.mango
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.xremap-nix.nixosModules.default
  ];
}
