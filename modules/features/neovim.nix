{ inputs, ... }: {
  flake.nixosModules.neovim = { config, pkgs, ... }: {
    programs.neovim.enable = true;
  };

  perSystem = { pkgs, ... }: {
    packages.neovim = inputs.wrappers.lib.makeWrapper {
      inherit pkgs;
      package = pkgs.neovim;
      runtimeInputs = with pkgs; [
        clang
        gcc
        pkg-config
        manix
        statix
        nixd
        alejandra
        lua-language-server
      ];
      env = {
        SHELL = "${pkgs.fish}/bin/fish";
      };
    };
  };
}
