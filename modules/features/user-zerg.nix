{ inputs, self, ... }: {
  flake.nixosModules.user-zerg = { config, pkgs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
    ];

    users.users.zerg = {
      isNormalUser = true;
      description = "zerg's account";
      extraGroups = [ "wheel" "networkmanager" ];
    };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = {
      inherit inputs self;
    };
    home-manager.users.zerg = import ../../users/zerg/home.nix;
  };
}
