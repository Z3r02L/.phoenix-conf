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
    # nix-ai-tools.url = "github:numtide/nix-ai-tools";
  };
    

  outputs = inputs@{ self, nixpkgs, home-manager, wrappers, flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (import-tree ./modules/nixos)
        (import-tree ./modules/home-manager)
        # Убираем import-tree ./modules/wrappedPrograms, так как эти файлы не являются корректными flake-parts модулями
      ];
      systems = [ "x86_64-linux" ]; # Можно расширить
      perSystem = { config, pkgs, ... }: { };
      flake = {
        nixosConfigurations = {
          zerg = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit inputs; };
            modules = [
              (import-tree ./modules/profiles)
              ./hosts/zerg/default.nix
              ./hosts/zerg/configuration.nix
              inputs.mangowm.nixosModules.mango
            ];
          };
          nixConfig = {
            extra-substituters = [ "https://cache.numtide.com" ];
            extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
          };
        };
      };
      # описание машин и пользователей внутри flake-parts.modules, см. ниже
    };
}
