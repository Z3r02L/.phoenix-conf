{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Frameworks
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    wrappers.url = "github:lassulus/wrappers";

    # System Modules
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";
    persist-retro.url = "github:Geometer1729/persist-retro";

    stylix.url = "github:danth/stylix";

    # Software
    mangowm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.quickshell.follows = "quickshell";
    };

    # dgop = {
    #   url = "github:AvengeMedia/dgop";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    dankMaterialShell = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.dgop.follows = "dgop";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Software
    zapret-discord-youtube.url = "github:kartavkun/zapret-discord-youtube";
    helium.url = "github:schembriaiden/helium-browser-nix-flake";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    xremap-nix.url = "github:xremap/nix-flake";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, wrappers, flake-parts, import-tree, zapret-discord-youtube, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (import-tree ./modules/features)
      ];
      systems = [ "x86_64-linux" ];
      perSystem = { config, pkgs, ... }: { };
      flake = {
        nixosConfigurations = {
          zerg = import ./hosts/zerg/default.nix { inherit inputs self; };
          l2   = import ./hosts/l2/default.nix   { inherit inputs self; };
          s1   = import ./hosts/s1/default.nix   { inherit inputs self; };
        };
      };
    };
}
