{ inputs, ... }: {
  # As a module for flake-parts, export the nixosModules so it's available in the flake
  flake = {
    nixosModules.nix = { config, pkgs, ... }: {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
        inputs.home-manager.nixosModules.home-manager
      ];
      programs.nix-index-database.comma.enable = true;

      nix.settings.experimental-features = ["nix-command" "flakes"];
     # nix.package = pkgs.lix;
      programs.nix-ld.enable = true;
      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        # Nix tooling
        nil
        nixd
        statix
        alejandra
        manix
        nix-inspect
      ];
    };
  };
}
