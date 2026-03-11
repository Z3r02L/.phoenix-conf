{inputs, ...}: {
  perSystem = {pkgs, ...}: let
  in {
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
        SHELL = "fish";
      };
    };
  };
}
